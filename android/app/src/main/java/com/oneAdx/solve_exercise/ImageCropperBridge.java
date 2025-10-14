package com.oneAdx.solve_exercise; // ← đổi đúng package của bạn

import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Bundle;
import android.util.Base64;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.Nullable;

import java.io.InputStream;
import java.io.OutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.ByteArrayOutputStream;
import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.android.FlutterFragmentActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

import com.canhub.cropper.CropImageContract;
import com.canhub.cropper.CropImageContractOptions;
import com.canhub.cropper.CropImageOptions;
import com.canhub.cropper.CropImageView;
import android.util.Log;

public final class ImageCropperBridge {

    public static final String CHANNEL = "image_cropper";
    private static final String TAG = "ImageCropperBridge";

    private final FlutterFragmentActivity activity;
    private MethodChannel.Result pendingResult;

    private ActivityResultLauncher<CropImageContractOptions> cropLauncher;
    private ActivityResultLauncher<Intent> cameraLauncher;
    private ActivityResultLauncher<String> galleryLauncher;

    public ImageCropperBridge(FlutterFragmentActivity activity) {
        this.activity = activity;
    }

    public void onCreate(@Nullable Bundle savedInstanceState) {
        // 1) Nhận kết quả từ Cropper
        cropLauncher = activity.registerForActivityResult(new CropImageContract(), result -> {
            if (pendingResult == null) return;

            if (result.isSuccessful()) {
                Uri uri = result.getUriContent(); // ⬅️ dùng Uri nội bộ của Cropper
                if (uri != null) {
                    deliverResultFromUri(uri);     // ⬅️ trả base64 từ Uri, KHÔNG lưu path
                } else {
                    // (tuỳ chọn) fallback nếu lib chỉ trả file path tạm nội bộ
                    String filePath = result.getUriFilePath(activity, /*includeStoragePermissions*/ false);
                    if (filePath != null) {
                        deliverResultFromFilePathOnce(filePath); // chỉ đọc 1 lần, không lưu thêm
                    } else {
                        pendingResult.error("CROP_EMPTY", "No image returned", null);
                    }
                }
            } else {
                Exception e = result.getError();
                pendingResult.error("CROP_ERROR", e != null ? e.getMessage() : "Crop failed", null);
            }
            pendingResult = null;
        });


        // 2) Nhận ảnh từ CameraCaptureActivity (camera tuỳ biến)
        cameraLauncher = activity.registerForActivityResult(
                new ActivityResultContracts.StartActivityForResult(),
                r -> {
                    if (pendingResult == null) return;
                    if (r.getResultCode() == FlutterFragmentActivity.RESULT_OK && r.getData() != null) {
                        String path = r.getData().getStringExtra("path");
                        if (path == null) {
                            pendingResult.error("CAMERA_EMPTY", "No image path", null);
                            pendingResult = null;
                            return;
                        }
                        CropImageOptions options = buildDefaultCropOptions();
                        Uri src = Uri.fromFile(new File(path));
                        CropImageContractOptions contractOptions = new CropImageContractOptions(src, options);
                        cropLauncher.launch(contractOptions);
                    } else {
                        pendingResult.error("CAMERA_CANCEL", "User cancelled", null);
                        pendingResult = null;
                    }
                });

        // 3) Chọn ảnh từ thư viện (SAF) → vào Cropper
        galleryLauncher = activity.registerForActivityResult(
                new ActivityResultContracts.GetContent(),
                uri -> {
                    if (pendingResult == null) return;
                    if (uri != null) {
                        CropImageOptions options = buildDefaultCropOptions();
                        CropImageContractOptions contractOptions = new CropImageContractOptions(uri, options);
                        cropLauncher.launch(contractOptions);
                    } else {
                        pendingResult.error("GALLERY_CANCEL", "User cancelled", null);
                        pendingResult = null;
                    }
                }
        );
    }

    /** Đọc file tạm do cropper tạo (nếu lib chỉ trả path). KHÔNG copy, KHÔNG lưu thêm. */
    private void deliverResultFromFilePathOnce(String filePath) {
        try {
            int[] wh = new int[2];
            String b64 = encodeBase64ScaledFromPathOnce(filePath, /*maxDim*/1600, wh);
            String mime = "image/png";

            Log.d(TAG, "deliverResultFromFilePathOnce: w=" + wh[0] + " h=" + wh[1] + " len=" + (b64 != null ? b64.length() : 0));

            Map<String, Object> payload = new HashMap<>();
            payload.put("base64", b64);
            payload.put("mime", mime);
            payload.put("width", wh[0]);
            payload.put("height", wh[1]);
            pendingResult.success(payload);
        } catch (Exception e) {
            pendingResult.error("ENCODE_ERROR", e.getMessage(), null);
        }
    }


    public void configureChannel(FlutterEngine engine) {
        new MethodChannel(engine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    if (pendingResult != null) {
                        result.error("BUSY", "Another request is in progress", null);
                        return;
                    }

                    switch (call.method) {
                        case "cameraAndCrop":
                        case "pickAndCrop":
                            pendingResult = result;
                            Intent i = new Intent(activity, CameraCaptureActivity.class);
                            cameraLauncher.launch(i);
                            break;

                        case "galleryAndCrop":
                            pendingResult = result;
                            galleryLauncher.launch("image/*");
                            break;

                        default:
                            result.notImplemented();
                    }
                });
    }

    private CropImageOptions buildDefaultCropOptions() {
        CropImageOptions options = new CropImageOptions();
        options.guidelines = CropImageView.Guidelines.OFF; // tắt lưới
        options.outputCompressFormat = Bitmap.CompressFormat.PNG;
        options.outputCompressQuality = 90;
        return options;
    }
    private void deliverResultFromUri(Uri uri) {
        try {
            int[] wh = new int[2];
            String b64 = encodeBase64ScaledFromUri(uri, /*maxDim*/1600, wh);
            String mime = "image/png";

            // (tuỳ chọn) log gọn để tránh spam logcat
            Log.d(TAG, "deliverResultFromUri: w=" + wh[0] + " h=" + wh[1] + " len=" + (b64 != null ? b64.length() : 0));

            Map<String, Object> payload = new HashMap<>();
            payload.put("base64", b64);
            payload.put("mime", mime);
            payload.put("width", wh[0]);
            payload.put("height", wh[1]);
            pendingResult.success(payload);
        } catch (Exception e) {
            pendingResult.error("ENCODE_ERROR", e.getMessage(), null);
        }
    }

    private String encodeBase64ScaledFromPathOnce(String path, int maxDim, int[] outWH) throws Exception {
        // Pass 1
        BitmapFactory.Options o = new BitmapFactory.Options();
        o.inJustDecodeBounds = true;
        BitmapFactory.decodeFile(path, o);
        int w = o.outWidth, h = o.outHeight;
        if (w <= 0 || h <= 0) throw new Exception("Invalid image bounds");

        // inSampleSize
        int inSample = 1;
        int maxSide = Math.max(w, h);
        while (maxSide / inSample > maxDim) inSample *= 2;

        // Pass 2
        BitmapFactory.Options o2 = new BitmapFactory.Options();
        o2.inSampleSize = inSample;
        Bitmap bmp = BitmapFactory.decodeFile(path, o2);
        if (bmp == null) throw new Exception("Decode bitmap failed");

        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        bmp.compress(Bitmap.CompressFormat.PNG, 100, baos);
        if (outWH != null && outWH.length >= 2) {
            outWH[0] = bmp.getWidth();
            outWH[1] = bmp.getHeight();
        }
        bmp.recycle();

        byte[] bytes = baos.toByteArray();
        return Base64.encodeToString(bytes, Base64.NO_WRAP);
    }



    private static void logLong(String tag, String msg) {
        if (msg == null) return;
        final int chunkSize = 3000;
        for (int i = 0; i < msg.length(); i += chunkSize) {
            int end = Math.min(msg.length(), i + chunkSize);
            Log.d(tag, msg.substring(i, end));
        }
    }

    private String encodeBase64ScaledFromUri(Uri uri, int maxDim, int[] outWH) throws Exception {
        BitmapFactory.Options o = new BitmapFactory.Options();
        o.inJustDecodeBounds = true;
        try (InputStream in = activity.getContentResolver().openInputStream(uri)) {
            BitmapFactory.decodeStream(in, null, o);
        }
        int w = o.outWidth, h = o.outHeight;
        if (w <= 0 || h <= 0) throw new Exception("Invalid image bounds");

        int inSample = 1;
        int maxSide = Math.max(w, h);
        while (maxSide / inSample > maxDim) inSample *= 2;

        BitmapFactory.Options o2 = new BitmapFactory.Options();
        o2.inSampleSize = inSample;

        Bitmap bmp;
        try (InputStream in2 = activity.getContentResolver().openInputStream(uri)) {
            bmp = BitmapFactory.decodeStream(in2, null, o2);
        }
        if (bmp == null) throw new Exception("Decode bitmap failed");

        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        bmp.compress(Bitmap.CompressFormat.PNG, 100, baos); // PNG: quality bị bỏ qua
        if (outWH != null && outWH.length >= 2) {
            outWH[0] = bmp.getWidth();
            outWH[1] = bmp.getHeight();
        }
        bmp.recycle();

        byte[] bytes = baos.toByteArray();
        return Base64.encodeToString(bytes, Base64.NO_WRAP);
    }

}

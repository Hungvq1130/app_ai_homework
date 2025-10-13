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
                String filePath = result.getUriFilePath(activity, true);
                Uri uri = result.getUriContent();

                String finalPath = filePath;
                if (finalPath == null && uri != null) {
                    finalPath = copyUriToCache(uri);
                }

                if (finalPath != null) {
                    deliverResult(finalPath); // ← trả path + base64
                } else {
                    pendingResult.error("CROP_EMPTY", "No image returned", null);
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

    private String copyUriToCache(Uri uri) {
        try {
            String name = "CROP_" + System.currentTimeMillis() + ".jpg";
            File outFile = new File(activity.getCacheDir(), name);
            try (InputStream in = activity.getContentResolver().openInputStream(uri);
                 OutputStream out = new FileOutputStream(outFile)) {
                byte[] buf = new byte[8192];
                int n;
                while ((n = in.read(buf)) > 0) out.write(buf, 0, n);
                out.flush();
            }
            return outFile.getAbsolutePath();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    /** Tạo payload trả về: path + base64 (đã nén/resize an toàn) */
    private void deliverResult(String filePath) {
        try {
            int[] wh = new int[2];
            String b64 = encodeBase64Scaled(filePath, /*maxDim*/1600, /*quality*/85, wh);
            String mime = "image/png";
            String dataUrl = "data:" + mime + ";base64," + b64;

            // 🔥 Logcat: in theo từng khúc để không bị cắt
            logLong(TAG, "dataUrl=" + dataUrl);

            Map<String, Object> payload = new HashMap<>();
            payload.put("base64", b64);
            payload.put("mime", mime);
            payload.put("width", wh[0]);
            payload.put("height", wh[1]);
            // (tuỳ bạn) payload.put("path", filePath);

            pendingResult.success(payload);
        } catch (Exception e) {
            pendingResult.error("ENCODE_ERROR", e.getMessage(), null);
        }
    }

    private static void logLong(String tag, String msg) {
        if (msg == null) return;
        final int chunkSize = 3000;
        for (int i = 0; i < msg.length(); i += chunkSize) {
            int end = Math.min(msg.length(), i + chunkSize);
            Log.d(tag, msg.substring(i, end));
        }
    }

    /**
     * Đọc ảnh từ path, decode có inSampleSize để giới hạn cạnh dài <= maxDim,
     * sau đó nén JPEG quality và trả base64 (NO_WRAP).
     */
    private String encodeBase64Scaled(String path, int maxDim, int quality, int[] outWH) throws Exception {
        // 1) Đọc kích thước thật
        BitmapFactory.Options o = new BitmapFactory.Options();
        o.inJustDecodeBounds = true;
        BitmapFactory.decodeFile(path, o);
        int w = o.outWidth;
        int h = o.outHeight;

        // 2) Tính inSampleSize
        int inSample = 1;
        int maxSide = Math.max(w, h);
        while (maxSide / inSample > maxDim) inSample *= 2;

        // 3) Decode với inSampleSize
        BitmapFactory.Options o2 = new BitmapFactory.Options();
        o2.inSampleSize = inSample;
        Bitmap bmp = BitmapFactory.decodeFile(path, o2);
        if (bmp == null) throw new Exception("Decode bitmap failed");

        // 4) Nén JPEG
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        bmp.compress(Bitmap.CompressFormat.PNG, quality, baos);
        if (outWH != null && outWH.length >= 2) {
            outWH[0] = bmp.getWidth();
            outWH[1] = bmp.getHeight();
        }
        bmp.recycle();

        byte[] bytes = baos.toByteArray();
        return Base64.encodeToString(bytes, Base64.NO_WRAP);
    }
}

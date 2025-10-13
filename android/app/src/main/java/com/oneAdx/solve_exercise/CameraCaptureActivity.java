package com.oneAdx.solve_exercise; // ← giữ đúng package của bạn

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.provider.Settings;
import android.widget.ImageButton;
import android.widget.Toast;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import androidx.camera.core.CameraSelector;
import androidx.camera.core.ImageCapture;
import androidx.camera.core.ImageCaptureException;
import androidx.camera.view.CameraController;
import androidx.camera.view.LifecycleCameraController;
import androidx.camera.view.PreviewView;

import java.io.File;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.FileOutputStream;
import java.text.SimpleDateFormat;
import java.util.Locale;
import java.util.concurrent.Executors;

public class CameraCaptureActivity extends AppCompatActivity {

    private LifecycleCameraController controller;
    private PreviewView previewView;
    private ImageButton btnCapture;
    private ImageButton btnGallery;

    private ActivityResultLauncher<String> cameraPermissionLauncher;
    private ActivityResultLauncher<String> galleryLauncher; // ← launcher mở thư viện

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_camera_capture);

        previewView = findViewById(R.id.previewView);
        btnCapture  = findViewById(R.id.btnCapture);
        btnGallery  = findViewById(R.id.btnGallery);

        // Launcher mở thư viện (SAF) → trả path về MainActivity để crop
        galleryLauncher =
                registerForActivityResult(new ActivityResultContracts.GetContent(), uri -> {
                    if (uri == null) {
                        setResult(RESULT_CANCELED);
                        return;
                    }
                    String path = copyUriToCache(uri);
                    if (path != null) {
                        Intent data = new Intent();
                        data.putExtra("path", path); // MainActivity đang trông chờ key "path"
                        setResult(RESULT_OK, data);
                    } else {
                        Toast.makeText(this, "Không đọc được ảnh đã chọn.", Toast.LENGTH_SHORT).show();
                        setResult(RESULT_CANCELED);
                    }
                    finish(); // quay về MainActivity (nơi sẽ mở crop)
                });

        // Đăng ký launcher xin quyền CAMERA
        cameraPermissionLauncher =
                registerForActivityResult(new ActivityResultContracts.RequestPermission(),
                        isGranted -> {
                            if (isGranted) {
                                initCameraAndUI(); // chỉ khởi tạo camera khi đã có quyền
                            } else {
                                if (!ActivityCompat.shouldShowRequestPermissionRationale(
                                        this, Manifest.permission.CAMERA)) {
                                    Toast.makeText(this,
                                            "Ứng dụng cần quyền Camera. Hãy cấp trong Cài đặt.",
                                            Toast.LENGTH_LONG).show();
                                    openAppSettings();
                                } else {
                                    Toast.makeText(this,
                                            "Đã từ chối quyền Camera.", Toast.LENGTH_SHORT).show();
                                    // Không finish ngay, vẫn cho phép mở thư viện
                                }
                            }
                        });

        // Gán click cho nút thư viện (không cần quyền camera)
        btnGallery.setOnClickListener(v -> openGallery());

        ensureCameraPermission(); // xin quyền & khởi tạo camera (nếu được)
    }

    private void ensureCameraPermission() {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA)
                == PackageManager.PERMISSION_GRANTED) {
            initCameraAndUI();
        } else {
            cameraPermissionLauncher.launch(Manifest.permission.CAMERA);
        }
    }

    private void openAppSettings() {
        Intent intent = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
        intent.setData(Uri.parse("package:" + getPackageName()));
        startActivity(intent);
    }

    private void initCameraAndUI() {
        // Khởi tạo CameraX
        controller = new LifecycleCameraController(this);
        controller.setCameraSelector(CameraSelector.DEFAULT_BACK_CAMERA);
        controller.setEnabledUseCases(CameraController.IMAGE_CAPTURE);

        previewView.setController(controller);
        controller.bindToLifecycle(this);

        btnCapture.setOnClickListener(v -> takePhoto());
        // btnGallery click đã được gán trong onCreate, hoạt động kể cả khi không có quyền camera
    }

    private void takePhoto() {
        // Lưu vào thư mục riêng của app (không cần quyền Storage)
        File dir = getExternalFilesDir(Environment.DIRECTORY_PICTURES);
        if (dir == null) dir = getFilesDir();

        String name = "IMG_" + new SimpleDateFormat("yyyyMMdd_HHmmss", Locale.US)
                .format(System.currentTimeMillis()) + ".jpg";
        File output = new File(dir, name);

        ImageCapture.OutputFileOptions opts =
                new ImageCapture.OutputFileOptions.Builder(output).build();

        controller.takePicture(
                opts,
                Executors.newSingleThreadExecutor(),
                new ImageCapture.OnImageSavedCallback() {
                    @Override
                    public void onImageSaved(@NonNull ImageCapture.OutputFileResults outputFileResults) {
                        Intent data = new Intent();
                        data.putExtra("path", output.getAbsolutePath()); // MainActivity sẽ crop
                        setResult(RESULT_OK, data);
                        finish();
                    }

                    @Override
                    public void onError(@NonNull ImageCaptureException exception) {
                        Toast.makeText(CameraCaptureActivity.this,
                                "Lỗi chụp ảnh: " + exception.getMessage(),
                                Toast.LENGTH_SHORT).show();
                        setResult(RESULT_CANCELED);
                        finish();
                    }
                }
        );
    }

    private void openGallery() {
        // Mở picker hệ thống, không cần quyền đọc bộ nhớ từ Android 10+
        galleryLauncher.launch("image/*");
    }

    private String copyUriToCache(Uri uri) {
        try {
            File dir = getExternalFilesDir(Environment.DIRECTORY_PICTURES);
            if (dir == null) dir = getFilesDir();
            String name = "PICK_" + System.currentTimeMillis() + ".jpg";
            File outFile = new File(dir, name);

            try (InputStream in = getContentResolver().openInputStream(uri);
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
}

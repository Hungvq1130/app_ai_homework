package com.oneAdx.solve_exercise; // ← đổi đúng package của bạn

import android.os.Bundle;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterFragmentActivity;
import io.flutter.embedding.engine.FlutterEngine;

public class MainActivity extends FlutterFragmentActivity {

    private ImageCropperBridge cropperBridge;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        cropperBridge = new ImageCropperBridge(this);
        cropperBridge.onCreate(savedInstanceState); // đăng ký ActivityResult
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        cropperBridge.configureChannel(flutterEngine); // đăng ký MethodChannel
    }
}

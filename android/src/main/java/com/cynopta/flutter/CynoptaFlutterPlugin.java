package com.cynopta.flutter;

import androidx.annotation.NonNull;
import com.cynopta.sdk.CynoptaFlutterBridge;
import io.flutter.embedding.engine.plugins.FlutterPlugin;

/**
 * Flutter plugin entrypoint for the Cynopta SDK.
 */
public class CynoptaFlutterPlugin implements FlutterPlugin {
    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        CynoptaFlutterBridge.attachToFlutterEngine(binding.getApplicationContext(), binding);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    }
}

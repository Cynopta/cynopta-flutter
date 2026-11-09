package com.cynopta.flutter;

import androidx.annotation.NonNull;
import com.cynopta.sdk.CynoptaFlutterBridge;
import io.flutter.embedding.engine.plugins.FlutterPlugin;

/**
 * Zero-config Flutter plugin entrypoint for the Cynopta Android SDK.
 *
 * <p>Automatically attaches {@link CynoptaFlutterBridge} to any active {@code FlutterEngine}
 * and bundles the native {@code com.github.Cynopta:android-sdk-dist} artifact.
 */
public class CynoptaFlutterPlugin implements FlutterPlugin {
    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        CynoptaFlutterBridge.attachToFlutterEngine(binding.getApplicationContext(), binding);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        // MethodChannel lifecycle is bound to the BinaryMessenger / FlutterEngine.
    }
}

package top.wj.zk_vpn;

import android.app.Activity;
import android.app.Application;
import android.util.Log;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

public class ZkVpnPlugin implements FlutterPlugin, ActivityAware {
    private static final String TAG = "ZkVpnPlugin";
    private MethodChannel methodChannel;
    private EventChannel eventChannel;
    private FlutterPluginBinding pluginBinding;
    private Application application;
    private Activity activity;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPlugin.FlutterPluginBinding binding) {
        Log.i(TAG, "onAttachedToEngine: ");
        this.pluginBinding = binding;
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPlugin.FlutterPluginBinding binding) {
        Log.i(TAG, "onDetachedFromEngine: ");
        this.pluginBinding = null;
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        Log.i(TAG, "onAttachedToActivity: ");
        if (pluginBinding != null) {
            setup(pluginBinding, binding);
        }
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        Log.i(TAG, "onDetachedFromActivityForConfigChanges: ");
        onDetachedFromActivity();
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        Log.i(TAG, "onReattachedToActivityForConfigChanges: ");
        onAttachedToActivity(binding);
    }

    @Override
    public void onDetachedFromActivity() {
        Log.i(TAG, "onDetachedFromActivity: ");
        teardown();
    }

    private void setup(FlutterPluginBinding fBin, ActivityPluginBinding aBin) {
        methodChannel = new MethodChannel(fBin.getBinaryMessenger(), "zk_vpn");
//        eventChannel = new EventChannel(fBin.getBinaryMessenger(), "zk_vpn_event");

        this.application = (Application) fBin.getApplicationContext();
        this.activity = aBin.getActivity();

        PluginMethodCall pluginMethodCall = new PluginMethodCall(this.activity);
        PluginStream pluginStream = new PluginStream(this.activity);

        methodChannel.setMethodCallHandler(pluginMethodCall);
        eventChannel.setStreamHandler(pluginStream);
    }

    private void teardown() {
        methodChannel.setMethodCallHandler(null);
//        eventChannel.setStreamHandler(null);

        application = null;
        activity = null;

        methodChannel = null;
        eventChannel = null;
    }
}

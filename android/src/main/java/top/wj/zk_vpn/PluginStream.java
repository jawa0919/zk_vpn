package top.wj.zk_vpn;

import android.app.Activity;
import android.util.Log;

import io.flutter.plugin.common.EventChannel;

public class PluginStream implements EventChannel.StreamHandler {
    private static final String TAG = "PluginStream";

    private final Activity activity;

    public PluginStream(final Activity activity) {
        this.activity = activity;
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        Log.i(TAG, "onListen: ");
    }

    @Override
    public void onCancel(Object arguments) {
        Log.i(TAG, "onCancel: ");
    }
}

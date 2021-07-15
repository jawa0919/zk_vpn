package top.wj.zk_vpn;

import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.util.Log;

import androidx.annotation.NonNull;

import net.ttxc.L4Proxy.L4ProxyArd;

import java.util.Arrays;
import java.util.HashMap;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class PluginMethodCall implements MethodChannel.MethodCallHandler {
    private static final String TAG = "PluginMethodCall";

    private final Activity activity;

    public PluginMethodCall(final Activity activity) {
        this.activity = activity;
    }

    private MethodChannel.Result pendingResult;

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull final MethodChannel.Result result) {
        Log.i(TAG, "onMethodCall: ");
        pendingResult = result;
        if (call.method.equals("getPlatformVersion")) {
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        } else if (call.method.equals("connect")) {
            Log.i(TAG, "connect");
            final String url = call.argument("url");
            new Thread() {
                public void run() {
                    L4ProxyArd api = L4ProxyArd.getInstance();
                    Log.i(TAG, "getInstance");
                    boolean isConnect = api.L4ProxyConnectVPN();
                    Log.i(TAG, "L4ProxyConnectVPN " + isConnect);
                    String forwardAddress = api.L4ProxyConnectServer(url);
                    Log.i(TAG, "L4ProxyConnectServer " + forwardAddress);
                    int forwardPort = api.L4ProxyServiceRun(url);
                    Log.i(TAG, "L4ProxyServiceRun " + forwardPort);
                    final HashMap<String, Object> map = new HashMap<>();
                    String userCode = api.getTitle();
                    Log.i(TAG, "getTitle " + userCode);
                    map.put("userCode", userCode);
                    map.put("forwardAddress", forwardAddress);
                    map.put("forwardPort", forwardPort);
                    activity.runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            pendingResult.success(map);
                        }
                    });
                }
            }.start();
        } else {
            result.notImplemented();
        }
    }
}

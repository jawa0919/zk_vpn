package top.wiz.zk_vpn

import android.app.Activity
import android.app.Application
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

class ZkVpnPlugin : FlutterPlugin, ActivityAware {

    private var methodChannel: MethodChannel? = null
    private var pluginBinding: FlutterPlugin.FlutterPluginBinding? = null
    private var application: Application? = null
    private var activity: Activity? = null

    companion object {
        private const val TAG = "ZkVpnPlugin"

        @Deprecated("only use flutter v1")
        fun registerWith(registrar: PluginRegistry.Registrar) {
            if (registrar.activity() == null) return
            val plugin = ZkVpnPlugin()
            val application = registrar.activeContext().applicationContext as Application
            plugin.setup(registrar.messenger(), application, registrar.activity())
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.i(TAG, "onAttachedToEngine: ")
        this.pluginBinding = binding
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.i(TAG, "onDetachedFromEngine: ")
        this.pluginBinding = null
    }

    override fun onDetachedFromActivity() {
        Log.i(TAG, "onDetachedFromActivity: ")
        teardown()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        Log.i(TAG, "onReattachedToActivityForConfigChanges: ")
        onAttachedToActivity(binding)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        Log.i(TAG, "onAttachedToActivity: ")
        pluginBinding?.let {
            setup(it.binaryMessenger, it.applicationContext as Application, binding.activity)
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        Log.i(TAG, "onDetachedFromActivityForConfigChanges: ")
        onDetachedFromActivity()
    }

    private fun setup(messenger: BinaryMessenger, application: Application, activity: Activity) {
        methodChannel = MethodChannel(messenger, "zk_vpn")

        this.application = application
        this.activity = activity

        val handler = ZkVpnMethodCallHandler(activity)
        methodChannel?.setMethodCallHandler(handler)
    }

    private fun teardown() {
        methodChannel?.setMethodCallHandler(null)
        application = null
        activity = null
        methodChannel = null
    }
}

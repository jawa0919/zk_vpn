package top.wiz.zk_vpn

import android.app.Activity
import android.os.Environment
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import net.ttxc.L4Proxy.L4ProxyArd
import java.io.File

class ZkVpnMethodCallHandler(private val activity: Activity) : MethodChannel.MethodCallHandler {

    companion object {
        private const val TAG = "ZkVpnMethodCallHandler"
    }

    private var l4ProxyArd: L4ProxyArd? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            "checkCertificate" -> {
                val rootPath = Environment.getExternalStorageDirectory().path
                val platformDir = File("$rootPath/platform");
                val ipConfigFile = File("$rootPath/platform/ipConfig.txt");
                result.success(platformDir.exists() && platformDir.isDirectory && ipConfigFile.exists())
            }
            "getCertCN" -> {
                val rootPath = Environment.getExternalStorageDirectory().path
                val platformDir = File("$rootPath/platform")
                Thread {
                    val api = l4ProxyArd ?: L4ProxyArd.getInstance()
                    val res = api.getCertCN(platformDir.path)
                    result.success(res)
                }.start()
            }
            "getTitle" -> {
                Thread {
                    val api = l4ProxyArd ?: L4ProxyArd.getInstance()
                    val res = api.title
                    result.success(res)
                }.start()
            }
            "getSSoInfo" -> {
                val appId = call.argument<String>("appId")
                val type = call.argument<String>("type")
                Thread {
                    val api = l4ProxyArd ?: L4ProxyArd.getInstance()
                    val res = api.getSSoInfo(appId, type)
                    result.success(res)
                }.start()
            }
            "connectVPN" -> {
                Thread {
                    val api = l4ProxyArd ?: L4ProxyArd.getInstance()
                    val res = api.L4ProxyConnectVPN()
                    result.success(res)
                }.start()
            }
            "serviceRun" -> {
                val url = call.argument<String>("url")
                Thread {
                    val api = l4ProxyArd ?: L4ProxyArd.getInstance()
                    val res = api.L4ProxyServiceRun("$url")
                    result.success(res)
                }.start()
            }
            "connectServer" -> {
                val url = call.argument<String>("url")
                Thread {
                    val api = l4ProxyArd ?: L4ProxyArd.getInstance()
                    val res = api.L4ProxyConnectServer("$url")
                    result.success(res)
                }.start()
            }
            else -> {
                result.notImplemented()
            }
        }
    }
}
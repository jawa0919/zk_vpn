package top.wiz.zk_vpn

import android.app.Activity
import android.os.Environment
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import net.ttxc.L4Proxy.L4ProxyArd
import java.io.File

class ZkVpnMethodCallHandler(private val activity: Activity) : MethodChannel.MethodCallHandler {

    companion object {
        private const val TAG = "ZkVpnMethodCallHandler"
    }

    private val mainHandler = Handler(Looper.getMainLooper())
    private var api: L4ProxyArd? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            "checkCertificate" -> {
                val rootPath = Environment.getExternalStorageDirectory().path
                val platformDir = File("$rootPath/platform")
                val ipConfigFile = File("$rootPath/platform/ipConfig.txt")
                val res = platformDir.exists() && platformDir.isDirectory && ipConfigFile.exists()
                result.success(res)
            }
            "getCertCN" -> {
                val rootPath = Environment.getExternalStorageDirectory().path
                val platformDir = File("$rootPath/platform")
                Thread {
                    api = api ?: L4ProxyArd.getInstance()
                    val res = api?.getCertCN(platformDir.path)
                    mainHandler.post(Runnable { result.success(res) })
                }.start()
            }
            "getTitle" -> {
                Thread {
                    api = api ?: L4ProxyArd.getInstance()
                    val res = api?.title
                    mainHandler.post(Runnable { result.success(res) })
                }.start()
            }
            "getSSoInfo" -> {
                val appId = call.argument<String>("appId")
                val type = call.argument<String>("type")
                Thread {
                    api = api ?: L4ProxyArd.getInstance()
                    val res = api?.getSSoInfo(appId, type)
                    mainHandler.post(Runnable { result.success(res) })
                }.start()
            }
            "connectVPN" -> {
                Thread {
                    api = api ?: L4ProxyArd.getInstance()
                    val res = api?.L4ProxyConnectVPN()
                    mainHandler.post(Runnable { result.success(res) })
                }.start()
            }
            "serviceRun" -> {
                val url = call.argument<String>("url")
                Thread {
                    api = api ?: L4ProxyArd.getInstance()
                    val res = api?.L4ProxyServiceRun("$url")
                    mainHandler.post(Runnable { result.success(res) })
                }.start()
            }
            "connectServer" -> {
                val url = call.argument<String>("url")
                Thread {
                    api = api ?: L4ProxyArd.getInstance()
                    val res = api?.L4ProxyConnectServer("$url")
                    mainHandler.post(Runnable { result.success(res) })
                }.start()
            }
            else -> {
                result.notImplemented()
            }
        }
    }
}
package vpnclient.click

//
import android.content.Intent
import android.net.VpnService
import android.os.Bundle
import io.flutter.plugin.common.MethodChannel
//

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    private val CHANNEL = "vpnclient_engine2"

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            when (call.method) {
                "startVPN" -> {
                    val intent = VpnService.prepare(this)
                    if (intent != null) {
                        startActivityForResult(intent, 0)
                    } else {
                        startVPN()
                    }
                    result.success(true)
                }
                "stopVPN" -> {
                    stopVPN()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun startVPN() {
        val intent = Intent(this, VPNService::class.java)
        startService(intent)
    }

    private fun stopVPN() {
        val intent = Intent(this, VPNService::class.java)
        stopService(intent)
    }
}

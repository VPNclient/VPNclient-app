package click.vpnclient

import android.net.VpnService
import android.os.ParcelFileDescriptor
import android.util.Log
import java.io.FileInputStream
import java.io.FileOutputStream

class VPNService : VpnService() {
    private var vpnInterface: ParcelFileDescriptor? = null

    override fun onCreate() {
        super.onCreate()
        val builder = Builder()
        builder.setSession("VPNclient")
            .addAddress("10.0.0.2", 24)
            .addDnsServer("8.8.8.8")
            .addRoute("0.0.0.0", 0)

        vpnInterface = builder.establish()

        Thread {
            try {
                val input = FileInputStream(vpnInterface!!.fileDescriptor)
                val output = FileOutputStream(vpnInterface!!.fileDescriptor)
                val buffer = ByteArray(32767)
                while (true) {
                    val length = input.read(buffer)
                    if (length > 0) {
                        output.write(buffer, 0, length)
                    }
                }
            } catch (e: Exception) {
                Log.e("VPNService", "Error in VPN thread", e)
            }
        }.start()
    }

    override fun onDestroy() {
        vpnInterface?.close()
        vpnInterface = null
        super.onDestroy()
    }
}

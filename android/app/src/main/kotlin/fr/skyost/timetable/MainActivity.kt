package fr.skyost.timetable

import android.content.Intent
import android.content.pm.PackageManager
import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    companion object {
        /**
         * The refresh timetable intent key.
         */
        const val INTENT_REFRESH_TIMETABLE: String = "mainActivity://refreshTimetable"

        /**
         * The date intent key.
         */
        const val INTENT_DATE: String = "mainActivity://date"

        /**
         * The permission alarm set code.
         */

        const val PERMISSION_ALARM_SET: Int = 0
    }

    /**
     * The requested date.
     */
    var requestedDateString: String? = null

    /**
     * Whether the user wants to refresh the timetable.
     */
    var shouldRefreshTimeTable: Boolean = false

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)

        requestedDateString = intent.extras?.getString(INTENT_DATE, null)
        shouldRefreshTimeTable = intent.extras?.getBoolean(INTENT_REFRESH_TIMETABLE, false) == true
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            Application.CHANNEL
        ).setMethodCallHandler { call, result ->
            Application.handleMethod(call, result, this)
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String>,
        grantResults: IntArray
    ) {
        when (requestCode) {
            PERMISSION_ALARM_SET -> {
                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    Toast.makeText(this, R.string.alarm_permission_granted, Toast.LENGTH_SHORT)
                        .show()
                } else {
                    Toast.makeText(this, R.string.alarm_permission_denied, Toast.LENGTH_SHORT)
                        .show()
                }
                return
            }
        }
    }
}

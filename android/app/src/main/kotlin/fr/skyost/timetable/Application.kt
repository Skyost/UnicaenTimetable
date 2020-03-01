package fr.skyost.timetable

import android.Manifest
import android.accounts.Account
import android.accounts.AccountManager
import android.app.Activity
import android.app.NotificationManager
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.AsyncTask
import android.os.Build
import android.provider.AlarmClock
import android.provider.Settings
import android.widget.Toast
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.transistorsoft.flutter.backgroundfetch.HeadlessTask
import fr.skyost.timetable.ringer.LessonModeManager
import fr.skyost.timetable.utils.Utils
import fr.skyost.timetable.widget.TodayWidgetReceiver
import io.flutter.app.FlutterApplication
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.apache.commons.codec.binary.Base64


class Application : FlutterApplication() {
    companion object {
        const val CHANNEL = "fr.skyost.timetable"

        const val PREFERENCES_FILE = "preferences"
        const val PREFERENCES_LESSONS_RINGER_MODE = "ringer-mode"

        fun handleMethod(call: MethodCall, result: MethodChannel.Result, context: Context) {
            when (call.method) {
                "account.get" -> {
                    val manager: AccountManager = AccountManager.get(context)
                    val accounts: Array<Account> = manager.getAccountsByType(context.getString(R.string.account_type_authority))
                    if (!accounts.isNullOrEmpty()) {
                        val account: Account = accounts.first()
                        val password: String = manager.getPassword(account)
                        var base64Encoded = true

                        if (Base64.isBase64(password)) {
                            base64Encoded = false
                        }

                        val user: MutableMap<String, Any> = HashMap()
                        user["username"] = account.name
                        user["password"] = if (base64Encoded) Utils.base64Decode(context, password) else password
                        user["base64_encoded"] = base64Encoded

                        result.success(user)
                        return
                    }
                    result.success(null)
                }
                "account.create" -> {
                    val manager: AccountManager = AccountManager.get(context)
                    val account = Account(call.argument("username"), context.getString(R.string.account_type_authority))
                    if (manager.addAccountExplicitly(account, call.argument("password"), null)) {
                        result.success(null)
                        return
                    }
                    result.error("generic_error", null, null)
                }
                "account.remove" -> {
                    val manager: AccountManager = AccountManager.get(context)
                    val accounts: Array<Account> = manager.getAccountsByType(context.getString(R.string.account_type_authority))
                    if (!accounts.isNullOrEmpty()) {
                        Utils.removeAccount(manager, accounts.first(), result)
                        return
                    }
                    result.success(null)
                }
                "sync.finished" -> {
                    val updateIntent = Intent(context, TodayWidgetReceiver::class.java)
                    updateIntent.action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                    updateIntent.putExtra(TodayWidgetReceiver.INTENT_REFRESH_WIDGETS, true)
                    context.sendBroadcast(updateIntent)
                    result.success(null)
                }
                "ringer_mode.changed" -> {
                    val mode: Int = call.argument<Int>("value")!!
                    context.getSharedPreferences(PREFERENCES_FILE, Context.MODE_PRIVATE).edit().putInt(PREFERENCES_LESSONS_RINGER_MODE, mode).commit()
                    if (mode == 0) { // If mode = 0 (i.e. disabled), we cancel and disable the LessonModeManager.
                        AsyncTask.execute {
                            LessonModeManager.cancel(context)
                            if (LessonModeManager.inLesson(context)) {
                                LessonModeManager.disable(context)
                            }
                        }
                    } else { // If mode = 1 (i.e. silent), we have to request the required permissions.
                        if (mode == 1) {
                            val manager: NotificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !manager.isNotificationPolicyAccessGranted && context is Activity) {
                                Toast.makeText(context, R.string.toast_enable_silent, Toast.LENGTH_LONG).show()
                                val intent = Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS)
                                context.startActivityForResult(intent, 0)
                                result.success(false)
                                return
                            }
                        }

                        // And we can enable the LessonModeManager.
                        AsyncTask.execute {
                            LessonModeManager.schedule(context)
                            if (LessonModeManager.inLesson(context)) {
                                LessonModeManager.enable(context)
                            }
                        }
                    }
                    result.success(true)
                }
                "activity.set_alarm" -> {
                    if (context !is Activity) {
                        result.error("no_activity", null, null)
                        return
                    }

                    val activity: Activity = context
                    if (ContextCompat.checkSelfPermission(context, Manifest.permission.SET_ALARM) != PackageManager.PERMISSION_GRANTED) {
                        ActivityCompat.requestPermissions(activity, arrayOf(Manifest.permission.SET_ALARM), MainActivity.PERMISSION_ALARM_SET)
                        result.success(false)
                        return
                    }

                    val intent = Intent(AlarmClock.ACTION_SET_ALARM)
                    intent.putExtra(AlarmClock.EXTRA_MESSAGE, call.argument<Int>("title"))
                    intent.putExtra(AlarmClock.EXTRA_HOUR, call.argument<Int>("hour"))
                    intent.putExtra(AlarmClock.EXTRA_MINUTES, call.argument<Int>("minute"))
                    context.startActivity(intent)
                    result.success(null)
                }
                "activity.extract_should_sync" -> {
                    if (context !is MainActivity) {
                        result.error("no_activity", null, null)
                        return
                    }

                    val activity: MainActivity = context
                    if(activity.shouldRefreshTimeTable) {
                        activity.shouldRefreshTimeTable = false
                        result.success(true)
                        return
                    }
                    result.success(false)
                }
                "activity.extract_date" -> {
                    if (context !is MainActivity) {
                        result.error("no_activity", null, null)
                        return
                    }

                    val activity: MainActivity = context
                    if(activity.date != null) {
                        activity.date = null
                        result.success(activity.date)
                        return
                    }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onCreate() {
        super.onCreate()
        HeadlessTask.onInitialized { engine -> MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result -> handleMethod(call, result, applicationContext) } }
    }
}
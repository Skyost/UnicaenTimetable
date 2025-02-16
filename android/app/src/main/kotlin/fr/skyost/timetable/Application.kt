package fr.skyost.timetable

import android.Manifest
import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.provider.AlarmClock
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.transistorsoft.flutter.backgroundfetch.HeadlessTask
import fr.skyost.timetable.utils.AccountUtils
import fr.skyost.timetable.widget.TodayWidgetProvider
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class Application : android.app.Application() {
    companion object {
        const val CHANNEL = "fr.skyost.timetable"

        fun handleMethod(call: MethodCall, result: MethodChannel.Result, context: Context) {
            when (call.method) {
                "account.get" -> {
                    result.success(AccountUtils.get(context)?.toMap())
                }
                "account.create" -> {
                    val username: String? = call.argument("username")
                    val password: String? = call.argument("password")
                    if (username == null || password == null) {
                        result.error("not_enough_parameters", null, null)
                        return
                    }
                    result.success(AccountUtils.create(context, username, password))
                }
                "account.remove" -> {
                    CoroutineScope(Dispatchers.Main).launch {
                        result.success(AccountUtils.remove(context))
                    }
                }
                "sync.get" -> {
                    val lastModified = Lesson.resolveLessonsFile(context).lastModified()
                    result.success(lastModified.div(1000))
                }
                "sync.refresh" -> {
                    val updateIntent = Intent(context, TodayWidgetProvider::class.java)
                    updateIntent.action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                    updateIntent.putExtra(TodayWidgetProvider.INTENT_REFRESH_WIDGETS, true)
                    context.sendBroadcast(updateIntent)
                    AccountUtils.notifyUpdate(context)
                    val lastModified = Lesson.resolveLessonsFile(context).lastModified()
                    result.success(lastModified.div(1000))
                }
                "activity.setAlarm" -> {
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
                "activity.shouldRefreshTimeTable" -> {
                    if (context !is MainActivity) {
                        result.error("no_activity", null, null)
                        return
                    }

                    val activity: MainActivity = context
                    if (activity.shouldRefreshTimeTable) {
                        activity.shouldRefreshTimeTable = false
                        result.success(true)
                        return
                    }
                    result.success(false)
                }
                "activity.getRequestedDateString" -> {
                    if (context !is MainActivity) {
                        result.error("no_activity", null, null)
                        return
                    }

                    val activity: MainActivity = context
                    if (activity.requestedDateString != null) {
                        val date: String = activity.requestedDateString!!
                        activity.requestedDateString = null
                        result.success(date)
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
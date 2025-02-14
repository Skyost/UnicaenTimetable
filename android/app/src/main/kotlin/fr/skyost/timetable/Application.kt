package fr.skyost.timetable

import android.content.Context
import fr.skyost.timetable.utils.AccountUtils
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
                else -> result.notImplemented()
            }
        }
    }
}
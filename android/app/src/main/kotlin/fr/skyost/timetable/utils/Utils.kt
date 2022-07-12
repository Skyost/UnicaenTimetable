package fr.skyost.timetable.utils

import android.accounts.Account
import android.accounts.AccountManager
import android.accounts.AccountManagerFuture
import android.app.PendingIntent
import android.os.Build
import android.os.Bundle
import io.flutter.plugin.common.MethodChannel
import org.joda.time.DateTime

class Utils {
    companion object {
        /**
         * Returns PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT if supported.
         *
         * @return PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT if supported.
         */
        val FLAG_IMMUTABLE_OR_UPDATE_CURRENT = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) { PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT } else { PendingIntent.FLAG_UPDATE_CURRENT }

        /**
         * Removes an account.
         *
         * @param manager The accounts manager.
         * @param account The account.
         */
        fun removeAccount(manager: AccountManager, account: Account?, result: MethodChannel.Result) {
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    manager.removeAccount(account, null, { accountManagerFuture: AccountManagerFuture<Bundle> ->
                        result.success(accountManagerFuture.result.getBoolean(AccountManager.KEY_BOOLEAN_RESULT, false))
                    }, null)
                } else {
                    manager.removeAccount(account, { accountManagerFuture: AccountManagerFuture<Boolean> ->
                        result.success(accountManagerFuture.result)
                    }, null)
                }
            } catch (ex: java.lang.Exception) {
                ex.printStackTrace()
                result.error(ex.javaClass.name, ex.message, null)
            }
        }

        /**
         * Returns tomorrow midnight (and 1 second) calendar.
         *
         * @return Tomorrow midnight calendar.
         */
        fun tomorrowMidnight(): DateTime {
            return DateTime.now().plusDays(1).withTimeAtStartOfDay()
        }

        /**
         * Adds a leading zero to the given number.
         *
         * @return The number with a leading zero.
         */
        fun addLeadingZero(n: Int): String {
            return (if (n < 10) "0" else "") + n.toString()
        }
    }
}
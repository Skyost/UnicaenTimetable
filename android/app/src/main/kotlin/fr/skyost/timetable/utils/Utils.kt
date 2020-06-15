package fr.skyost.timetable.utils

import android.accounts.Account
import android.accounts.AccountManager
import android.accounts.AccountManagerFuture
import android.content.Context
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.util.Base64
import io.flutter.plugin.common.MethodChannel
import org.joda.time.DateTime
import java.nio.charset.Charset
import javax.crypto.Cipher
import javax.crypto.SecretKeyFactory
import javax.crypto.spec.PBEKeySpec
import javax.crypto.spec.PBEParameterSpec


class Utils {
    companion object {
        /**
         * Decodes a password.
         *
         * @param context The context.
         * @param password The account password.
         *
         * @return The decoded password.
         */
        fun base64Decode(context: Context, password: String): String {
            try {
                val bytes = Base64.decode(password, Base64.DEFAULT)
                val keyFactory = SecretKeyFactory.getInstance("PBEWithMD5AndDES")
                val key = keyFactory.generateSecret(PBEKeySpec(Settings.Secure.ANDROID_ID.toCharArray()))
                val pbeCipher = Cipher.getInstance("PBEWithMD5AndDES")
                pbeCipher.init(Cipher.DECRYPT_MODE, key, PBEParameterSpec(Settings.Secure.getString(context.contentResolver, Settings.Secure.ANDROID_ID).toByteArray(Charset.forName("UTF-8")), 20))
                return String(pbeCipher.doFinal(bytes), Charset.forName("UTF-8"))
            } catch (ex: Exception) {
                ex.printStackTrace()
            }
            return password
        }

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

        fun addLeadingZero(n: Int): String {
            return (if (n < 10) "0" else "") + n.toString()
        }
    }
}
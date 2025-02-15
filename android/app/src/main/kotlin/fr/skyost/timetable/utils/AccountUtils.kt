package fr.skyost.timetable.utils

import android.accounts.Account
import android.accounts.AccountManager
import android.app.Activity
import android.content.Context
import android.os.Build
import fr.skyost.timetable.R
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File
import java.time.LocalDateTime
import java.time.ZoneOffset

/**
 * Contains various useful methods to interact with the account on device.
 */
class AccountUtils {
    companion object {
        private val synchronizationFile: String = "synchronization"

        /**
         * Creates the account.
         *
         * @param context The context.
         * @param username The username.
         * @param password The password.
         *
         * @return A boolean indicating the result.
         */
        fun create(context: Context, username: String, password: String): Boolean {
            try {
                val manager: AccountManager = AccountManager.get(context)
                val account = Account(username, context.getString(R.string.account_type_authority))
                return manager.addAccountExplicitly(account, password, null)
            } catch (ex: Exception) {
                ex.printStackTrace()
                return false
            }
        }

        /**
         * Returns the account credentials.
         *
         * @param context The context.
         *
         * @return The credentials instance.
         */
        fun get(context: Context): Credentials? {
            try {
                val manager: AccountManager = AccountManager.get(context)
                val accounts: Array<Account> =
                    manager.getAccountsByType(context.getString(R.string.account_type_authority))
                val account: Account? = accounts.firstOrNull()
                if (account != null) {
                    return Credentials(account.name, manager.getPassword(account))
                }
            } catch (ex: Exception) {
                ex.printStackTrace()
            }
            return null
        }

        /**
         * Removes the account.
         *
         * @param context The context.
         *
         * @return A boolean indicating the result.
         */
        suspend fun remove(context: Context): Boolean {
            return withContext(Dispatchers.IO) {
                try {
                    val manager: AccountManager = AccountManager.get(context)
                    val accounts: Array<Account> =
                        manager.getAccountsByType(context.getString(R.string.account_type_authority))
                    val account = accounts.firstOrNull() ?: return@withContext false
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        val result = manager.removeAccount(
                            account,
                            if (context is Activity) context else null,
                            null,
                            null
                        )
                        return@withContext result.result.getBoolean(
                            AccountManager.KEY_BOOLEAN_RESULT,
                            false
                        )
                    } else {
                        val result = manager.removeAccount(account, null, null)
                        return@withContext result.result
                    }
                } catch (ex: Exception) {
                    ex.printStackTrace()
                }
                return@withContext false
            }
        }

        /**
         * Resolves the last update date.
         *
         * @param context The context.
         *
         * @return The last update date (seconds since epoch).
         */
        fun resolveLastUpdate(context: Context): Long? {
            val file = File(context.filesDir, synchronizationFile)
            if (!file.exists()) {
                return null
            }
            val content = file.readText()
            return content.toLongOrNull()
        }

        /**
         * Notifies an update.
         *
         * @param context The context.
         *
         * @return The last update date (seconds since epoch).
         */
        fun notifyUpdate(context: Context): Long? {
            val manager: AccountManager = AccountManager.get(context)
            val accounts: Array<Account> =
                manager.getAccountsByType(context.getString(R.string.account_type_authority))
            val account = accounts.firstOrNull() ?: return null
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                manager.notifyAccountAuthenticated(account)
            }
            val file = File(context.filesDir, synchronizationFile)
            if (!file.exists()) {
                file.createNewFile()
            }
            val date = LocalDateTime.now()
            val secondsSinceEpoch = date.toEpochSecond(ZoneOffset.UTC)
            file.writeText(secondsSinceEpoch.toString())
            return secondsSinceEpoch
        }
    }
}

/**
 * Contains an [username] and a [password].
 */
data class Credentials(val username: String, val password: String) {
    /**
     * Converts these credentials to a map.
     *
     * @return The map.
     */
    fun toMap(): Map<String, String> {
        return mapOf(
            "username" to username,
            "password" to password
        )
    }
}
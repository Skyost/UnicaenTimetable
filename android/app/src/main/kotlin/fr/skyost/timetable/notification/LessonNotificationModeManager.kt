package fr.skyost.timetable.notification

import android.app.*
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.AsyncTask
import android.os.Build
import android.provider.Settings
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat
import fr.skyost.timetable.*
import fr.skyost.timetable.Application
import fr.skyost.timetable.utils.Utils
import org.joda.time.DateTime
import org.joda.time.DateTimeConstants
import org.joda.time.LocalDate


/**
 * The manager that allows to manager the lesson mode.
 */
@RequiresApi(Build.VERSION_CODES.M)
class LessonNotificationModeManager : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        // If it's not enabled, we can exit right now.
        AsyncTask.execute {
            if (isEnabled(context)) {
                if (inLesson(context)) {
                    enable(context)
                }
                else {
                    disable(context);
                }
                schedule(context)
            } else {
                if (inLesson(context)) {
                    disable(context)
                }
                cancel(context)
            }
        }
    }

    /**
     * The disable notification action.
     */
    class NotificationAction : IntentService(NotificationAction::class.java.simpleName) {
        override fun onHandleIntent(intent: Intent?) {
            // Disables the lesson mode.
            cancel(this)
            disable(this)
            schedule(this, getScheduleTime(this, 1))
        }
    }

    companion object {
        /**
         * The notification channel ID.
         */
        private const val NOTIFICATION_CHANNEL_ID: String = "timetable_notification_channel"

        /**
         * The notification tag.
         */
        private const val NOTIFICATION_TAG: String = "timetable_notification"

        /**
         * The mode notification ID.
         */
        private const val MODE_NOTIFICATION_ID: Int = 1

        /**
         * The exception notification ID.
         */
        private const val EXCEPTION_NOTIFICATION_ID: Int = 2

        /**
         * Disabled value.
         */
        const val VALUE_DISABLED: Int = -1

        /**
         * Alarms filter value.
         */
        private const val VALUE_FILTER_ALARMS: Int = 0

        /**
         * Turns on lesson mode, even if disabled in the config.
         *
         * @param context The context.
         */
        @JvmOverloads
        fun enable(context: Context) {
            try {
                val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                val interruptionFilter: Int = getInterruptionFilterFromPreferences(context)
                if (interruptionFilter != VALUE_DISABLED) {
                    manager.setInterruptionFilter(interruptionFilter)
                }
                // And we display the notification.
                displayNotification(context)
            } catch (ex: SecurityException) {
                // If the user has disabled the application in its settings, this exception will be thrown.
                val message = context.getString(R.string.notification_lessonmodenotification_exception)
                val builder = NotificationCompat.Builder(context.applicationContext, NOTIFICATION_CHANNEL_ID)
                        .setSmallIcon(R.drawable.notification_small_drawable)
                        .setContentTitle(context.getString(R.string.notification_lessonmodenotification_title))
                        .setStyle(NotificationCompat.BigTextStyle().bigText(message))
                        .setPriority(NotificationCompat.PRIORITY_MAX)
                        .setContentText(message)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    val intent = Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS)
                    builder.setContentIntent(PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT))
                }
                val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                // So we have to notify the user.
                manager.notify(NOTIFICATION_TAG, EXCEPTION_NOTIFICATION_ID, builder.build())
            }
        }

        /**
         * Turns off lesson mode, even if disabled in the config.
         *
         * @param context The context.
         */
        fun disable(context: Context) {
            val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.setInterruptionFilter(NotificationManager.INTERRUPTION_FILTER_ALL)

            // And we close the notification.
            closeNotification(context)
        }

        /**
         * Schedules the next call of this receiver.
         *
         * @param context The context.
         * @param time The schedule time.
         */
        @JvmOverloads
        fun schedule(context: Context, time: Long = getScheduleTime(context)) {
            var scheduleTime = time
            val manager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            // Time = -1 when there is not lesson left today so we have to refresh it tomorrow.
            if (scheduleTime == -1L) {
                scheduleTime = Utils.tomorrowMidnight().millis
            }
            // We schedule the pending intent.
            val pendingIntent = getPendingIntent(context)
            when {
                Build.VERSION.SDK_INT >= Build.VERSION_CODES.M -> manager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, scheduleTime, pendingIntent)
                Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP -> manager.setExact(AlarmManager.RTC_WAKEUP, scheduleTime, pendingIntent)
                else -> manager[AlarmManager.RTC_WAKEUP, scheduleTime] = pendingIntent
            }
        }

        /**
         * Cancels the schedule of this receiver.
         *
         * @param context The context.
         */
        fun cancel(context: Context) {
            val manager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

            // We cancel the pending intent.
            val pendingIntent = getPendingIntent(context)
            manager.cancel(pendingIntent)
            pendingIntent.cancel()
        }

        /**
         * Returns a PendingIntent to schedule this class.
         *
         * @param context The context.
         *
         * @return A PendingIntent to schedule this class.
         */
        private fun getPendingIntent(context: Context): PendingIntent {
            val intent = Intent(context, LessonNotificationModeManager::class.java)
            return PendingIntent.getBroadcast(context, 0, intent, 0)
        }

        /**
         * Checks if the user is currently in a lesson.
         *
         * @param context The context.
         *
         * @return Whether we're currently in a lesson.
         */
        fun inLesson(context: Context): Boolean {
            val repository = LessonRepository()
            repository.load(context)

            val lessons: List<Lesson> = repository.getRemainingLessons()
            if (lessons.isEmpty()) {
                return false
            }
            // This is the next lesson, we get it and we check that we're currently in it.
            val next = lessons[0]
            val now = DateTime.now()
            return now.isAfter(next.start) && now.isBefore(next.end)
        }

        /**
         * Returns the next schedule time of this receiver.
         *
         * @param context The context.
         *
         * @return The next schedule time of this receiver. -1 if it should be tomorrow midnight.
         */
        @JvmOverloads
        fun getScheduleTime(context: Context, skip: Int = 0): Long {
            val repository = LessonRepository()
            repository.load(context)

            // If there is not remaining lessons, we return -1.
            val lessons: List<Lesson> = repository.getRemainingLessons()
            if (lessons.size <= skip) {
                return -1L
            }

            // If we're not in this lesson, we return the start date (+1 sec).
            // Otherwise, we return the end date (+1 sec).
            val next = lessons[skip]
            return if (DateTime.now().isBefore(next.start)) next.start.millis + 1000L else next.end.millis + 1000L
        }

        /**
         * Returns the interruption filter sets in preferences.
         *
         * @param context The context.
         *
         * @return The interruption filter sets in preferences.
         */
        private fun getInterruptionFilterFromPreferences(context: Context): Int {
            // We read the preference value.
            var mode: Int = context.getSharedPreferences(Application.PREFERENCES_FILE, Context.MODE_PRIVATE).getInt(Application.PREFERENCES_LESSON_NOTIFICATION_MODE, VALUE_DISABLED)

            when (mode) {
                VALUE_FILTER_ALARMS -> return NotificationManager.INTERRUPTION_FILTER_ALARMS
            }

            return VALUE_DISABLED
        }

        /**
         * Checks if the lesson mode is enabled according to the config.
         *
         * @param context The context.
         *
         * @return Whether the lesson mode is enabled.
         */
        fun isEnabled(context: Context): Boolean {
            return getInterruptionFilterFromPreferences(context) != VALUE_DISABLED
        }

        /**
         * Creates the notification channel.
         *
         * @param context The context.
         */
        @RequiresApi(api = Build.VERSION_CODES.O)
        fun createChannel(context: Context) {
            // We create a channel.
            val channel = NotificationChannel(NOTIFICATION_CHANNEL_ID, context.getString(R.string.notification_lessonmodenotification_channel), NotificationManager.IMPORTANCE_HIGH)
            channel.lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            channel.setBypassDnd(true)
            // And we add it to the notification manager.
            val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(channel)
        }

        /**
         * Displays the lesson mode notification.
         *
         * @param context The context.
         */
        private fun displayNotification(context: Context) {
            // If we are saturday or sunday (it should not be possible), we go to the next monday.
            var date = LocalDate.now()
            if (date.dayOfWeek == DateTimeConstants.SATURDAY || date.dayOfWeek == DateTimeConstants.SUNDAY) {
                date = date.withDayOfWeek(DateTimeConstants.MONDAY).plusWeeks(1)
            }
            // We create the MainActivity intent.
            val intent = Intent(context, MainActivity::class.java)
            intent.putExtra(MainActivity.INTENT_DATE, date.toString("yyyy-MM-dd"))
            // The disable intent.
            val disableMode = PendingIntent.getService(context, 0, Intent(context, NotificationAction::class.java), PendingIntent.FLAG_ONE_SHOT)
            // And we create the message.
            val value = context.getSharedPreferences(Application.PREFERENCES_FILE, Context.MODE_PRIVATE).getInt(Application.PREFERENCES_LESSON_NOTIFICATION_MODE, VALUE_DISABLED)
            val message = context.getString(R.string.notification_lessonmodenotification_message, context.resources.getStringArray(R.array.notification_lessonmodenotification)[value + 1].toUpperCase())
            // We build our notification.
            val builder = NotificationCompat.Builder(context.applicationContext, NOTIFICATION_CHANNEL_ID)
                    .setSmallIcon(R.drawable.notification_small_drawable)
                    .setContentTitle(context.getString(R.string.notification_lessonmodenotification_title))
                    .setStyle(NotificationCompat.BigTextStyle().bigText(message))
                    .setContentText(message)
                    .addAction(R.drawable.notification_block_drawable, context.getString(R.string.notification_lessonmodenotification_button), disableMode)
                    .setOngoing(true)
                    .setPriority(NotificationCompat.PRIORITY_MAX)
                    .setCategory(NotificationCompat.CATEGORY_ALARM)
                    .setContentIntent(PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT))
            val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            // And we send it !
            manager.notify(NOTIFICATION_TAG, MODE_NOTIFICATION_ID, builder.build())
        }

        /**
         * Closes the lesson mode notification.
         *
         * @param context The context.
         */
        fun closeNotification(context: Context) {
            val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            // Closes the notification if possible.
            manager.cancel(NOTIFICATION_TAG, MODE_NOTIFICATION_ID)
        }
    }
}
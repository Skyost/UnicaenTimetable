package fr.skyost.timetable.widget

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import fr.skyost.timetable.Lesson
import fr.skyost.timetable.LessonRepository
import fr.skyost.timetable.utils.Utils
import org.joda.time.DateTime
import java.util.concurrent.Executors

/**
 * The AsyncTask that allows to schedule a widget update.
 */
class TodayWidgetUpdateScheduler {
    companion object {
        fun schedule(context: Context, repository: LessonRepository) {
            val executor = Executors.newSingleThreadExecutor()
            val handler = Handler(Looper.getMainLooper())

            executor.execute {
                val nextSchedule = getNextSchedule(context, repository)
                handler.post {
                    scheduleAt(context, nextSchedule)
                }
            }
        }

        private fun getNextSchedule(context: Context, repository: LessonRepository): DateTime {
            try {
                // We load the repository.
                repository.load(context)
                // We get the remaining lessons and if possible, we return the end of the next one.
                val remainingLessons: List<Lesson> = repository.getRemainingLessons()
                val date: DateTime = if (remainingLessons.isEmpty()) Utils.tomorrowMidnight() else remainingLessons[0].end
                return if (date.secondOfMinute == 0) date.withSecondOfMinute(1) else date
            }
            catch(ex: Exception) {
                ex.printStackTrace()
            }
            return Utils.tomorrowMidnight()
        }

        private fun scheduleAt (context: Context, date: DateTime) {
            // With the alarm manager, we schedule our update.
            val manager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val intent = Intent(context, TodayWidgetUpdateScheduler::class.java)
            intent.action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            intent.putExtra(TodayWidgetReceiver.INTENT_REFRESH_WIDGETS, true)
            manager[AlarmManager.RTC_WAKEUP, date.millis] = PendingIntent.getBroadcast(context, 0, intent, Utils.FLAG_IMMUTABLE_OR_UPDATE_CURRENT)
        }
    }
}
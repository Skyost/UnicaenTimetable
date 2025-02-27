package fr.skyost.timetable.widget

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import fr.skyost.timetable.Lesson
import java.time.LocalDateTime
import java.time.ZonedDateTime
import java.time.temporal.ChronoUnit
import java.util.concurrent.Executors

/**
 * The utility class that allows to schedule a widget update.
 */
class TodayWidgetUpdateScheduler {
    companion object {
        fun schedule(context: Context, widgetId: Int, lessonsOfTheDay: List<Lesson>) {
            val executor = Executors.newSingleThreadExecutor()
            val handler = Handler(Looper.getMainLooper())

            executor.execute {
                val nextSchedule = getNextSchedule(lessonsOfTheDay)
                handler.post {
                    scheduleAt(context, widgetId, nextSchedule)
                }
            }
        }

        private fun getNextSchedule(lessonsOfTheDay: List<Lesson>): LocalDateTime {
            val tomorrowMidnight = LocalDateTime
                .now()
                .plusDays(1)
                .truncatedTo(ChronoUnit.DAYS)
            try {
                // We get the remaining lessons and if possible, we return the end of the next one.
                val remainingLessons: List<Lesson> = getRemainingLessons(lessonsOfTheDay)
                val date: LocalDateTime =
                    if (remainingLessons.isEmpty()) tomorrowMidnight else remainingLessons[0].end
                return if (date.second == 0) date.withSecond(1) else date
            } catch (ex: Exception) {
                ex.printStackTrace()
            }
            return tomorrowMidnight
        }

        private fun getRemainingLessons(lessonsOfTheDay: List<Lesson>): List<Lesson> {
            // We get the today's lessons.
            val now: LocalDateTime = LocalDateTime.now()
            val result = ArrayList(lessonsOfTheDay)
            for (lesson in lessonsOfTheDay) {
                // If we are past the lesson, we remove it from the list.
                if (!now.isAfter(lesson.end)) {
                    continue
                }
                result.remove(lesson)
            }
            return result
        }

        private fun scheduleAt(context: Context, widgetId: Int, date: LocalDateTime) {
            // With the alarm manager, we schedule our update.
            val offset = ZonedDateTime.now().offset
            val manager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val intent = Intent(context, TodayWidgetProvider::class.java)
            intent.action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            intent.putExtra(TodayWidgetProvider.INTENT_REFRESH_WIDGETS, true)
            intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
            manager[AlarmManager.RTC_WAKEUP, date.toEpochSecond(offset) * 1000] =
                PendingIntent.getBroadcast(
                    context,
                    TodayWidgetProvider.REFRESH_REQUEST,
                    intent,
                    TodayWidgetProvider.FLAG_IMMUTABLE_OR_UPDATE_CURRENT
                )
        }
    }
}

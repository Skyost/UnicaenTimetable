package fr.skyost.timetable.widget

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.os.AsyncTask
import fr.skyost.timetable.Lesson
import fr.skyost.timetable.LessonRepository
import fr.skyost.timetable.utils.Utils
import org.joda.time.DateTime
import java.lang.ref.WeakReference

/**
 * The AsyncTask that allows to schedule a widget update.
 */
class TodayWidgetUpdateScheduler internal constructor(context: Context) : AsyncTask<LessonRepository, Void?, DateTime>() {
    /**
     * A context atomic reference.
     */
    private val context: WeakReference<Context> = WeakReference(context)

    override fun doInBackground(vararg repositories: LessonRepository): DateTime {
        try {
            // We get the repository.
            val repository: LessonRepository = repositories[0]
            repository.load(context.get()!!)
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

    override fun onPostExecute(date: DateTime) {
        val context = context.get() ?: return
        // With the alarm manager, we schedule our update.
        val manager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, javaClass)
        intent.action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
        intent.putExtra(TodayWidgetReceiver.INTENT_REFRESH_WIDGETS, true)
        manager[AlarmManager.RTC_WAKEUP, date.millis] = PendingIntent.getBroadcast(context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT)
    }

    /**
     * Returns the context.
     *
     * @return The context.
     */
    fun getContext(): Context? {
        return context.get()
    }

}
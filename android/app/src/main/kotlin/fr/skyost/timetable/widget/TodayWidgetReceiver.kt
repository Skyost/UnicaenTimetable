package fr.skyost.timetable.widget

import TodayWidgetDateManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.text.format.DateFormat
import android.widget.RemoteViews
import androidx.core.content.ContextCompat
import fr.skyost.timetable.LessonRepository
import fr.skyost.timetable.MainActivity
import fr.skyost.timetable.R
import org.joda.time.LocalDate
import java.text.SimpleDateFormat
import java.util.*

/**
 * The today's widget provider.
 */
class TodayWidgetReceiver : AppWidgetProvider() {
    companion object {
        /**
         * The back request.
         */
        const val BACK_REQUEST = 400
        /**
         * The next request.
         */
        const val NEXT_REQUEST = 500
        /**
         * The refresh widgets intent key.
         */
        const val INTENT_REFRESH_WIDGETS = "refresh-widgets"
        /**
         * The relative day intent key.
         */
        const val INTENT_RELATIVE_DAY = "relative-day"
    }

    override fun onReceive(context: Context, intent: Intent) {
        // If we have to refresh the widgets, then let's do it !
        if (intent.hasExtra(INTENT_REFRESH_WIDGETS)) {
            val manager = AppWidgetManager.getInstance(context)
            this.onUpdate(
                    context,
                    manager,
                    if (intent.hasExtra(AppWidgetManager.EXTRA_APPWIDGET_ID)) intArrayOf(intent.getIntExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID)) else manager.getAppWidgetIds(ComponentName(context, this.javaClass)),
                    intent.getIntExtra(INTENT_RELATIVE_DAY, 0)
            )
        }
        super.onReceive(context, intent)
    }

    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        onUpdate(context, manager, ids, 0)
    }

    private fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray, relativeDay: Int) {
        // We change the relative day.
        val dateManager: TodayWidgetDateManager = TodayWidgetDateManager.instance
        dateManager.relativeDay = relativeDay
        // We update everything.
        val views = RemoteViews(context.packageName, R.layout.widget_today_layout)
        updateDrawables(context, views, dateManager)
        updateTitle(context, views, dateManager)
        updateMessage(context, views)
        registerIntents(context, views, dateManager)
        // We notify the update.
        for (id in ids) {
            manager.notifyAppWidgetViewDataChanged(id, R.id.widget_today_content)
            manager.updateAppWidget(id, views)
        }
        // And we schedule the next update.
        val repository = LessonRepository()
        TodayWidgetUpdateScheduler(context).execute(repository)
    }

    /**
     * Updates the drawables.
     *
     * @param context The context.
     * @param views Widgets' RemoteViews.
     * @param dateManager The date manager.
     */
    private fun updateDrawables(context: Context?, views: RemoteViews, dateManager: TodayWidgetDateManager) {
        // We set the drawables (according to the current API).
        views.setImageViewResource(R.id.widget_today_refresh, R.drawable.widget_today_refresh_drawable)
        views.setImageViewResource(R.id.widget_today_back, R.drawable.widget_today_back_drawable)
        views.setImageViewResource(R.id.widget_today_next, R.drawable.widget_today_next_drawable)
        // If there is no previous day, we "disable" the previous button.
        if (dateManager.relativeDay <= 0) {
            views.setInt(R.id.widget_today_back, "setColorFilter", ContextCompat.getColor(context!!, R.color.color_widget_today_white_disabled))
        } else {
            views.setInt(R.id.widget_today_back, "setColorFilter", ContextCompat.getColor(context!!, R.color.color_widget_today_white))
        }
    }

    /**
     * Update widgets' title.
     *
     * @param context The context.
     * @param views Widgets' RemoteViews.
     * @param dateManager The date manager.
     */
    private fun updateTitle(context: Context, views: RemoteViews, dateManager: TodayWidgetDateManager) {
        // If it's today, let's show it !
        if (dateManager.relativeDay == 0) {
            views.setTextViewText(R.id.widget_today_title, context.getString(R.string.widget_today_title))
            return
        }
        // Otherwise we show the date.
        val date: Date = TodayWidgetDateManager.instance.absoluteDay.toDate()
        views.setTextViewText(R.id.widget_today_title, SimpleDateFormat("E", Locale.getDefault()).format(date).toUpperCase() + " " + DateFormat.getDateFormat(context).format(date))
    }

    /**
     * Update widgets' message.
     *
     * @param context The context.
     * @param views Widgets' RemoteViews.
     */
    private fun updateMessage(context: Context?, views: RemoteViews) {
        val intent = Intent(context, TodayWidgetService::class.java)
        views.setRemoteAdapter(R.id.widget_today_content, intent)
    }

    /**
     * Attaches MainActivity intents to this widget.
     *
     * @param context A context.
     * @param views Widgets' RemoteViews.
     * @param dateManager The date manager.
     */
    private fun registerIntents(context: Context?, views: RemoteViews, dateManager: TodayWidgetDateManager) {
        val now: LocalDate = dateManager.absoluteDay
        // We create the intent that allows to go to the current date.
        val currentFragment = Intent(context, MainActivity::class.java)
        currentFragment.putExtra(MainActivity.INTENT_DATE, now.toString("yyyy-MM-dd"))
        views.setOnClickPendingIntent(R.id.widget_today_title, PendingIntent.getActivity(context, 0, currentFragment, PendingIntent.FLAG_UPDATE_CURRENT))
        // The refresh intent.
        val refresh = currentFragment.clone() as Intent
        refresh.putExtra(MainActivity.INTENT_REFRESH_TIMETABLE, true)
        views.setOnClickPendingIntent(R.id.widget_today_refresh, PendingIntent.getActivity(context, 0, refresh, PendingIntent.FLAG_UPDATE_CURRENT))
        // The next button intent.
        val next = Intent(context, this.javaClass)
        next.putExtra(INTENT_REFRESH_WIDGETS, true)
        next.putExtra(INTENT_RELATIVE_DAY, getNextRelativeDays(dateManager))
        views.setOnClickPendingIntent(R.id.widget_today_next, PendingIntent.getBroadcast(context, BACK_REQUEST, next, PendingIntent.FLAG_UPDATE_CURRENT))
        // And the previous button intent (enabled if it's not today).
        if (dateManager.relativeDay > 0) {
            val back = next.clone() as Intent
            back.putExtra(INTENT_RELATIVE_DAY, getBackRelativeDays(dateManager))
            views.setOnClickPendingIntent(R.id.widget_today_back, PendingIntent.getBroadcast(context, NEXT_REQUEST, back, PendingIntent.FLAG_UPDATE_CURRENT))
        } else {
            views.setOnClickPendingIntent(R.id.widget_today_back, null)
        }
    }

    private fun getNextRelativeDays(dateManager: TodayWidgetDateManager): Int {
        /*val now: LocalDate = dateManager.absoluteDay*/
        return dateManager.relativeDay + 1 /*+ (if (now.dayOfWeek == DateTimeConstants.FRIDAY) 2 else 0)*/
    }

    private fun getBackRelativeDays(dateManager: TodayWidgetDateManager): Int {
        /*val now: LocalDate = LocalDate.now()
        val absoluteDay: LocalDate = dateManager.absoluteDay
        if(now.dayOfWeek().get() == DateTimeConstants.SUNDAY && dateManager.relativeDay == 1) {
            return dateManager.relativeDay - 1
        }

        if(now.dayOfWeek().get() == DateTimeConstants.SATURDAY && dateManager.relativeDay == 2) {
            return dateManager.relativeDay - 1
        }*/

        return dateManager.relativeDay - 1 /*- (if (absoluteDay.dayOfWeek == DateTimeConstants.MONDAY) 2 else 0)*/
    }
}
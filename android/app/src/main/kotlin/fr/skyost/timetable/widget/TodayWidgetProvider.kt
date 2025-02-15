package fr.skyost.timetable.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.text.format.DateFormat
import android.widget.RemoteViews
import androidx.core.content.ContextCompat
import fr.skyost.timetable.Lesson
import fr.skyost.timetable.MainActivity
import fr.skyost.timetable.R
import java.text.SimpleDateFormat
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import java.util.Locale

/**
 * The today's widget provider.
 */
class TodayWidgetProvider : AppWidgetProvider() {
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
        const val INTENT_REFRESH_WIDGETS = "todayWidget://refreshWidgets"

        /**
         * The relative day intent key.
         */
        const val INTENT_RELATIVE_DAY = "todayWidget://relativeDay"

        /**
         * Returns PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT if supported.
         *
         * @return PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT if supported.
         */
        val FLAG_IMMUTABLE_OR_UPDATE_CURRENT = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        // If we have to refresh the widgets, then let's do it !
        if (intent.hasExtra(INTENT_REFRESH_WIDGETS)) {
            val manager = AppWidgetManager.getInstance(context)
            this.onUpdate(
                context,
                manager,
                if (intent.hasExtra(AppWidgetManager.EXTRA_APPWIDGET_ID)) intArrayOf(
                    intent.getIntExtra(
                        AppWidgetManager.EXTRA_APPWIDGET_ID,
                        AppWidgetManager.INVALID_APPWIDGET_ID
                    )
                ) else manager.getAppWidgetIds(
                    ComponentName(context, this.javaClass)
                ),
                intent.getIntExtra(INTENT_RELATIVE_DAY, 0)
            )
        }
        super.onReceive(context, intent)
    }

    private fun onUpdate(
        context: Context,
        manager: AppWidgetManager,
        ids: IntArray,
        relativeDay: Int
    ) {
        // We change the relative day.
        val dateManager: TodayWidgetDateManager = TodayWidgetDateManager.instance
        dateManager.relativeDay = relativeDay
        // We load the lesson list.
        val lessonList = Lesson.readList(context, TodayWidgetDateManager.instance.absoluteDay)
        // We update everything.
        val views = RemoteViews(context.packageName, R.layout.today_widget)
        updateDrawables(context, views, dateManager)
        updateTitle(context, views, dateManager)
        updateMessage(context, views, lessonList)
        registerIntents(context, views, dateManager)
        // We notify the update.
        for (id in ids) {
            manager.notifyAppWidgetViewDataChanged(id, R.id.today_widget_content)
            manager.updateAppWidget(id, views)
        }
        // And we schedule the next update.
        TodayWidgetUpdateScheduler.schedule(context, if (TodayWidgetDateManager.instance.relativeDay == 0) lessonList else null)
    }

    /**
     * Updates the drawables.
     *
     * @param context The context.
     * @param views Widgets' RemoteViews.
     * @param dateManager The date manager.
     */
    private fun updateDrawables(
        context: Context?,
        views: RemoteViews,
        dateManager: TodayWidgetDateManager
    ) {
        // We set the drawables (according to the current API).
        views.setImageViewResource(R.id.today_widget_refresh, R.drawable.today_widget_refresh)
        views.setImageViewResource(R.id.today_widget_back, R.drawable.today_widget_back)
        views.setImageViewResource(R.id.today_widget_next, R.drawable.today_widget_next)
        // If there is no previous day, we "disable" the previous button.
        if (dateManager.relativeDay <= 0) {
            views.setInt(
                R.id.today_widget_back,
                "setColorFilter",
                ContextCompat.getColor(context!!, R.color.color_today_widget_white_disabled)
            )
        } else {
            views.setInt(
                R.id.today_widget_back,
                "setColorFilter",
                ContextCompat.getColor(context!!, R.color.color_today_widget_white)
            )
        }
    }

    /**
     * Update widgets' title.
     *
     * @param context The context.
     * @param views Widgets' RemoteViews.
     * @param dateManager The date manager.
     */
    private fun updateTitle(
        context: Context,
        views: RemoteViews,
        dateManager: TodayWidgetDateManager
    ) {
        // If it's today, let's show it !
        if (dateManager.relativeDay == 0) {
            views.setTextViewText(
                R.id.today_widget_title,
                context.getString(R.string.today_widget_title)
            )
            return
        }
        // Otherwise we show the date.
        val date: LocalDate = TodayWidgetDateManager.instance.absoluteDay
        views.setTextViewText(
            R.id.today_widget_title,
            SimpleDateFormat("E", Locale.getDefault()).format(date)
                .uppercase() + " " + DateFormat.getDateFormat(context).format(date)
        )
    }

    /**
     * Update widgets' message.
     *
     * @param context The context.
     * @param views Widgets' RemoteViews.
     * @param lessons The lesson list.
     */
    private fun updateMessage(context: Context, views: RemoteViews, lessons: List<Lesson>) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val builder = RemoteViews.RemoteCollectionItems.Builder()
            val htmlLessons = TodayWidgetViewsFactory.todayLessonListToHtml(context, lessons)
            for (i in 0 .. htmlLessons.size) {
                builder.addItem(i.toLong(), TodayWidgetViewsFactory.htmlLessonToRemoteView(context, htmlLessons[i]))
            }
            views.setRemoteAdapter(R.id.today_widget_content, builder.build())
        } else {
            val intent = Intent(context, TodayWidgetService::class.java)
            views.setRemoteAdapter(R.id.today_widget_content, intent)
        }
    }

    /**
     * Attaches MainActivity intents to this widget.
     *
     * @param context A context.
     * @param views Widgets' RemoteViews.
     * @param dateManager The date manager.
     */
    private fun registerIntents(
        context: Context?,
        views: RemoteViews,
        dateManager: TodayWidgetDateManager
    ) {
        val now: LocalDate = dateManager.absoluteDay
        // We create the intent that allows to go to the current date.
        val currentFragment = Intent(context, MainActivity::class.java)
        currentFragment.putExtra(
            MainActivity.INTENT_DATE,
            now.format(DateTimeFormatter.ISO_LOCAL_DATE)
        )
        views.setOnClickPendingIntent(
            R.id.today_widget_title,
            PendingIntent.getActivity(context, 0, currentFragment, FLAG_IMMUTABLE_OR_UPDATE_CURRENT)
        )
        // The refresh intent.
        val refresh = currentFragment.clone() as Intent
        refresh.putExtra(MainActivity.INTENT_REFRESH_TIMETABLE, true)
        views.setOnClickPendingIntent(
            R.id.today_widget_refresh,
            PendingIntent.getActivity(context, 0, refresh, FLAG_IMMUTABLE_OR_UPDATE_CURRENT)
        )
        // The next button intent.
        val next = Intent(context, this.javaClass)
        next.putExtra(INTENT_REFRESH_WIDGETS, true)
        next.putExtra(INTENT_RELATIVE_DAY, getNextRelativeDays(dateManager))
        views.setOnClickPendingIntent(
            R.id.today_widget_next,
            PendingIntent.getBroadcast(
                context,
                BACK_REQUEST,
                next,
                FLAG_IMMUTABLE_OR_UPDATE_CURRENT
            )
        )
        // And the previous button intent (enabled if it's not today).
        if (dateManager.relativeDay > 0) {
            val back = next.clone() as Intent
            back.putExtra(INTENT_RELATIVE_DAY, getBackRelativeDays(dateManager))
            views.setOnClickPendingIntent(
                R.id.today_widget_back,
                PendingIntent.getBroadcast(
                    context,
                    NEXT_REQUEST,
                    back,
                    FLAG_IMMUTABLE_OR_UPDATE_CURRENT
                )
            )
        } else {
            views.setOnClickPendingIntent(R.id.today_widget_back, null)
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
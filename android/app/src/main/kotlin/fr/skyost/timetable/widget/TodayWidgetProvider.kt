package fr.skyost.timetable.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.widget.RemoteViews
import androidx.core.content.ContextCompat
import fr.skyost.timetable.Lesson
import fr.skyost.timetable.MainActivity
import fr.skyost.timetable.R
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import java.time.format.FormatStyle
import java.util.Locale

/**
 * The today's widget provider.
 */
class TodayWidgetProvider : AppWidgetProvider() {
    companion object {
        /**
         * The back request.
         */
        const val BACK_REQUEST = 4000

        /**
         * The next request.
         */
        const val NEXT_REQUEST = 5000

        /**
         * A refresh request.
         */
        const val REFRESH_REQUEST = 6000

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
            val ids = if (intent.hasExtra(AppWidgetManager.EXTRA_APPWIDGET_ID)) intArrayOf(
                intent.getIntExtra(
                    AppWidgetManager.EXTRA_APPWIDGET_ID,
                    AppWidgetManager.INVALID_APPWIDGET_ID
                )
            ) else manager.getAppWidgetIds(ComponentName(context, this.javaClass))
            for (id in ids) {
                if (intent.hasExtra(INTENT_RELATIVE_DAY)) {
                    val day = intent.getIntExtra(INTENT_RELATIVE_DAY, 0)
                    TodayWidgetDateManager.changeRelativeDay(id, day)
                }
                updateWidget(context, manager, id)
            }
        }
        super.onReceive(context, intent)
    }

    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        for (id in ids) {
            updateWidget(context, manager, id)
        }
    }

    private fun updateWidget(context: Context, manager: AppWidgetManager, id: Int) {
        // We change the relative day.
        TodayWidgetDateManager.getRelativeDay(id)
        // We load the lesson list.
        val lessonList = Lesson.readList(context, TodayWidgetDateManager.resolveAbsoluteDay(id))
        // We update everything.
        val views = RemoteViews(context.packageName, R.layout.today_widget)
        updateDrawables(context, views, id)
        updateTitle(context, views, id)
        updateMessage(context, views, id, lessonList)
        registerIntents(context, views, id)
        // We notify the update.
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
            manager.notifyAppWidgetViewDataChanged(id, R.id.today_widget_content)
        }
        manager.updateAppWidget(id, views)
        // And we schedule the next update.
        TodayWidgetUpdateScheduler.schedule(context, id, lessonList)
    }

    /**
     * Updates the drawables.
     *
     * @param context The context.
     * @param views Widgets' RemoteViews.
     * @param id The widget id.
     */
    private fun updateDrawables(
        context: Context?,
        views: RemoteViews,
        id: Int
    ) {
        // We set the drawables (according to the current API).
        views.setImageViewResource(R.id.today_widget_refresh, R.drawable.today_widget_refresh)
        views.setImageViewResource(R.id.today_widget_back, R.drawable.today_widget_back)
        views.setImageViewResource(R.id.today_widget_next, R.drawable.today_widget_next)
        // If there is no previous day, we "disable" the previous button.
        if (TodayWidgetDateManager.getRelativeDay(id) <= 0) {
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
     * @param id The widget id.
     */
    private fun updateTitle(
        context: Context,
        views: RemoteViews,
        id: Int
    ) {
        // If it's today, let's show it !
        if (TodayWidgetDateManager.getRelativeDay(id) == 0) {
            views.setTextViewText(
                R.id.today_widget_title,
                context.getString(R.string.today_widget_title)
            )
            return
        }
        // Otherwise we show the date.
        val date: LocalDate = TodayWidgetDateManager.resolveAbsoluteDay(id)
        views.setTextViewText(
            R.id.today_widget_title,
            date.format(DateTimeFormatter.ofPattern("E", Locale.getDefault()))
                .uppercase() + " " + date.format(DateTimeFormatter.ofLocalizedDate(FormatStyle.SHORT))
        )
    }

    /**
     * Update widgets' message.
     *
     * @param context The context.
     * @param views Widgets' RemoteViews.
     * @param id The widget id.
     * @param lessons The lesson list.
     */
    private fun updateMessage(
        context: Context,
        views: RemoteViews,
        id: Int,
        lessons: List<Lesson>
    ) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val builder = RemoteViews.RemoteCollectionItems.Builder()
            val htmlLessons = TodayWidgetViewsFactory.todayLessonListToHtml(context, lessons)
            for (i in htmlLessons.indices) {
                builder.addItem(
                    i.toLong(),
                    TodayWidgetViewsFactory.htmlLessonToRemoteView(context, htmlLessons[i])
                )
            }
            views.setRemoteAdapter(R.id.today_widget_content, builder.build())
        } else {
            val intent = Intent(context, TodayWidgetService::class.java)
            intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, id)
            views.setRemoteAdapter(R.id.today_widget_content, intent)
        }
    }

    /**
     * Attaches MainActivity intents to this widget.
     *
     * @param context A context.
     * @param views Widgets' RemoteViews.
     * @param id The widget id.
     */
    private fun registerIntents(
        context: Context?,
        views: RemoteViews,
        id: Int
    ) {
        val day = TodayWidgetDateManager.getRelativeDay(id)
        val now: LocalDate = TodayWidgetDateManager.resolveAbsoluteDay(id)
        // We create the intent that allows to go to the current date.
        val currentFragment = Intent(context, MainActivity::class.java)
        currentFragment.putExtra(
            MainActivity.INTENT_DATE,
            now.format(DateTimeFormatter.ISO_LOCAL_DATE)
        )
        views.setOnClickPendingIntent(
            R.id.today_widget_title,
            PendingIntent.getActivity(context, id + 1, currentFragment, FLAG_IMMUTABLE_OR_UPDATE_CURRENT)
        )
        // The refresh intent.
        val refresh = currentFragment.clone() as Intent
        refresh.putExtra(MainActivity.INTENT_REFRESH_TIMETABLE, true)
        views.setOnClickPendingIntent(
            R.id.today_widget_refresh,
            PendingIntent.getActivity(context, id + 2, refresh, FLAG_IMMUTABLE_OR_UPDATE_CURRENT)
        )
        // The next button intent.
        val next = Intent(context, this.javaClass)
        next.putExtra(INTENT_REFRESH_WIDGETS, true)
        next.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, id)
        next.putExtra(INTENT_RELATIVE_DAY, day + 1)
        views.setOnClickPendingIntent(
            R.id.today_widget_next,
            PendingIntent.getBroadcast(
                context,
                BACK_REQUEST + id + 3,
                next,
                FLAG_IMMUTABLE_OR_UPDATE_CURRENT
            )
        )
        // And the previous button intent (enabled if it's not today).
        if (day > 0) {
            val back = next.clone() as Intent
            back.putExtra(INTENT_RELATIVE_DAY, day - 1)
            views.setOnClickPendingIntent(
                R.id.today_widget_back,
                PendingIntent.getBroadcast(
                    context,
                    NEXT_REQUEST + id + 4,
                    back,
                    FLAG_IMMUTABLE_OR_UPDATE_CURRENT
                )
            )
        } else {
            views.setOnClickPendingIntent(R.id.today_widget_back, null)
        }
    }
}
package fr.skyost.timetable.widget

import android.appwidget.AppWidgetManager
import android.content.Intent
import android.widget.RemoteViewsService

/**
 * The today's widget service.
 */
class TodayWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        // We create the corresponding RemoteViews factory.
        val widgetId = intent.getIntExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID)
        return TodayWidgetViewsFactory(applicationContext, widgetId)
    }
}

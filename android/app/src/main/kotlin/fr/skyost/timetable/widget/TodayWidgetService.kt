package fr.skyost.timetable.widget

import android.content.Intent
import android.widget.RemoteViewsService

/**
 * The today's widget service.
 */
class TodayWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        // We create the corresponding RemoteViews factory.
        return TodayWidgetViewsFactory(applicationContext)
    }
}

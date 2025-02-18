package fr.skyost.timetable.receiver

import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import fr.skyost.timetable.widget.TodayWidgetProvider

/**
 * The BroadcastReceiver that allows to refresh the widget, ...
 */
class NeedUpdateReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        // Refreshes the widget.
        val updateIntent = Intent(context, TodayWidgetProvider::class.java)
        updateIntent.action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
        updateIntent.putExtra(TodayWidgetProvider.INTENT_REFRESH_WIDGETS, true)
        context.sendBroadcast(updateIntent)
    }
}

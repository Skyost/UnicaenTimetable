package fr.skyost.timetable.receiver

import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.AsyncTask
import fr.skyost.timetable.ringer.LessonModeManager
import fr.skyost.timetable.widget.TodayWidgetReceiver

/**
 * The BroadcastReceiver that allows to refresh the widget, lesson mode, ...
 */
class NeedUpdateReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        // Refreshes the widget.
        val updateIntent = Intent(context, TodayWidgetReceiver::class.java)
        updateIntent.action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
        updateIntent.putExtra(TodayWidgetReceiver.INTENT_REFRESH_WIDGETS, true)
        context.sendBroadcast(updateIntent)
        // And toggles the lesson mode according to the update.

        if (!LessonModeManager.isEnabled(context)) {
            return
        }
        AsyncTask.execute {
            if (LessonModeManager.inLesson(context)) {
                LessonModeManager.enable(context)
            } else {
                LessonModeManager.disable(context)
            }
            LessonModeManager.schedule(context)
        }
    }
}
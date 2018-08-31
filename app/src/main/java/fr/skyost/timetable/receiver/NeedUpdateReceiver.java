package fr.skyost.timetable.receiver;

import android.appwidget.AppWidgetManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.AsyncTask;

import fr.skyost.timetable.lesson.ringer.LessonModeManager;
import fr.skyost.timetable.widget.TodayWidgetReceiver;

/**
 * The BroadcastReceiver that allows to refresh the widget, lesson mode, ...
 */

public class NeedUpdateReceiver extends BroadcastReceiver {

	@Override
	public void onReceive(final Context context, final Intent intent) {
		// Refreshes the widget.
		final Intent updateIntent = new Intent(context, TodayWidgetReceiver.class);
		updateIntent.setAction(AppWidgetManager.ACTION_APPWIDGET_UPDATE);
		updateIntent.putExtra(TodayWidgetReceiver.INTENT_REFRESH_WIDGETS, true);
		context.sendBroadcast(updateIntent);

		// And toggles the lesson mode according to the update.
		if(!LessonModeManager.isEnabled(context)) {
			return;
		}

		AsyncTask.execute(() -> {
			if(LessonModeManager.inLesson(context)) {
				LessonModeManager.enable(context);
			}
			else {
				LessonModeManager.disable(context);
			}
			LessonModeManager.schedule(context);
		});
	}

}
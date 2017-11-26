package fr.skyost.timetable.receivers;

import android.appwidget.AppWidgetManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

public class NeedUpdateWidgetReceiver extends BroadcastReceiver {

	@Override
	public final void onReceive(final Context context, final Intent intent) {
		final Intent updateIntent = new Intent(context, TodayWidgetReceiver.class);
		updateIntent.setAction(AppWidgetManager.ACTION_APPWIDGET_UPDATE);
		updateIntent.putExtra(TodayWidgetReceiver.INTENT_REFRESH_WIDGETS, true);
		context.sendBroadcast(updateIntent);
	}

}
package fr.skyost.timetable.receivers;

import android.appwidget.AppWidgetManager;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.util.Log;
import android.widget.RemoteViews;

import fr.skyost.timetable.R;

public class TimeChangeReceiver extends BroadcastReceiver {

	@Override
	public final void onReceive(final Context context, final Intent intent) {
		final RemoteViews remoteViews = new RemoteViews(context.getPackageName(), R.layout.widget_today_layout);
		final AppWidgetManager manager = AppWidgetManager.getInstance(context);
		for(final int id : manager.getAppWidgetIds(new ComponentName(context, TodayWidgetReceiver.class))) {
			manager.updateAppWidget(id, remoteViews);
		}
	}

}

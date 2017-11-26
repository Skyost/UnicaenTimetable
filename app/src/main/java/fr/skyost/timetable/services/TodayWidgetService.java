package fr.skyost.timetable.services;

import android.content.Intent;
import android.widget.RemoteViewsService;

import fr.skyost.timetable.receivers.TodayWidgetReceiver;

public class TodayWidgetService extends RemoteViewsService {

	@Override
	public final RemoteViewsFactory onGetViewFactory(final Intent intent) {
		return new TodayWidgetViewsFactory(this);
	}

}
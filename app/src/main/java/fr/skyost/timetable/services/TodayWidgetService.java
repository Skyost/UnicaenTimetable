package fr.skyost.timetable.services;

import android.content.Intent;
import android.widget.RemoteViewsService;

import fr.skyost.timetable.receivers.TodayWidgetReceiver;

public class TodayWidgetService extends RemoteViewsService {

	@Override
	public RemoteViewsFactory onGetViewFactory(Intent intent) {
		return(new TodayWidgetViewsFactory(this.getPackageName(), intent.getStringArrayExtra(TodayWidgetReceiver.INTENT_ITEMS)));
	}

}
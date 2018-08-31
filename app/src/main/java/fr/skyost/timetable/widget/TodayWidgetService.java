package fr.skyost.timetable.widget;

import android.content.Intent;
import android.widget.RemoteViewsService;

import fr.skyost.timetable.application.TimetableApplication;

/**
 * The today's widget service.
 */

public class TodayWidgetService extends RemoteViewsService {

	@Override
	public RemoteViewsFactory onGetViewFactory(final Intent intent) {
		// We create the corresponding RemoteViews factory.
		final TimetableApplication application = (TimetableApplication)getApplication();
		return new TodayWidgetViewsFactory(getApplicationContext(), application.getDatabase());
	}

}
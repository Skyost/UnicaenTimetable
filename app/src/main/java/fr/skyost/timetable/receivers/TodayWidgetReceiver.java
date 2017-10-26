package fr.skyost.timetable.receivers;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.text.Html;
import android.widget.RemoteViews;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import fr.skyost.timetable.R;
import fr.skyost.timetable.Timetable;
import fr.skyost.timetable.Timetable.Lesson;
import fr.skyost.timetable.activities.MainActivity;
import fr.skyost.timetable.utils.Utils;

public class TodayWidgetReceiver extends AppWidgetProvider {

	public static final int CURRENT_DAY_REQUEST = 100;
	public static final int REFRESH_REQUEST = 200;
	public static final int SCHEDULE_REQUEST = 300;

	@Override
	public final void onReceive(final Context context, final Intent intent) {
		if(intent.getAction().equals(AppWidgetManager.ACTION_APPWIDGET_UPDATE)) {
			final AppWidgetManager manager = AppWidgetManager.getInstance(context);
			this.onUpdate(context, manager, manager.getAppWidgetIds(new ComponentName(context, TodayWidgetReceiver.class)));
		}

		super.onReceive(context, intent);
	}

	@Override
	public final void onUpdate(final Context context, final AppWidgetManager manager, final int[] ids) {
		final RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.widget_today_layout);

		Lesson nextLesson = null;
		try {
			final StringBuilder content = new StringBuilder();
			final List<Lesson> lessons = new ArrayList<Lesson>(Timetable.loadFromDisk(context).getLessonsOfToday());
			if(lessons.size() == 0) {
				content.append("<i>" + context.getResources().getString(R.string.widget_today_nothing) + "</i>");
			}
			else {
				Collections.sort(lessons, new Comparator<Lesson>() {

					@Override
					public final int compare(final Lesson lesson1, final Lesson lesson2) {
						return lesson1.getStart().compareTo(lesson2.getStart());
					}

				});

				final Calendar now = Calendar.getInstance();
				for(final Lesson lesson : lessons) {
					if(!now.after(lesson.getEnd())) {
						content.append("<b>" + lesson.getName() + "</b> :<br/>");
						content.append(Utils.addZeroIfNeeded(lesson.getStart().get(Calendar.HOUR_OF_DAY)) + ":" + Utils.addZeroIfNeeded(lesson.getStart().get(Calendar.MINUTE)) + " - ");
						content.append(Utils.addZeroIfNeeded(lesson.getEnd().get(Calendar.HOUR_OF_DAY)) + ":" + Utils.addZeroIfNeeded(lesson.getEnd().get(Calendar.MINUTE)) + "&emsp;");
						content.append("<i>" + lesson.getLocation() + "</i><br/><br/>");

						if(nextLesson == null || lesson.getEnd().getTimeInMillis() < nextLesson.getEnd().getTimeInMillis()) {
							nextLesson = lesson;
						}
					}
				}

				if(nextLesson == null) {
					content.append("<i>" + context.getResources().getString(R.string.widget_today_nothingremaining) + "</i>");
				}
				else {
					content.setLength(content.length() - 10);
				}

				updateMessage(views, content.toString());
			}
		}
		catch(final Exception ex) {
			ex.printStackTrace();
			updateMessage(views, "<i>" + context.getResources().getString(R.string.widget_today_error) + "</i>");
		}

		registerIntents(context, views);
		for(final int id : ids) {
			manager.updateAppWidget(id, views);
		}
		scheduleNextUpdate(context, nextLesson);
	}

	/**
	 * Update widgets' message.
	 *
	 * @param views Widgets' RemoteViews.
	 * @param content The message.
	 */

	public final void updateMessage(final RemoteViews views, final String content) {
		if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
			views.setTextViewText(R.id.widget_today_content, Html.fromHtml(content.toString(), Html.FROM_HTML_MODE_COMPACT));
		}
		else {
			views.setTextViewText(R.id.widget_today_content, Html.fromHtml(content.toString()));
		}
	}

	/**
	 * Attaches MainActivity intents to this widget.
	 *
	 * @param context A context.
	 * @param views Widgets' RemoteViews.
	 */

	public final void registerIntents(final Context context, final RemoteViews views) {
		int day = Calendar.getInstance().get(Calendar.DAY_OF_WEEK);
		if(day == Calendar.SATURDAY || day == Calendar.SUNDAY) {
			day = Calendar.MONDAY;
		}
		final Intent currentDay = new Intent(context, MainActivity.class);
		currentDay.putExtra(MainActivity.INTENT_CURRENT_FRAGMENT, day);
		views.setOnClickPendingIntent(R.id.widget_today_layout, PendingIntent.getActivity(context, CURRENT_DAY_REQUEST, currentDay, PendingIntent.FLAG_UPDATE_CURRENT));

		final Intent refresh = (Intent)currentDay.clone();
		refresh.putExtra(MainActivity.INTENT_REFRESH_TIMETABLE, true);
		views.setOnClickPendingIntent(R.id.widget_today_refresh, PendingIntent.getActivity(context, REFRESH_REQUEST, refresh, PendingIntent.FLAG_UPDATE_CURRENT));
	}

	/**
	 * Schedules widgets next update.
	 *
	 * @param context A context.
	 * @param lesson The next lesson.
	 */

	private static final void scheduleNextUpdate(final Context context, final Lesson lesson) {
		final AlarmManager manager = (AlarmManager)context.getSystemService(Context.ALARM_SERVICE);

		final Intent intent = new Intent(context, TodayWidgetReceiver.class);
		intent.setAction(AppWidgetManager.ACTION_APPWIDGET_UPDATE);
		final PendingIntent pending = PendingIntent.getBroadcast(context, SCHEDULE_REQUEST, intent, PendingIntent.FLAG_UPDATE_CURRENT);

		final Calendar calendar;
		if(lesson == null) {
			calendar = Calendar.getInstance();
			calendar.set(Calendar.HOUR_OF_DAY, 0);
			calendar.set(Calendar.MINUTE, 0);
			calendar.set(Calendar.SECOND, 0);
			calendar.set(Calendar.MILLISECOND, 0);
			calendar.add(Calendar.DAY_OF_YEAR, 1);
		}
		else {
			calendar = lesson.getEnd();
		}
		calendar.add(Calendar.SECOND, 1);

		if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
			manager.setExact(AlarmManager.RTC_WAKEUP, calendar.getTimeInMillis(), pending);
		}
		else {
			manager.set(AlarmManager.RTC_WAKEUP, calendar.getTimeInMillis(), pending);
		}
	}

}
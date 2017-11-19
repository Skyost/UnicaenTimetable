package fr.skyost.timetable.receivers;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.content.Intent;
import android.content.ComponentName;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Build;
import android.support.v7.content.res.AppCompatResources;
import android.widget.RemoteViews;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import fr.skyost.timetable.R;
import fr.skyost.timetable.Timetable;
import fr.skyost.timetable.activities.MainActivity;
import fr.skyost.timetable.services.TodayWidgetService;
import fr.skyost.timetable.utils.Utils;

public class TodayWidgetReceiver extends AppWidgetProvider {

	public static final int CURRENT_DAY_REQUEST = 100;
	public static final int REFRESH_REQUEST = 200;
	public static final int SCHEDULE_REQUEST = 300;

	public static final String INTENT_REFRESH_WIDGETS = "refresh-widgets";
	public static final String INTENT_ITEMS = "items";

	@Override
	public final void onReceive(final Context context, final Intent intent) {
		if(intent.hasExtra(INTENT_REFRESH_WIDGETS)) {
			final AppWidgetManager manager = AppWidgetManager.getInstance(context);
			this.onUpdate(
					context,
					manager,
					intent.hasExtra(AppWidgetManager.EXTRA_APPWIDGET_ID) ? new int[]{intent.getIntExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID)} : manager.getAppWidgetIds(new ComponentName(context, this.getClass()))
			);
		}

		super.onReceive(context, intent);
	}

	@Override
	public final void onUpdate(final Context context, final AppWidgetManager manager, final int[] ids) {
		final RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.widget_today_layout);
		final List<String> items = new ArrayList<String>();
		Timetable.Lesson nextLesson = null;

		try {
			final List<Timetable.Lesson> lessons = new ArrayList<Timetable.Lesson>(Timetable.loadFromDisk(context).getLessonsOfToday());
			if(lessons.size() == 0) {
				items.add("<i>" + context.getResources().getString(R.string.widget_today_nothing) + "</i>");
			}
			else {
				Collections.sort(lessons, new Comparator<Timetable.Lesson>() {

					@Override
					public final int compare(final Timetable.Lesson lesson1, final Timetable.Lesson lesson2) {
						return lesson1.getStart().compareTo(lesson2.getStart());
					}

				});

				final Calendar now = Calendar.getInstance();
				for(final Timetable.Lesson lesson : lessons) {
					if(!now.after(lesson.getEnd())) {
						items.add("<b>" + lesson.getName() + "</b> :<br/>" + Utils.addZeroIfNeeded(lesson.getStart().get(Calendar.HOUR_OF_DAY)) + ":" + Utils.addZeroIfNeeded(lesson.getStart().get(Calendar.MINUTE)) + " - " + Utils.addZeroIfNeeded(lesson.getEnd().get(Calendar.HOUR_OF_DAY)) + ":" + Utils.addZeroIfNeeded(lesson.getEnd().get(Calendar.MINUTE)) + "<br/>" + "<i>" + lesson.getLocation() + "</i>");

						if(nextLesson == null || lesson.getEnd().getTimeInMillis() < nextLesson.getEnd().getTimeInMillis()) {
							nextLesson = lesson;
						}
					}
				}

				if(nextLesson == null) {
					items.add("<i>" + context.getResources().getString(R.string.widget_today_nothingremaining) + "</i>");
				}
			}
		}
		catch(final Exception ex) {
			ex.printStackTrace();
			items.add("<i>" + context.getResources().getString(R.string.widget_today_error) + "</i>");
		}

		updateDrawables(views, context);
		updateMessage(context, views, items);
		registerIntents(context, views);
		for(final int id : ids) {
			manager.updateAppWidget(id, views);
		}
		scheduleNextUpdate(context, nextLesson);

		super.onUpdate(context, manager, ids);
	}

	/**
	 * Updates the drawables.
	 *
	 * @param views Widgets' RemoteViews.
	 * @param context The context.
	 */

	public final void updateDrawables(final RemoteViews views, final Context context) {
		if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
			views.setImageViewResource(R.id.widget_today_refresh, R.drawable.widget_today_refresh_drawable);
		}
		else {
			for(int[] drawableData : new int[][]{
					new int[]{R.drawable.widget_today_refresh_drawable, R.id.widget_today_refresh}
			}) {
				final Drawable drawable = AppCompatResources.getDrawable(context, drawableData[0]);
				final Bitmap bitmap = Bitmap.createBitmap(drawable.getIntrinsicWidth(), drawable.getIntrinsicHeight(), Bitmap.Config.ARGB_8888);
				Canvas canvas = new Canvas(bitmap);
				drawable.setBounds(0, 0, canvas.getWidth(), canvas.getHeight());
				drawable.draw(canvas);
				views.setImageViewBitmap(drawableData[1], bitmap);
			}
		}
	}

	/**
	 * Update widgets' message.
	 *
	 * @param context The context.
	 * @param views Widgets' RemoteViews.
	 * @param items The message (HTML formatted).
	 */

	public final void updateMessage(final Context context, final RemoteViews views, final List<String> items) {
		final Intent intent = new Intent(context, TodayWidgetService.class);

		intent.putExtra(INTENT_ITEMS, items.toArray(new String[items.size()]));
		intent.setData(Uri.parse(intent.toUri(Intent.URI_INTENT_SCHEME)));

		views.setRemoteAdapter(R.id.widget_today_content, intent);
	}

	/**
	 * Attaches MainActivity intents to this widget_today_layout.
	 *
	 * @param context A context.
	 * @param views Widgets' RemoteViews.
	 */

	public final void registerIntents(final Context context, final RemoteViews views) {
		int day = Calendar.getInstance().get(Calendar.DAY_OF_WEEK);
		if(day == Calendar.SATURDAY || day == Calendar.SUNDAY) {
			day = Calendar.MONDAY;
		}
		final Intent currentFragment = new Intent(context, MainActivity.class);
		currentFragment.putExtra(MainActivity.INTENT_CURRENT_FRAGMENT, day);
		views.setOnClickPendingIntent(R.id.widget_today_layout, PendingIntent.getActivity(context, CURRENT_DAY_REQUEST, currentFragment, PendingIntent.FLAG_UPDATE_CURRENT));

		final Intent refresh = (Intent)currentFragment.clone();
		refresh.putExtra(MainActivity.INTENT_REFRESH_TIMETABLE, true);
		views.setOnClickPendingIntent(R.id.widget_today_refresh, PendingIntent.getActivity(context, REFRESH_REQUEST, refresh, PendingIntent.FLAG_UPDATE_CURRENT));
	}

	/**
	 * Schedules widgets next update.
	 *
	 * @param context A context.
	 * @param lesson The next lesson.
	 */

	public final void scheduleNextUpdate(final Context context, final Timetable.Lesson lesson) {
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
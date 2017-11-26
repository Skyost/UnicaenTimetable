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

import java.util.Calendar;

import fr.skyost.timetable.R;
import fr.skyost.timetable.Timetable;
import fr.skyost.timetable.activities.MainActivity;
import fr.skyost.timetable.services.TodayWidgetService;

public class TodayWidgetReceiver extends AppWidgetProvider {

	public static final int CURRENT_DAY_REQUEST = 100;
	public static final int REFRESH_REQUEST = 200;
	public static final int SCHEDULE_REQUEST = 300;

	public static final String INTENT_REFRESH_WIDGETS = "refresh-widgets";

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
		Timetable.Lesson nextLesson = null;

		try {
			nextLesson = Timetable.loadFromDisk(context).getNextLesson();
		}
		catch(final Exception ex) {
			ex.printStackTrace();
		}

		updateDrawables(views, context);
		updateMessage(context, views);
		registerIntents(context, views);
		for(final int id : ids) {
			manager.notifyAppWidgetViewDataChanged(id, R.id.widget_today_content);
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
	 */

	public final void updateMessage(final Context context, final RemoteViews views) {
		final Intent intent = new Intent(context, TodayWidgetService.class);
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

		final Intent intent = new Intent(context, this.getClass());
		intent.setAction(AppWidgetManager.ACTION_APPWIDGET_UPDATE);
		intent.putExtra(INTENT_REFRESH_WIDGETS, true);
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
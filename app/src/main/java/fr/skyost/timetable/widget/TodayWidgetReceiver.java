package fr.skyost.timetable.widget;

import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.support.v4.content.ContextCompat;
import android.text.format.DateFormat;
import android.widget.RemoteViews;

import org.joda.time.DateTimeConstants;
import org.joda.time.LocalDate;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

import fr.skyost.timetable.R;
import fr.skyost.timetable.activity.MainActivity;
import fr.skyost.timetable.application.TimetableApplication;
import fr.skyost.timetable.lesson.database.LessonDao;
import fr.skyost.timetable.utils.Utils;

/**
 * The today's widget provider.
 */

public class TodayWidgetReceiver extends AppWidgetProvider {

	/**
	 * The back request.
	 */

	public static final int BACK_REQUEST = 400;

	/**
	 * The next request.
	 */

	public static final int NEXT_REQUEST = 500;

	/**
	 * The refresh widgets intent key.
	 */

	public static final String INTENT_REFRESH_WIDGETS = "refresh-widgets";

	/**
	 * The relative day intent key.
	 */

	public static final String INTENT_RELATIVE_DAY = "relative-day";

	@Override
	public void onReceive(final Context context, final Intent intent) {
		// If we have to refresh the widgets, then let's do it !
		if(intent.hasExtra(INTENT_REFRESH_WIDGETS)) {
			final AppWidgetManager manager = AppWidgetManager.getInstance(context);
			this.onUpdate(
					context,
					manager,
					intent.hasExtra(AppWidgetManager.EXTRA_APPWIDGET_ID) ? new int[]{intent.getIntExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID)} : manager.getAppWidgetIds(new ComponentName(context, this.getClass())),
					intent.getIntExtra(INTENT_RELATIVE_DAY, 0)
			);
		}

		super.onReceive(context, intent);
	}

	@Override
	public void onUpdate(final Context context, final AppWidgetManager manager, final int[] ids) {
		onUpdate(context, manager, ids, 0);
	}

	public void onUpdate(final Context context, final AppWidgetManager manager, final int[] ids, final int relativeDay) {
		// We change the relative day.
		final TodayWidgetDateManager dateManager = TodayWidgetDateManager.getInstance();
		dateManager.setRelativeDay(relativeDay);

		// We update everything.
		final RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.widget_today_layout);
		updateDrawables(context, views, dateManager);
		updateTitle(context, views, dateManager);
		updateMessage(context, views);
		registerIntents(context, views, dateManager);

		// We notify the update.
		for(final int id : ids) {
			manager.notifyAppWidgetViewDataChanged(id, R.id.widget_today_content);
			manager.updateAppWidget(id, views);
		}

		// And we schedule the next update.
		final LessonDao dao = ((TimetableApplication)context.getApplicationContext()).getDatabase().getLessonDao();
		new TodayWidgetUpdateScheduler(context).execute(dao);
	}

	/**
	 * Updates the drawables.
	 *
	 * @param context The context.
	 * @param views Widgets' RemoteViews.
	 * @param dateManager The date manager.
	 */

	public void updateDrawables(final Context context, final RemoteViews views, final TodayWidgetDateManager dateManager) {
		// We set the drawables (according to the current API).
		if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
			views.setImageViewResource(R.id.widget_today_refresh, R.drawable.widget_today_refresh_drawable);
			views.setImageViewResource(R.id.widget_today_back, R.drawable.widget_today_back_drawable);
			views.setImageViewResource(R.id.widget_today_next, R.drawable.widget_today_next_drawable);
		}
		else {
			views.setImageViewBitmap(R.id.widget_today_refresh, Utils.drawableToBitmap(context, R.drawable.widget_today_refresh_drawable));
			views.setImageViewBitmap(R.id.widget_today_back, Utils.drawableToBitmap(context, R.drawable.widget_today_back_drawable));
			views.setImageViewBitmap(R.id.widget_today_next, Utils.drawableToBitmap(context, R.drawable.widget_today_next_drawable));
		}

		// If there is no previous day, we "disable" the previous button.
		if(dateManager.getRelativeDay() <= 0) {
			views.setInt(R.id.widget_today_back, "setColorFilter", ContextCompat.getColor(context, R.color.color_widget_today_white_disabled));
		}
		else {
			views.setInt(R.id.widget_today_back, "setColorFilter", ContextCompat.getColor(context, R.color.color_widget_today_white));
		}
	}

	/**
	 * Update widgets' title.
	 *
	 * @param context The context.
	 * @param views Widgets' RemoteViews.
	 * @param dateManager The date manager.
	 */

	public void updateTitle(final Context context, final RemoteViews views, final TodayWidgetDateManager dateManager) {
		// If it's today, let's show it !
		if(dateManager.getRelativeDay() == 0) {
			views.setTextViewText(R.id.widget_today_title, context.getString(R.string.widget_today_title));
			return;
		}

		// Otherwise we show the date.
		final Date date = TodayWidgetDateManager.getInstance().getAbsoluteDay().toDate();
		views.setTextViewText(R.id.widget_today_title, new SimpleDateFormat("E", Locale.getDefault()).format(date).toUpperCase() + " " + DateFormat.getDateFormat(context).format(date));
	}

	/**
	 * Update widgets' message.
	 *
	 * @param context The context.
	 * @param views Widgets' RemoteViews.
	 */

	public void updateMessage(final Context context, final RemoteViews views) {
		final Intent intent = new Intent(context, TodayWidgetService.class);
		views.setRemoteAdapter(R.id.widget_today_content, intent);
	}

	/**
	 * Attaches MainActivity intents to this widget.
	 *
	 * @param context A context.
	 * @param views Widgets' RemoteViews.
	 * @param dateManager The date manager.
	 */

	public void registerIntents(final Context context, final RemoteViews views, final TodayWidgetDateManager dateManager) {
		final LocalDate now = dateManager.getAbsoluteDay();

		// We create the intent that allows to go to the current date.
		final Intent currentFragment = new Intent(context, MainActivity.class);
		currentFragment.putExtra(MainActivity.INTENT_DATE, now.toString("yyyy-MM-dd"));
		views.setOnClickPendingIntent(R.id.widget_today_title, PendingIntent.getActivity(context, 0, currentFragment, PendingIntent.FLAG_UPDATE_CURRENT));

		// The refresh intent.
		final Intent refresh = (Intent)currentFragment.clone();
		refresh.putExtra(MainActivity.INTENT_REFRESH_TIMETABLE, true);
		views.setOnClickPendingIntent(R.id.widget_today_refresh, PendingIntent.getActivity(context, 0, refresh, PendingIntent.FLAG_UPDATE_CURRENT));

		// The next button intent.
		final Intent next = new Intent(context, this.getClass());
		next.putExtra(INTENT_REFRESH_WIDGETS, true);
		next.putExtra(INTENT_RELATIVE_DAY, dateManager.getRelativeDay() + 1 + (now.getDayOfWeek() == DateTimeConstants.FRIDAY ? 2 : 0));
		views.setOnClickPendingIntent(R.id.widget_today_next, PendingIntent.getBroadcast(context, BACK_REQUEST, next, PendingIntent.FLAG_UPDATE_CURRENT));

		// And the previous button intent (enabled if it's not today).
		if(dateManager.getRelativeDay() > 0) {
			final Intent back = (Intent)next.clone();
			back.putExtra(INTENT_RELATIVE_DAY, dateManager.getRelativeDay() - 1 - (now.getDayOfWeek() == DateTimeConstants.MONDAY ? 2 : 0));
			views.setOnClickPendingIntent(R.id.widget_today_back, PendingIntent.getBroadcast(context, NEXT_REQUEST, back, PendingIntent.FLAG_UPDATE_CURRENT));
		}
		else {
			views.setOnClickPendingIntent(R.id.widget_today_back, null);
		}
	}

}
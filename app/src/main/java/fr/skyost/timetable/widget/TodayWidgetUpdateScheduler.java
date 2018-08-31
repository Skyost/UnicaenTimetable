package fr.skyost.timetable.widget;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.content.Context;
import android.content.Intent;
import android.os.AsyncTask;

import org.joda.time.DateTime;

import java.util.List;
import java.util.concurrent.atomic.AtomicReference;

import fr.skyost.timetable.lesson.Lesson;
import fr.skyost.timetable.lesson.database.LessonDao;
import fr.skyost.timetable.utils.Utils;

/**
 * The AsyncTask that allows to schedule a widget update.
 */

public class TodayWidgetUpdateScheduler extends AsyncTask<LessonDao, Void, DateTime> {

	/**
	 * A context atomic reference.
	 */

	private final AtomicReference<Context> context;

	/**
	 * Creates a new today's widget update scheduler task.
	 *
	 * @param context The context.
	 */

	TodayWidgetUpdateScheduler(final Context context) {
		this.context = new AtomicReference<>(context);
	}

	@Override
	protected DateTime doInBackground(final LessonDao... daos) {
		// We get the DAO.
		final LessonDao dao = daos[0];

		// We get the remaining lessons and if possible, we return the end of the next one.
		final List<Lesson> remainingLessons = dao.getRemainingLessons();
		final DateTime date = remainingLessons.isEmpty() ? Utils.tomorrowMidnight() : remainingLessons.get(0).getEndDate();
		return date.getSecondOfMinute() == 0 ? date.withSecondOfMinute(1) : date;
	}

	@Override
	protected void onPostExecute(final DateTime date) {
		final Context context = this.context.get();
		if(context == null) {
			return;
		}

		// With the alarm manager, we schedule our update.
		final AlarmManager manager = (AlarmManager)context.getSystemService(Context.ALARM_SERVICE);
		if(manager == null) {
			return;
		}

		final Intent intent = new Intent(context, getClass());
		intent.setAction(AppWidgetManager.ACTION_APPWIDGET_UPDATE);
		intent.putExtra(TodayWidgetReceiver.INTENT_REFRESH_WIDGETS, true);

		manager.set(AlarmManager.RTC_WAKEUP, date.getMillis(), PendingIntent.getBroadcast(context, TodayWidgetReceiver.SCHEDULE_REQUEST, intent, PendingIntent.FLAG_UPDATE_CURRENT));
	}

	/**
	 * Returns the context reference.
	 *
	 * @return The context reference.
	 */

	public AtomicReference<Context> getContext() {
		return context;
	}

}
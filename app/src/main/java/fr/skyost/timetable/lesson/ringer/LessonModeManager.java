package fr.skyost.timetable.lesson.ringer;

import android.app.AlarmManager;
import android.app.IntentService;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.media.AudioManager;
import android.os.AsyncTask;
import android.os.Build;
import android.provider.Settings;

import org.joda.time.DateTime;
import org.joda.time.DateTimeConstants;
import org.joda.time.LocalDate;

import java.util.List;

import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;
import fr.skyost.timetable.R;
import fr.skyost.timetable.activity.MainActivity;
import fr.skyost.timetable.application.TimetableApplication;
import fr.skyost.timetable.lesson.Lesson;
import fr.skyost.timetable.utils.Utils;

/**
 * The manager that allows to manager the lesson mode.
 */

public class LessonModeManager extends BroadcastReceiver {

	/**
	 * The notification channel ID.
	 */

	public static final String NOTIFICATION_CHANNEL_ID = "timetable_ringer_channel";

	/**
	 * The notification tag.
	 */

	public static final String NOTIFICATION_TAG = "timetable_ringer";

	/**
	 * The mode notification ID.
	 */

	public static final int MODE_NOTIFICATION_ID = 1;

	/**
	 * The exception notification ID.
	 */

	public static final int EXCEPTION_NOTIFICATION_ID = 2;

	/**
	 * The ringer preference file.
	 */

	public static final String RINGER_FILE = "ringer";

	/**
	 * The ringer mode preference key.
	 */

	public static final String RINGER_MODE = "mode";

	@Override
	public void onReceive(final Context context, final Intent intent) {
		// If it's not enabled, we can exit right now.
		if(!LessonModeManager.isEnabled(context)) {
			return;
		}

		AsyncTask.execute(() -> {
			if(inLesson(context)) {
				enable(context);
			}
			else {
				disable(context);
			}

			schedule(context);
		});
	}

	/**
	 * Turns on lesson mode, even if disabled in the config.
	 *
	 * @param context The context.
	 */

	public static void enable(final Context context) {
		try {
			final SharedPreferences preferences = LessonModeManager.getSharedPreferences(context);
			final AudioManager manager = (AudioManager)context.getSystemService(Context.AUDIO_SERVICE);

			// If it's possible, we save the current ringer mode.
			if(manager != null && !preferences.contains(LessonModeManager.RINGER_MODE)) {
				final SharedPreferences.Editor editor = preferences.edit();
				final int mode =  manager.getRingerMode();
				manager.setRingerMode(LessonModeManager.getPreferenceMode(context));
				editor.putInt(LessonModeManager.RINGER_MODE, mode);
				editor.commit();
			}

			// And we display the notification.
			LessonModeManager.displayNotification(context);
		}
		catch(final SecurityException ex) {
			// If the user has disabled the application in its settings, this exception will be thrown.
			final String message = context.getString(R.string.notification_lessonsringermode_exception);
			final NotificationCompat.Builder builder = new NotificationCompat.Builder(context, NOTIFICATION_CHANNEL_ID)
					.setSmallIcon(R.drawable.notification_ringer_small_drawable)
					.setContentTitle(context.getString(R.string.notification_lessonsringermode_title))
					.setStyle(new NotificationCompat.BigTextStyle().bigText(message))
					.setContentText(message);

			if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
				final Intent intent = new Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS);
				builder.setContentIntent(PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT));
			}

			final NotificationManager manager = (NotificationManager)context.getSystemService(Context.NOTIFICATION_SERVICE);
			if(manager == null) {
				return;
			}

			// So we have to notify the user.
			manager.notify(NOTIFICATION_TAG, EXCEPTION_NOTIFICATION_ID, builder.build());
		}
	}

	/**
	 * Turns off lesson mode, even if disabled in the config.
	 *
	 * @param context The context.
	 */

	public static void disable(final Context context) {
		final SharedPreferences preferences = LessonModeManager.getSharedPreferences(context);
		final AudioManager manager = (AudioManager)context.getSystemService(Context.AUDIO_SERVICE);

		// We try to recover the ringer mode.
		if(manager != null && LessonModeManager.getPreferenceMode(context) == manager.getRingerMode()) {
			final int mode = preferences.getInt(LessonModeManager.RINGER_MODE, -1);
			preferences.edit().clear().commit(); // We need to clear them immediately as RingerModeStateChangeReceiver will be triggered.
			if(mode != -1) {
				manager.setRingerMode(mode);
			}
		}
		else {
			preferences.edit().clear().commit(); // Same here.
		}

		// And we close the notification.
		LessonModeManager.closeNotification(context);
	}

	/**
	 * Checks if the lesson mode is enabled according to the config.
	 *
	 * @param context The context
	 *
	 * @return Whether the lesson mode is enabled.
	 */

	public static boolean isEnabled(final Context context) {
		return !context.getSharedPreferences(MainActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE).getString(MainActivity.PREFERENCES_LESSONS_RINGER_MODE, "0").equals("0");
	}

	/**
	 * Schedules the next call of this receiver.
	 *
	 * @param context The context.
	 */

	public static void schedule(final Context context) {
		schedule(context, getScheduleTime(context));
	}

	/**
	 * Schedules the next call of this receiver.
	 *
	 * @param context The context.
	 * @param time The schedule time.
	 */

	public static void schedule(final Context context, long time) {
		final AlarmManager manager = (AlarmManager)context.getSystemService(Context.ALARM_SERVICE);
		if(manager == null) {
			return;
		}

		// Time = -1 when there is not lesson left today so we have to refresh it tomorrow.
		if(time == -1L) {
			time = Utils.tomorrowMidnight().getMillis();
		}

		// We schedule the pending intent.
		final PendingIntent pendingIntent = getPendingIntent(context);
		if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
			manager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, time, pendingIntent);
		}
		else if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
			manager.setExact(AlarmManager.RTC_WAKEUP, time, pendingIntent);
		}
		else {
			manager.set(AlarmManager.RTC_WAKEUP, time, pendingIntent);
		}
	}

	/**
	 * Cancels the schedule of this receiver.
	 *
	 * @param context The context.
	 */

	public static void cancel(final Context context) {
		final AlarmManager manager = (AlarmManager)context.getSystemService(Context.ALARM_SERVICE);
		if(manager == null) {
			return;
		}

		// We cancel the pending intent.
		final PendingIntent pendingIntent = getPendingIntent(context);
		manager.cancel(pendingIntent);
		pendingIntent.cancel();
	}

	/**
	 * Returns a PendingIntent to schedule this class.
	 *
	 * @param context The context.
	 *
	 * @return A PendingIntent to schedule this class.
	 */

	private static PendingIntent getPendingIntent(final Context context) {
		final Intent intent = new Intent(context, LessonModeManager.class);
		return PendingIntent.getBroadcast(context, 0, intent, 0);
	}

	/**
	 * Checks if the user is currently in a lesson.
	 *
	 * @param context The context.
	 *
	 * @return Whether we're currently in a lesson.
	 */

	public static boolean inLesson(final Context context) {
		final List<Lesson> lessons = ((TimetableApplication)context.getApplicationContext()).getDatabase().getLessonDao().getRemainingLessons();
		if(lessons.isEmpty()) {
			return false;
		}

		// This is the next lesson, we get it and we check that we're currently in it.
		final Lesson next = lessons.get(0);
		final DateTime now = DateTime.now();
		return now.isAfter(next.getStartDate()) && now.isBefore(next.getEndDate());
	}

	/**
	 * Returns the next schedule time of this receiver.
	 *
	 * @param context The context.
	 *
	 * @return The next schedule time of this receiver. -1 if it should be tomorrow midnight.
	 */

	public static long getScheduleTime(final Context context) {
		// If there is not remaining lessons, we return -1.
		final List<Lesson> lessons = ((TimetableApplication)context.getApplicationContext()).getDatabase().getLessonDao().getRemainingLessons();
		if(lessons.isEmpty()) {
			return -1L;
		}

		// If we're not in this lesson, we return the start date (+1 sec).
		final Lesson next = lessons.get(0);
		if(DateTime.now().isBefore(next.getStartDate())) {
			return next.getStartDate().getMillis() + 1000L;
		}

		// Otherwise, we return the end date (+1 sec).
		return next.getEndDate().getMillis() + 1000L;
	}

	/**
	 * Reads the Ringer File preferences.
	 *
	 * @param context The context.
	 *
	 * @return The Ringer File preferences.
	 */

	public static SharedPreferences getSharedPreferences(final Context context) {
		return context.getSharedPreferences(RINGER_FILE, Context.MODE_PRIVATE);
	}

	/**
	 * Returns the ringer mode sets in preferences.
	 *
	 * @param context The context.
	 *
	 * @return The ringer mode sets in preferences.
	 */

	public static int getPreferenceMode(final Context context) {
		final AudioManager manager = (AudioManager)context.getSystemService(Context.AUDIO_SERVICE);
		if(manager == null) {
			return -1;
		}

		// We read the preference value.
		int mode = manager.getRingerMode();
		switch(context.getSharedPreferences(MainActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE).getString(MainActivity.PREFERENCES_LESSONS_RINGER_MODE, "-1")) {
		case "1":
			mode = AudioManager.RINGER_MODE_SILENT;
			break;
		case "2":
			mode = AudioManager.RINGER_MODE_VIBRATE;
			break;
		default:
			break;
		}

		// And we return the corresponding mode.
		return mode;
	}

	/**
	 * Displays the lesson mode notification.
	 *
	 * @param context The context.
	 */

	private static void displayNotification(final Context context) {
		// If we are saturday or sunday (it should not be possible), we go to the next monday.
		LocalDate date = LocalDate.now();
		if(date.getDayOfWeek() == DateTimeConstants.SATURDAY || date.getDayOfWeek() == DateTimeConstants.SUNDAY) {
			date = date.withDayOfWeek(DateTimeConstants.MONDAY).plusWeeks(1);
		}

		// We create the MainActivity intent.
		final Intent intent = new Intent(context, MainActivity.class);
		intent.putExtra(MainActivity.INTENT_DATE, date.toString("yyyy-MM-dd"));

		// The disable intent.
		final PendingIntent disableMode = PendingIntent.getService(context, 0, new Intent(context, NotificationAction.class), PendingIntent.FLAG_ONE_SHOT);

		// And we create the message.
		final int value = Integer.parseInt(context.getSharedPreferences(MainActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE).getString(MainActivity.PREFERENCES_LESSONS_RINGER_MODE, "-1"));
		final String message = context.getString(R.string.notification_lessonsringermode_message, context.getResources().getStringArray(R.array.preferences_application_lessonsringermode_keys)[value].toUpperCase());

		// We build our notification.
		final NotificationCompat.Builder builder = new NotificationCompat.Builder(context, NOTIFICATION_CHANNEL_ID)
				.setSmallIcon(R.drawable.notification_ringer_small_drawable)
				.setContentTitle(context.getString(R.string.notification_lessonsringermode_title))
				.setStyle(new NotificationCompat.BigTextStyle().bigText(message))
				.setContentText(message)
				.addAction(R.drawable.notification_ringer_block_drawable, context.getString(R.string.notification_lessonsringermode_button), disableMode)
				.setOngoing(true)
				.setContentIntent(PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT));

		final NotificationManager manager = (NotificationManager)context.getSystemService(Context.NOTIFICATION_SERVICE);
		if(manager == null) {
			return;
		}

		// And we send it !
		manager.notify(NOTIFICATION_TAG, MODE_NOTIFICATION_ID, builder.build());
	}

	/**
	 * Closes the lesson mode notification.
	 *
	 * @param context The context.
	 */

	private static void closeNotification(final Context context) {
		final NotificationManager manager = (NotificationManager)context.getSystemService(Context.NOTIFICATION_SERVICE);
		if(manager == null) {
			return;
		}

		// Closes the notification if possible.
		manager.cancel(NOTIFICATION_TAG, MODE_NOTIFICATION_ID);
	}

	/**
	 * The disable notification action.
	 */

	public static class NotificationAction extends IntentService {

		/**
		 * Creates a new notification action.
		 */

		public NotificationAction() {
			super(NotificationAction.class.getSimpleName());
		}

		@Override
		protected final void onHandleIntent(@Nullable final Intent intent) {
			// Disables the lesson mode.
			LessonModeManager.disable(this);
		}

	}

}
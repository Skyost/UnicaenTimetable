package fr.skyost.timetable.receivers.ringer;

import android.app.AlarmManager;
import android.app.IntentService;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.media.AudioManager;
import android.os.Build;
import android.support.annotation.Nullable;
import android.support.v4.app.NotificationCompat;

import java.io.IOException;
import java.util.Calendar;

import fr.skyost.timetable.R;
import fr.skyost.timetable.Timetable;
import fr.skyost.timetable.activities.MainActivity;
import fr.skyost.timetable.receivers.TodayWidgetReceiver;
import fr.skyost.timetable.utils.Utils;

public class RingerModeManager extends BroadcastReceiver {

	public static final String NOTIFICATION_CHANNEL_ID = "timetable_ringer_channel";
	public static final String NOTIFICATION_TAG = "timetable_ringer";
	public static final int NOTIFICATION_ID = 1;

	public static final String RINGER_FILE = "ringer";
	public static final String RINGER_MODE = "mode";

	@Override
	public final void onReceive(final Context context, final Intent intent) {
		if(!RingerModeManager.isEnabled(context)) {
			return;
		}

		try {
			if(inLesson(context)) {
				enable(context);
			}
			else {
				disable(context);
			}

			schedule(context);
		}
		catch(final Exception ex) {
			ex.printStackTrace();
		}
	}

	/**
	 * Turns on lesson mode, even if disabled in the config.
	 *
	 * @param context The context.
	 */

	public static void enable(final Context context) {
		final SharedPreferences preferences = RingerModeManager.getSharedPreferences(context);
		final AudioManager manager = (AudioManager)context.getSystemService(Context.AUDIO_SERVICE);

		if(manager != null && !preferences.contains(RingerModeManager.RINGER_MODE) && !preferences.contains(RingerModeManager.RINGER_MODE)) {
			final SharedPreferences.Editor editor = preferences.edit();

			editor.putInt(RingerModeManager.RINGER_MODE, manager.getRingerMode());
			manager.setRingerMode(RingerModeManager.getPreferenceMode(context));

			editor.commit();
		}

		RingerModeManager.displayNotification(context);
	}

	/**
	 * Turns off lesson mode, even if disabled in the config.
	 *
	 * @param context The context.
	 */

	public static void disable(final Context context) {
		final SharedPreferences preferences = RingerModeManager.getSharedPreferences(context);
		final AudioManager manager = (AudioManager)context.getSystemService(Context.AUDIO_SERVICE);

		if(manager != null && RingerModeManager.getPreferenceMode(context) == manager.getRingerMode()) {
			final int mode = preferences.getInt(RingerModeManager.RINGER_MODE, -1);
			preferences.edit().clear().commit(); // We need to clear them immediately as RingerModeStateChangeReceiver will be triggered.
			if(mode != -1) {
				manager.setRingerMode(mode);
			}
		}
		else {
			preferences.edit().clear().commit();
		}

		RingerModeManager.closeNotification(context);
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
	 *
	 * @throws IOException If an exception occurs while getting the next schedule time.
	 */

	public static void schedule(final Context context) throws IOException {
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

		if(time == -1L) {
			time = Utils.tomorrowMidnight().getTimeInMillis();
		}

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

		final PendingIntent pendingIntent = getPendingIntent(context);

		manager.cancel(pendingIntent);
		pendingIntent.cancel();
	}

	/**
	 * Gets a PendingIntent to schedule this class.
	 *
	 * @param context The context.
	 *
	 * @return A PendingIntent to schedule this class.
	 */

	private static PendingIntent getPendingIntent(final Context context) {
		final Intent intent = new Intent(context, RingerModeManager.class);
		return PendingIntent.getBroadcast(context, 0, intent, 0);
	}

	/**
	 * Checks if the user is currently in a lesson.
	 *
	 * @param context The context.
	 *
	 * @return Whether we're currently in a lesson.
	 *
	 * @throws IOException If an exception occurs while reading the timetable.
	 */

	public static boolean inLesson(final Context context) throws IOException {
		final Timetable timetable = Timetable.loadFromDisk(context);
		if(timetable == null) {
			return false;
		}

		final Timetable.Lesson next = timetable.getNextLesson();
		if(next == null) {
			return false;
		}

		final Calendar calendar = Calendar.getInstance();
		return calendar.after(next.getStart()) && calendar.before(next.getEnd());
	}

	/**
	 * Gets the next schedule time of this receiver.
	 *
	 * @param context The context.
	 *
	 * @return The next schedule time of this receiver. -1 if it should be tomorrow midnight.
	 *
	 * @throws IOException If an exception occurs while reading the timetable.
	 */

	public static long getScheduleTime(final Context context) throws IOException {
		final Timetable timetable = Timetable.loadFromDisk(context);
		if(timetable == null) {
			return -1L;
		}

		final Timetable.Lesson next = timetable.getNextLesson();
		if(next == null) {
			return -1L;
		}

		if(Calendar.getInstance().before(next.getStart())) {
			return next.getStart().getTimeInMillis() + 1000L;
		}

		return next.getEnd().getTimeInMillis() + 1000L;
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
	 * Gets the ringer mode sets in preferences.
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

		final int value = Integer.parseInt(context.getSharedPreferences(MainActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE).getString(MainActivity.PREFERENCES_LESSONS_RINGER_MODE, "-1"));
		int mode = manager.getRingerMode();

		switch(value) {
		case 1:
			mode = AudioManager.RINGER_MODE_SILENT;
			break;
		case 2:
			mode = AudioManager.RINGER_MODE_VIBRATE;
			break;
		default:
			break;
		}

		return mode;
	}

	/**
	 * Displays the lesson mode notification.
	 *
	 * @param context The context.
	 */

	private static void displayNotification(final Context context) {
		int day = Calendar.getInstance().get(Calendar.DAY_OF_WEEK);
		if(day == Calendar.SATURDAY || day == Calendar.SUNDAY) {
			day = Calendar.MONDAY;
		}
		final Intent currentFragment = new Intent(context, MainActivity.class);
		currentFragment.putExtra(MainActivity.INTENT_CURRENT_FRAGMENT, day);

		final PendingIntent disableMode = PendingIntent.getService(context, 0, new Intent(context, NotificationAction.class), PendingIntent.FLAG_ONE_SHOT);

		final int value = Integer.parseInt(context.getSharedPreferences(MainActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE).getString(MainActivity.PREFERENCES_LESSONS_RINGER_MODE, "-1"));
		final String message = context.getString(R.string.notification_lessonsringermode_message, context.getResources().getStringArray(R.array.preferences_application_lessonsringermode_keys)[value].toUpperCase());

		final NotificationCompat.Builder builder = new NotificationCompat.Builder(context, NOTIFICATION_CHANNEL_ID);
		builder.setSmallIcon(R.drawable.notification_ringer_small_drawable);
		builder.setContentTitle(context.getString(R.string.notification_lessonsringermode_title));
		builder.setStyle(new NotificationCompat.BigTextStyle().bigText(message));
		builder.setContentText(message);
		builder.addAction(R.drawable.notification_ringer_block_drawable, context.getString(R.string.notification_lessonsringermode_button), disableMode);
		builder.setOngoing(true);
		builder.setContentIntent(PendingIntent.getActivity(context, TodayWidgetReceiver.CURRENT_DAY_REQUEST, currentFragment, PendingIntent.FLAG_UPDATE_CURRENT));

		final NotificationManager manager = (NotificationManager)context.getSystemService(Context.NOTIFICATION_SERVICE);
		if(manager == null) {
			return;
		}

		manager.notify(NOTIFICATION_TAG, NOTIFICATION_ID, builder.build());
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

		manager.cancel(NOTIFICATION_TAG, NOTIFICATION_ID);
	}

	/**
	 * The disable lesson mode notification action.
	 */

	public static class NotificationAction extends IntentService {

		public NotificationAction() {
			super(NotificationAction.class.getSimpleName());
		}

		@Override
		protected final void onHandleIntent(@Nullable Intent intent) {
			RingerModeManager.disable(this);
		}

	}

}
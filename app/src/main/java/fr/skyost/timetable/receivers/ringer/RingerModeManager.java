package fr.skyost.timetable.receivers.ringer;

import android.app.AlarmManager;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.media.AudioManager;
import android.os.Build;
import android.support.v4.app.NotificationCompat;

import java.io.IOException;
import java.util.Calendar;

import fr.skyost.timetable.R;
import fr.skyost.timetable.Timetable;
import fr.skyost.timetable.activities.MainActivity;
import fr.skyost.timetable.receivers.TodayWidgetReceiver;
import fr.skyost.timetable.utils.Utils;

public class RingerModeManager {

	public static final String NOTIFICATION_CHANNEL_ID = "timetable_ringer_channel";
	public static final String NOTIFICATION_TAG = "timetable_ringer";
	public static final int NOTIFICATION_ID = 1;

	public static final String RINGER_FILE = "ringer";
	public static final String RINGER_MODE = "mode";
	//public static final String RINGER_VOLUMES = "volumes";

	public static final boolean isEnabled(final Context context) {
		return Integer.parseInt(context.getSharedPreferences(MainActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE).getString(MainActivity.PREFERENCES_LESSONS_RINGER_MODE, "0")) != 0;
	}

	public static final void schedule(final Context context) throws IOException {
		schedule(context, true);
	}

	public static final void schedule(final Context context, final boolean nowIfPossible) throws IOException {
		RingerModeEnabler.schedule(context, nowIfPossible);
		RingerModeDisabler.schedule(context, nowIfPossible);
	}

	public static final void schedule(final Context context, final boolean nowIfPossible, final int task) throws IOException {
		final AlarmManager manager = (AlarmManager)context.getSystemService(Context.ALARM_SERVICE);
		final long time = getScheduleTime(context, task, nowIfPossible);

		if(task == RingerModeEnabler.TASK_ID && time == -1L) {
			new RingerModeEnabler().onReceive(context, null);
			return;
		}

		final PendingIntent pendingIntent = getPendingIntent(context, task);
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

	public static final void cancel(final Context context) {
		RingerModeEnabler.cancel(context);
		RingerModeDisabler.cancel(context);
	}

	public static final void cancel(final Context context, final int task) {
		final AlarmManager manager = (AlarmManager)context.getSystemService(Context.ALARM_SERVICE);
		final PendingIntent pendingIntent = getPendingIntent(context, task);

		manager.cancel(pendingIntent);
		pendingIntent.cancel();

		if(task == RingerModeDisabler.TASK_ID) {
			new RingerModeDisabler().onReceive(context, null);
		}
	}

	protected static final PendingIntent getPendingIntent(final Context context, final int task) {
		final Intent intent = new Intent(context, task == RingerModeEnabler.TASK_ID ? RingerModeEnabler.class : RingerModeDisabler.class);
		return PendingIntent.getBroadcast(context, 0, intent, PendingIntent.FLAG_CANCEL_CURRENT);
	}

	public static final long getScheduleTime(final Context context, final int task, final boolean nowIfPossible) throws IOException {
		final Timetable.Lesson[] remaining = Timetable.loadFromDisk(context).getRemainingLessons();

		if(remaining.length == 0) {
			return Utils.tomorrowMidnight();
		}

		if(task == RingerModeDisabler.TASK_ID) {
			return remaining[0].getEnd().getTimeInMillis() + 1000L;
		}

		if(remaining[0].getStart().before(Calendar.getInstance())) {
			if(nowIfPossible) {
				return -1L;
			}
			return remaining.length > 1 ? remaining[1].getStart().getTimeInMillis() + 1000L : Utils.tomorrowMidnight();
		}
		return remaining[0].getStart().getTimeInMillis() + 1000L;
	}

	public static final SharedPreferences getSharedPreferences(final Context context) {
		return context.getSharedPreferences(RINGER_FILE, Context.MODE_PRIVATE);
	}

	public static final int getPreferenceMode(final Context context) {
		final AudioManager manager = (AudioManager)context.getSystemService(Context.AUDIO_SERVICE);
		final int value = Integer.parseInt(context.getSharedPreferences(MainActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE).getString(MainActivity.PREFERENCES_LESSONS_RINGER_MODE, "-1"));

		final int currentMode = manager.getRingerMode();
		int mode = currentMode;

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

	protected static final void displayNotification(final Context context) {
		int day = Calendar.getInstance().get(Calendar.DAY_OF_WEEK);
		if(day == Calendar.SATURDAY || day == Calendar.SUNDAY) {
			day = Calendar.MONDAY;
		}
		final Intent currentFragment = new Intent(context, MainActivity.class);
		currentFragment.putExtra(MainActivity.INTENT_CURRENT_FRAGMENT, day);

		final int value = Integer.parseInt(context.getSharedPreferences(MainActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE).getString(MainActivity.PREFERENCES_LESSONS_RINGER_MODE, "-1"));

		final NotificationCompat.Builder builder = new NotificationCompat.Builder(context, NOTIFICATION_CHANNEL_ID);
		builder.setSmallIcon(R.drawable.notification_ringer_small_drawable);
		builder.setContentTitle(context.getString(R.string.notification_lessonsringermode_title));
		builder.setContentText(context.getString(R.string.notification_lessonsringermode_message, context.getResources().getStringArray(R.array.preferences_application_lessonsringermode_keys)[value].toUpperCase()));
		builder.addAction(R.drawable.notification_ringer_block_drawable, context.getString(R.string.notification_lessonsringermode_button), PendingIntent.getBroadcast(context, 0, new Intent(context, RingerModeDisabler.class), PendingIntent.FLAG_CANCEL_CURRENT));
		builder.setOngoing(true);
		builder.setContentIntent(PendingIntent.getActivity(context, TodayWidgetReceiver.CURRENT_DAY_REQUEST, currentFragment, PendingIntent.FLAG_UPDATE_CURRENT));

		final NotificationManager manager = (NotificationManager)context.getSystemService(Context.NOTIFICATION_SERVICE);
		manager.notify(NOTIFICATION_TAG, NOTIFICATION_ID, builder.build());
	}

	protected static final void closeNotification(final Context context) {
		final NotificationManager manager = (NotificationManager)context.getSystemService(Context.NOTIFICATION_SERVICE);
		manager.cancel(NOTIFICATION_TAG, NOTIFICATION_ID);
	}

}
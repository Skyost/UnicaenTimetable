package fr.skyost.timetable.receivers.ringer;

import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.media.AudioManager;

import java.io.IOException;

public class RingerModeDisabler extends BroadcastReceiver {

	public static final int TASK_ID = 1;

	@Override
	public final void onReceive(final Context context, final Intent intent) {
		if(!RingerModeManager.isEnabled(context)) {
			return;
		}

		try {
			final SharedPreferences preferences = RingerModeManager.getSharedPreferences(context);
			final AudioManager manager = (AudioManager)context.getSystemService(Context.AUDIO_SERVICE);

			if(RingerModeManager.getPreferenceMode(context) == manager.getRingerMode()) {
				/*if(preferences.contains(RingerModeManager.RINGER_VOLUMES)) {
					final String[] parts = preferences.getString(RingerModeManager.RINGER_VOLUMES, "").split(" ");
					if(parts.length < 6) {
						return;
					}

					manager.setStreamVolume(AudioManager.STREAM_ALARM, Integer.parseInt(parts[0]), 0);
					manager.setStreamVolume(AudioManager.STREAM_MUSIC, Integer.parseInt(parts[1]), 0);
					manager.setStreamVolume(AudioManager.STREAM_NOTIFICATION, Integer.parseInt(parts[2]), 0);
					manager.setStreamVolume(AudioManager.STREAM_RING, Integer.parseInt(parts[3]), 0);
					manager.setStreamVolume(AudioManager.STREAM_SYSTEM, Integer.parseInt(parts[4]), 0);
					manager.setStreamVolume(AudioManager.STREAM_VOICE_CALL, Integer.parseInt(parts[5]), 0);
				}*/

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
			schedule(context);
		}
		catch(final Exception ex) {
			ex.printStackTrace();
		}
	}

	public static final void schedule(final Context context) throws IOException {
		schedule(context, false);
	}

	public static final void schedule(final Context context,  final boolean nowIfPossible) throws IOException {
		RingerModeManager.schedule(context, nowIfPossible, TASK_ID);
	}

	public static final void cancel(final Context context) {
		RingerModeManager.cancel(context, TASK_ID);
	}

	private static final PendingIntent getPendingIntent(final Context context) {
		return RingerModeManager.getPendingIntent(context, TASK_ID);
	}

	public static final long getScheduleTime(final Context context) throws IOException {
		return RingerModeManager.getScheduleTime(context, TASK_ID, false);
	}

}

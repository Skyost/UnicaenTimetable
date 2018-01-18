package fr.skyost.timetable.receivers.ringer;

import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.media.AudioManager;

import java.io.IOException;

public class RingerModeEnabler extends BroadcastReceiver {

	public static final int TASK_ID = 0;

	@Override
	public final void onReceive(final Context context, final Intent intent) {
		if(!RingerModeManager.isEnabled(context)) {
			return;
		}

		try {
			final SharedPreferences preferences = RingerModeManager.getSharedPreferences(context);
			final AudioManager manager = (AudioManager)context.getSystemService(Context.AUDIO_SERVICE);

			if(!preferences.contains(RingerModeManager.RINGER_MODE) && !preferences.contains(RingerModeManager.RINGER_MODE)) {
				final SharedPreferences.Editor editor = preferences.edit();

				/*final StringBuilder builder = new StringBuilder();
				for(final int streamId : new int[]{AudioManager.STREAM_ALARM, AudioManager.STREAM_MUSIC, AudioManager.STREAM_NOTIFICATION, AudioManager.STREAM_RING, AudioManager.STREAM_SYSTEM, AudioManager.STREAM_VOICE_CALL}) {
					builder.append(manager.getStreamVolume(streamId) + " ");
					manager.setStreamVolume(streamId, 0, 0);
				}
				builder.setLength(builder.length() -1);
				editor.putString(RingerModeManager.RINGER_VOLUMES, builder.toString());*/

				editor.putInt(RingerModeManager.RINGER_MODE, manager.getRingerMode());
				manager.setRingerMode(RingerModeManager.getPreferenceMode(context));

				editor.commit();
			}

			RingerModeManager.displayNotification(context);
			schedule(context, false);
		}
		catch(final Exception ex) {
			ex.printStackTrace();
		}
	}

	public static final void schedule(final Context context) throws IOException {
		schedule(context, true);
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
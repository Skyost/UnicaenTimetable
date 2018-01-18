package fr.skyost.timetable.receivers.ringer;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.media.AudioManager;

public class RingerModeStateChangeReceiver extends BroadcastReceiver {

	@Override
	public final void onReceive(final Context context, final Intent intent) {
		try {
			if(RingerModeManager.isEnabled(context) && RingerModeManager.getScheduleTime(context, RingerModeEnabler.TASK_ID, true) == -1L) {
				final AudioManager manager = (AudioManager)context.getSystemService(Context.AUDIO_SERVICE);
				if(RingerModeManager.getPreferenceMode(context) == manager.getRingerMode()) {
					return;
				}

				new RingerModeDisabler().onReceive(context, intent);
			}
		}
		catch(final Exception ex) {
			ex.printStackTrace();
		}
	}

}

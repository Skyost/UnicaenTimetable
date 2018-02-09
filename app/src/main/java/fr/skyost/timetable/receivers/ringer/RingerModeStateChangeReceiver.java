package fr.skyost.timetable.receivers.ringer;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.media.AudioManager;

public class RingerModeStateChangeReceiver extends BroadcastReceiver {

	@Override
	public final void onReceive(final Context context, final Intent intent) {
		try {
			if(RingerModeManager.isEnabled(context) && RingerModeManager.inLesson(context)) {
				final AudioManager manager = (AudioManager)context.getSystemService(Context.AUDIO_SERVICE);
				if(manager == null || RingerModeManager.getPreferenceMode(context) == manager.getRingerMode()) {
					return;
				}

				RingerModeManager.disable(context);
			}
		}
		catch(final Exception ex) {
			ex.printStackTrace();
		}
	}

}

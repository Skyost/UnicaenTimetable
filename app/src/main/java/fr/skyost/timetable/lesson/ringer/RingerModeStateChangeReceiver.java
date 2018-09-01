package fr.skyost.timetable.lesson.ringer;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.media.AudioManager;
import android.os.AsyncTask;

public class RingerModeStateChangeReceiver extends BroadcastReceiver {

	@Override
	public void onReceive(final Context context, final Intent intent) {
		AsyncTask.execute(() -> {
			if(LessonModeManager.isEnabled(context) && LessonModeManager.inLesson(context)) {
				final AudioManager manager = (AudioManager)context.getSystemService(Context.AUDIO_SERVICE);
				if(manager == null || LessonModeManager.getPreferenceMode(context) == manager.getRingerMode()) {
					return;
				}

				LessonModeManager.disable(context);
			}
		});
	}

}

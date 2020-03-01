package fr.skyost.timetable.ringer

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.AudioManager
import android.os.AsyncTask

class RingerModeStateChangeReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        AsyncTask.execute {
            if (LessonModeManager.isEnabled(context) && LessonModeManager.inLesson(context)) {
                val manager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
                if (manager == null || LessonModeManager.getPreferenceMode(context) === manager.ringerMode) {
                    return@execute
                }
                LessonModeManager.disable(context)
            }
        }
    }
}
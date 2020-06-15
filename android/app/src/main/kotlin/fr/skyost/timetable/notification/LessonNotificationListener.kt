package fr.skyost.timetable.notification

import android.os.AsyncTask
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification

class LessonNotificationListener : NotificationListenerService() {
    override fun onInterruptionFilterChanged(interruptionFilter: Int) {
        super.onInterruptionFilterChanged(interruptionFilter)

        AsyncTask.execute {
            if (LessonNotificationModeManager.isEnabled(this) && LessonNotificationModeManager.inLesson(this)) {
                LessonNotificationModeManager.cancel(this)
                LessonNotificationModeManager.closeNotification(this)
                LessonNotificationModeManager.schedule(this, LessonNotificationModeManager.getScheduleTime(this, 1))
            }
        }
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        super.onNotificationPosted(sbn)
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification?) {
        super.onNotificationRemoved(sbn)
    }
}
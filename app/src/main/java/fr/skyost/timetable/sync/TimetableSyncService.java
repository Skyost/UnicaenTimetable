package fr.skyost.timetable.sync;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.IBinder;

import androidx.annotation.RequiresApi;
import androidx.core.app.NotificationCompat;

import fr.skyost.timetable.R;

/**
 * The synchronization service.
 */

public class TimetableSyncService extends Service {

	/**
	 * The notification channel ID.
	 */

	public static final String NOTIFICATION_CHANNEL_ID = "timetable_sync_channel";

	/**
	 * The service id.
	 */

	private static final int SERVICE_ID = 0;

	/**
	 * The synchronization adapter lock.
	 */

	private static final Object syncAdapterLock = new Object();

	/**
	 * The synchronization adapter.
	 */

	private static TimetableSyncAdapter syncAdapter = null;

	/*@Override
	public int onStartCommand(final Intent intent, final int flags, final int startId) {
		sendStartForegroundSignal();
		return super.onStartCommand(intent, flags, startId);
	}*/

	@Override
	public void onCreate() {
		// Creates a synchronized synchronization adapter.

		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
			sendStartForegroundSignal();
		}

		synchronized(syncAdapterLock) {
			if(syncAdapter == null) {
				syncAdapter = new TimetableSyncAdapter(getApplicationContext());
			}
		}
	}

	@Override
	public IBinder onBind(final Intent intent) {
		// We show the notification to the user.
		return syncAdapter.getSyncAdapterBinder();
	}

	/**
	 * Creates the notification channel.
	 *
	 * @param context The context.
	 */

	@RequiresApi(api = Build.VERSION_CODES.O)
	public static void createChannel(final Context context) {
		// We create a channel.
		final NotificationChannel channel = new NotificationChannel(NOTIFICATION_CHANNEL_ID, context.getString(R.string.notification_lessonringermode_channel), NotificationManager.IMPORTANCE_DEFAULT);
		channel.setLockscreenVisibility(Notification.VISIBILITY_PUBLIC);

		// And we add it to the notification manager.
		final NotificationManager manager = (NotificationManager)context.getSystemService(Context.NOTIFICATION_SERVICE);
		if(manager != null) {
			manager.createNotificationChannel(channel);
		}
	}

	/**
	 * Sends the start foreground signal.
	 */

	private void sendStartForegroundSignal() {
		startForeground(SERVICE_ID, new NotificationCompat.Builder(this, NOTIFICATION_CHANNEL_ID)
				.setContentTitle(getString(R.string.notification_sync_title))
				.setOngoing(true)
				.setProgress(0, 100, true)
				.build()
		);
	}

}

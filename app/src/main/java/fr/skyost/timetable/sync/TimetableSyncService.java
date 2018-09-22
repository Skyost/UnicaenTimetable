package fr.skyost.timetable.sync;

import android.app.Service;
import android.content.Intent;
import android.os.IBinder;

/**
 * The synchronization service.
 */

public class TimetableSyncService extends Service {

	/**
	 * The synchronization adapter lock.
	 */

	private static final Object syncAdapterLock = new Object();

	/**
	 * The synchronization adapter.
	 */

	private static TimetableSyncAdapter syncAdapter = null;

	@Override
	public void onCreate() {
		// Creates a synchronized synchronization adapter.
		synchronized(syncAdapterLock) {
			if(syncAdapter == null) {
				syncAdapter = new TimetableSyncAdapter(getApplicationContext());
			}
		}
	}

	@Override
	public IBinder onBind(final Intent intent) {
		return syncAdapter.getSyncAdapterBinder();
	}

}

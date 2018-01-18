package fr.skyost.timetable.services;

import android.app.Service;
import android.content.Intent;
import android.os.IBinder;

import fr.skyost.timetable.adapters.TimetableSyncAdapter;

public class TimetableSyncService extends Service {

	private static final Object syncAdapterLock = new Object();
	private static TimetableSyncAdapter syncAdapter = null;

	@Override
	public final void onCreate() {
		synchronized(syncAdapterLock) {
			if(syncAdapter == null) {
				syncAdapter = new TimetableSyncAdapter(getApplicationContext(), true, false);
			}
		}
	}

	@Override
	public final IBinder onBind(final Intent intent) {
		return syncAdapter.getSyncAdapterBinder();
	}

}

package fr.skyost.timetable.sync;

import android.accounts.Account;
import android.content.AbstractThreadedSyncAdapter;
import android.content.ContentProviderClient;
import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.content.SyncResult;
import android.os.Bundle;

import java.util.concurrent.TimeUnit;

import fr.skyost.timetable.application.TimetableApplication;
import fr.skyost.timetable.receiver.MainActivitySyncReceiver;
import fr.skyost.timetable.receiver.NeedUpdateReceiver;
import fr.skyost.timetable.sync.authentication.AuthenticationTask;

/**
 * The synchronization adapter.
 */

public class TimetableSyncAdapter extends AbstractThreadedSyncAdapter {

	/**
	 * Creates a new synchronization adapter instance.
	 *
	 * @param context The context.
	 */

	TimetableSyncAdapter(final Context context) {
		super(context, true);
	}

	@Override
	public void onPerformSync(final Account account, final Bundle extras, final String authority, final ContentProviderClient provider, final SyncResult syncResult) {
		// We check if this is a manual synchronization.
		boolean manualSync = false;
		if(extras != null) {
			manualSync = extras.getBoolean(ContentResolver.SYNC_EXTRAS_MANUAL, false);
			extras.remove(ContentResolver.SYNC_EXTRAS_MANUAL);
		}

		final Context context = getContext();
		int response = AuthenticationTask.ERROR;
		try {
			// We get the response code from the refreshFromNetwork of LessonDao.
			response = ((TimetableApplication)context.getApplicationContext()).getDatabase().getLessonDao().refreshFromNetwork(context);

			// If this is an incorrect response, we can stop.
			if(response != AuthenticationTask.SUCCESS) {
				throw new Exception("Invalid response : " + response);
			}

			// Otherwise we update our widget, lesson mode, ...
			context.sendBroadcast(new Intent(context, NeedUpdateReceiver.class));
			syncResult.stats.numUpdates++;
		}
		catch(final Exception ex) {
			ex.printStackTrace();

			syncResult.stats.numIoExceptions++;
			syncResult.delayUntil = TimeUnit.MINUTES.toSeconds(5);
		}

		// Refreshes the MainActivity (if possible).
		final Intent intent = new Intent(MainActivitySyncReceiver.INTENT_ACTION);
		intent.putExtra(MainActivitySyncReceiver.INTENT_RESPONSE, response);
		intent.putExtra(ContentResolver.SYNC_EXTRAS_MANUAL, manualSync);
		if(manualSync) {
			intent.putExtra(ContentResolver.SYNC_EXTRAS_EXPEDITED, true);
		}
		context.sendBroadcast(intent);
	}

}
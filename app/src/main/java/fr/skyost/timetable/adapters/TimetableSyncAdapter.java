package fr.skyost.timetable.adapters;

import android.Manifest;
import android.accounts.Account;
import android.accounts.AccountManager;
import android.appwidget.AppWidgetManager;
import android.content.AbstractThreadedSyncAdapter;
import android.content.ContentProviderClient;
import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SyncResult;
import android.os.Bundle;

import java.io.FileOutputStream;
import java.net.HttpURLConnection;
import java.text.ParseException;
import java.util.concurrent.TimeUnit;

import biweekly.Biweekly;
import biweekly.ICalendar;
import fr.skyost.timetable.R;
import fr.skyost.timetable.Timetable;
import fr.skyost.timetable.activities.MainActivity;
import fr.skyost.timetable.fragments.DefaultFragment;
import fr.skyost.timetable.receivers.ringer.RingerModeManager;
import fr.skyost.timetable.receivers.TodayWidgetReceiver;
import fr.skyost.timetable.tasks.AuthenticationTask;
import fr.skyost.timetable.utils.Utils;

public class TimetableSyncAdapter extends AbstractThreadedSyncAdapter {

	public TimetableSyncAdapter(final Context context, final boolean autoInitialize, final boolean allowParallelSyncs) {
		super(context, autoInitialize, allowParallelSyncs);
	}

	@Override
	public final void onPerformSync(final Account account, final Bundle extras, final String authority, final ContentProviderClient provider, final SyncResult syncResult) {
		final Context context = this.getContext();
		final Response response = sync(context, account);

		try {
			if(response.ex != null) {
				throw response.ex;
			}

			if(response.result == AuthenticationTask.UNAUTHORIZED || response.result == AuthenticationTask.NOT_FOUND || response.result == AuthenticationTask.NO_ACCOUNT) {
				throw new IllegalStateException("Unable to sync account : error code " + response.result + ".");
			}

			if(response.timetable == null) {
				throw new NullPointerException("Timetable can't be null.");
			}

			response.timetable.saveOnDisk(context);

			final long updateTime = System.currentTimeMillis();
			final FileOutputStream output = context.openFileOutput(DefaultFragment.UPDATE_TIME_FILE, Context.MODE_PRIVATE);
			output.write(String.valueOf(updateTime).getBytes(Utils.UTF_8));
			output.close();

			final SharedPreferences preferences = context.getSharedPreferences(MainActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE);
			preferences.edit().putLong(MainActivity.PREFERENCES_LAST_UPDATE, updateTime).apply();

			final Intent updateIntent = new Intent(context, TodayWidgetReceiver.class);
			updateIntent.setAction(AppWidgetManager.ACTION_APPWIDGET_UPDATE);
			updateIntent.putExtra(TodayWidgetReceiver.INTENT_REFRESH_WIDGETS, true);
			context.sendBroadcast(updateIntent);

			if(RingerModeManager.isEnabled(context)) {
				RingerModeManager.schedule(context, false);
			}

			syncResult.stats.numUpdates++;
		}
		catch(final ParseException ex) {
			ex.printStackTrace();

			syncResult.stats.numParseExceptions++;
		}
		catch(final Exception ex) {
			ex.printStackTrace();

			syncResult.stats.numIoExceptions++;
			syncResult.delayUntil = TimeUnit.MINUTES.toSeconds(5);
		}

		final Intent intent = new Intent(MainActivity.INTENT_SYNC_FINISHED);
		intent.putExtra(MainActivity.INTENT_SYNC_TIMETABLE, response.timetable);
		intent.putExtra(MainActivity.INTENT_SYNC_RESULT, response.result);
		intent.putExtra(ContentResolver.SYNC_EXTRAS_MANUAL, true);
		context.sendBroadcast(intent);
	}

	public static final Response sync(final Context context, final Account account) {
		try {
			if(!Utils.hasPermission(context, Manifest.permission.INTERNET)) {
				return new Response(AuthenticationTask.UNAUTHORIZED, null, null);
			}

			final Account[] accounts = AccountManager.get(context).getAccountsByType(context.getString(R.string.account_type_authority));
			if(accounts.length < 1) {
				return new Response(AuthenticationTask.NO_ACCOUNT, null, null);
			}

			final okhttp3.Response response = AuthenticationTask.buildClient().newCall(AuthenticationTask.buildRequest(context, account.name, Utils.a(context, account))).execute();

			final int code = response.code();
			if(code == HttpURLConnection.HTTP_NOT_FOUND) {
				return new Response(AuthenticationTask.NOT_FOUND, null, null);
			}
			if(code == HttpURLConnection.HTTP_UNAUTHORIZED) {
				return new Response(AuthenticationTask.UNAUTHORIZED, null, null);
			}

			final ICalendar calendar = Biweekly.parse(response.body().byteStream()).first();
			return new Response(AuthenticationTask.SUCCESS, new Timetable(calendar), null);
		}
		catch(final Exception ex) {
			return new Response(AuthenticationTask.ERROR, null, ex);
		}
	}

	public static class Response {

		public Integer result;
		public Timetable timetable;
		public Exception ex;

		public Response(final int result, final Timetable timetable, final Exception ex) {
			this.result = result;
			this.timetable = timetable;
			this.ex = ex;
		}

	}

}
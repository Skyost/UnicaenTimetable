package fr.skyost.timetable.tasks;

import android.Manifest;
import android.accounts.Account;
import android.accounts.AccountManager;
import android.app.Activity;
import android.os.AsyncTask;

import net.fortuna.ical4j.data.CalendarBuilder;
import net.fortuna.ical4j.model.Calendar;

import java.net.HttpURLConnection;

import fr.skyost.timetable.R;
import fr.skyost.timetable.Timetable;
import fr.skyost.timetable.utils.Utils;

public class CalendarTask extends AsyncTask<Void, Void, CalendarTask.Response> {

	private final Activity activity;
	private final CalendarTaskListener listener;

	public CalendarTask(final Activity activity, final CalendarTaskListener listener) {
		this.activity = activity;
		this.listener = listener;
	}

	@Override
	protected final void onPreExecute() {
		listener.onCalendarTaskStarted();
	}

	@Override
	protected final Response doInBackground(final Void... params) {
		try {
			if(!Utils.hasPermission(activity, Manifest.permission.INTERNET)) {
				return new Response(AuthenticationTask.UNAUTHORIZED, null, null);
			}

			final Account[] accounts = AccountManager.get(activity).getAccountsByType(activity.getString(R.string.account_type));
			if(accounts.length < 1) {
				return new Response(AuthenticationTask.NO_ACCOUNT, null, null);
			}

			final Account account = accounts[0];
			final okhttp3.Response response = AuthenticationTask.buildClient().newCall(AuthenticationTask.buildRequest(activity, account.name, Utils.a(activity, account))).execute();

			final int code = response.code();
			if(code == HttpURLConnection.HTTP_NOT_FOUND) {
				return new Response(AuthenticationTask.NOT_FOUND, null, null);
			}
			if(code == HttpURLConnection.HTTP_UNAUTHORIZED) {
				return new Response(AuthenticationTask.UNAUTHORIZED, null, null);
			}

			final Calendar calendar = new CalendarBuilder().build(response.body().byteStream());
			return new Response(AuthenticationTask.SUCCESS, new Timetable(calendar), null);
		}
		catch(final Exception ex) {
			return new Response(AuthenticationTask.ERROR, null, ex);
		}
	}

	@Override
	protected final void onPostExecute(final Response result) {
		listener.onCalendarResult(result);
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

	public interface CalendarTaskListener {

		void onCalendarTaskStarted();
		void onCalendarResult(final Response response);

	}

}
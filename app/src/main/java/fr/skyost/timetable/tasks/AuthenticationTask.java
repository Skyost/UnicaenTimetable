package fr.skyost.timetable.tasks;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.res.Resources;
import android.net.Uri;
import android.os.AsyncTask;

import org.joda.time.DateTime;

import java.lang.ref.WeakReference;
import java.net.HttpURLConnection;
import java.util.concurrent.TimeUnit;

import fr.skyost.timetable.R;
import fr.skyost.timetable.Timetable;
import fr.skyost.timetable.activities.MainActivity;
import fr.skyost.timetable.utils.Utils;
import okhttp3.Credentials;
import okhttp3.OkHttpClient;
import okhttp3.Request;

public class AuthenticationTask extends AsyncTask<Void, Void, AuthenticationTask.Response> {

	public static final int SUCCESS = 100;
	public static final int NO_ACCOUNT = 200;
	public static final int NOT_FOUND = 300;
	public static final int UNAUTHORIZED = 400;
	public static final int ERROR = 500;

	@Deprecated
	public static final String PREFERENCES_FILE = "authentication";
	@Deprecated
	public static final String PREFERENCES_USERNAME = "data-0";
	@Deprecated
	public static final String PREFERENCES_PASSWORD = "data-1";

	private final WeakReference<Activity> activity;
	private final AuthenticationListener listener;
	private final String username;
	private final String password;

	public AuthenticationTask(final Activity activity, final String username, final String password, final AuthenticationListener listener) {
		this.activity = new WeakReference<>(activity);
		this.username = username;
		this.password = password;
		this.listener = listener;
	}

	@Override
	protected final void onPreExecute() {
		listener.onAuthenticationTaskStarted();
	}

	@Override
	protected final Response doInBackground(final Void... params) {
		try {
			final Activity activity = this.activity.get();
			if(activity == null) {
				throw new NullPointerException("Unable to access to parent activity.");
			}

			if(!Utils.hasPermission(activity, Manifest.permission.INTERNET)) {
				return new Response(UNAUTHORIZED, null);
			}

			final int code = buildClient().newCall(buildRequest(activity, username, password)).execute().code();
			if(code == HttpURLConnection.HTTP_NOT_FOUND) {
				return new Response(NOT_FOUND, null);
			}
			if(code == HttpURLConnection.HTTP_UNAUTHORIZED) {
				return new Response(UNAUTHORIZED, null);
			}

			return new Response(SUCCESS, null, username, password);
		}
		catch(final Exception ex) {
			return new Response(ERROR, ex);
		}
	}

	@Override
	protected final void onPostExecute(final Response result) {
		listener.onAuthenticationResult(result);
	}

	/**
	 * Builds a new client.
	 *
	 * @return The new client.
	 */

	public static OkHttpClient buildClient() {
		return new OkHttpClient.Builder()
				.connectTimeout(15, TimeUnit.SECONDS)
				.readTimeout(15, TimeUnit.SECONDS)
				.build();
	}

	/**
	 * Builds a new calendar request.
	 *
	 * @param context We need a context to get the calendar address.
	 * @param username The username.
	 * @param password The password.
	 *
	 * @return The request.
	 */

	public static Request buildRequest(final Context context, final String username, final String password) {
		return new Request.Builder()
				.url(getCalendarAddress(context, username))
				.header("Authorization", Credentials.basic(username, password))
				.get()
				.build();
	}

	/**
	 * Gets the calendar address.
	 *
	 * @param context We need it to read preferences.
	 * @param account The account.
	 *
	 * @return The calendar address.
	 */

	private static String getCalendarAddress(final Context context, final String account) {
		final Resources resources = context.getResources();
		final SharedPreferences preferences = context.getSharedPreferences(MainActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE);

		final DateTime minDate = Timetable.getMinStartDate(context);
		final DateTime maxDate = Timetable.getMaxEndDate(context);

		return preferences.getString(MainActivity.PREFERENCES_SERVER, resources.getString(R.string.settings_default_server)) + "/home/" + account + "/" + Uri.encode(preferences.getString(MainActivity.PREFERENCES_CALENDAR, resources.getString(R.string.settings_default_calendarname))) + "?auth=ba&fmt=ics" + (minDate == null ? "" : "&start=" + minDate.toString("MM/dd/YYYY")) + (maxDate == null ? "" : "&end=" + maxDate.toString("MM/dd/YYYY"));
	}

	public static class Response {

		public Integer result;
		public Exception ex;

		public String username;
		public String password;

		private Response(final int result, final Exception ex) {
			this(result, ex, null, null);
		}

		private Response(final int result, final Exception ex, final String username, final String password) {
			this.result = result;
			this.ex = ex;
			this.username = username;
			this.password = password;
		}

	}

	public interface AuthenticationListener {

		void onAuthenticationTaskStarted();
		void onAuthenticationResult(final Response response);

	}

}
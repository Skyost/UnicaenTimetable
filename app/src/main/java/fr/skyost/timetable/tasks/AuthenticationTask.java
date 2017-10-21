package fr.skyost.timetable.tasks;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.res.Resources;
import android.net.Uri;
import android.os.AsyncTask;
import android.util.Base64;

import org.joda.time.DateTime;

import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;
import java.net.URL;

import fr.skyost.timetable.R;
import fr.skyost.timetable.Timetable;
import fr.skyost.timetable.activities.MainActivity;
import fr.skyost.timetable.utils.ObscuredSharedPreferences;
import fr.skyost.timetable.utils.Utils;

public class AuthenticationTask extends AsyncTask<Void, Void, AuthenticationTask.Response> {

	public static final int SUCCESS = 100;
	public static final int NOT_FOUND = 200;
	public static final int UNAUTHORIZED = 300;
	public static final int ERROR = 400;

	public static final String PREFERENCES_FILE = "authentication";
	public static final String PREFERENCES_USERNAME = "data-0";
	public static final String PREFERENCES_PASSWORD = "data-1";

	private final Activity activity;
	private final AuthenticationListener listener;

	public AuthenticationTask(final Activity activity, final AuthenticationListener listener) {
		this.activity = activity;
		this.listener = listener;
	}

	@Override
	protected final void onPreExecute() {
		listener.onAuthenticationTaskStarted();
	}

	@Override
	protected final Response doInBackground(final Void... params) {
		try {
			if(!Utils.hasPermission(activity, Manifest.permission.INTERNET)) {
				return new Response(UNAUTHORIZED, null);
			}

			final SharedPreferences preferences = new ObscuredSharedPreferences(activity, activity.getSharedPreferences(PREFERENCES_FILE, Context.MODE_PRIVATE));
			final String username = preferences.getString(PREFERENCES_USERNAME, "");

			final HttpURLConnection urlConnection = (HttpURLConnection)new URL(getCalendarAddress(activity, username)).openConnection();
			urlConnection.setRequestProperty("Authorization", getAuthenticationData(username, preferences.getString(PREFERENCES_PASSWORD, "")));
			final int response = urlConnection.getResponseCode();
			if(response == 404) {
				return new Response(NOT_FOUND, null);
			}
			if(response == 401) {
				return new Response(UNAUTHORIZED, null);
			}
			urlConnection.getInputStream();
			return new Response(SUCCESS, null);
		}
		catch(final Exception ex) {
			return new Response(ERROR, ex);
		}
	}

	@Override
	protected final void onPostExecute(final Response result) {
		listener.onAuthenticationResult(result.result, result.ex);
	}

	public static final String getCalendarAddress(final Context context, final String account) {
		final Resources resources = context.getResources();
		final SharedPreferences preferences = context.getSharedPreferences(MainActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE);

		final DateTime minDate = Timetable.getMinStartDate(context);
		final DateTime maxDate = Timetable.getMaxEndDate(context);

		return preferences.getString(MainActivity.PREFERENCES_SERVER, resources.getString(R.string.settings_default_server)) + "/home/" + account + "/" + Uri.encode(preferences.getString(MainActivity.PREFERENCES_CALENDAR, resources.getString(R.string.settings_default_calendarname))) + "?auth=ba&fmt=ics" + (minDate == null ? "" : "&start=" + minDate.toString("MM/dd/YYYY")) + (maxDate == null ? "" : "&end=" + maxDate.toString("MM/dd/YYYY"));
	}

	public static final String getAuthenticationData(final String username, final String password) throws UnsupportedEncodingException {
		return "Basic " + new String(Base64.encode((username + ":" + password).getBytes(Utils.UTF_8), Base64.DEFAULT));
	}

	public static class Response {

		public Integer result;
		public Exception ex;

		public Response(final int result, final Exception ex) {
			this.result = result;
			this.ex = ex;
		}

	}

	public interface AuthenticationListener {

		void onAuthenticationTaskStarted();
		void onAuthenticationResult(final int result, final Exception exception);

	}

}
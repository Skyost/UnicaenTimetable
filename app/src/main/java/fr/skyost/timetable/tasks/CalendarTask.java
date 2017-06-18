package fr.skyost.timetable.tasks;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.os.AsyncTask;

import net.fortuna.ical4j.data.CalendarBuilder;
import net.fortuna.ical4j.model.Calendar;

import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;

import fr.skyost.timetable.Timetable;
import fr.skyost.timetable.utils.ObscuredSharedPreferences;
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

			final SharedPreferences preferences = new ObscuredSharedPreferences(activity, activity.getSharedPreferences(AuthenticationTask.PREFERENCES_FILE, Context.MODE_PRIVATE));
			final String username = preferences.getString(AuthenticationTask.PREFERENCES_USERNAME, "");

			final HttpURLConnection urlConnection = (HttpURLConnection)new URL(AuthenticationTask.getCalendarAddress(activity, username)).openConnection();
			urlConnection.setRequestProperty("Authorization", AuthenticationTask.getAuthenticationData(username, preferences.getString(AuthenticationTask.PREFERENCES_PASSWORD, "")));
			final int response = urlConnection.getResponseCode();
			if(response == 404 || response == 401) { // 404 if username is incorrect, 401 if password is incorrect.
				return new Response(AuthenticationTask.UNAUTHORIZED, null, null);
			}

			final InputStream input = urlConnection.getInputStream();
			final Calendar calendar = new CalendarBuilder().build(input);
			input.close();

			return new Response(AuthenticationTask.SUCCESS, new Timetable(calendar), null);
		}
		catch(final Exception ex) {
			return new Response(AuthenticationTask.ERROR, null, ex);
		}
	}

	@Override
	protected final void onPostExecute(final Response result) {
		listener.onCalendarResult(result.result, result.timetable, result.ex);
	}

	public static class Response {

		private Integer result;
		private Timetable timetable;
		private Exception ex;

		public Response(final int result, final Timetable timetable, final Exception ex) {
			this.result = result;
			this.timetable = timetable;
			this.ex = ex;
		}

	}

	public interface CalendarTaskListener {

		void onCalendarTaskStarted();
		void onCalendarResult(final int result, final Timetable timetable, final Exception exception);

	}

}
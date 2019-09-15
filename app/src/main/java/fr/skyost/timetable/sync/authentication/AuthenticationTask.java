package fr.skyost.timetable.sync.authentication;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.AsyncTask;

import androidx.appcompat.app.AppCompatActivity;

import org.joda.time.DateTime;

import java.lang.ref.WeakReference;
import java.net.HttpURLConnection;
import java.util.concurrent.TimeUnit;

import fr.skyost.timetable.R;
import fr.skyost.timetable.activity.settings.SettingsActivity;
import fr.skyost.timetable.utils.Utils;
import okhttp3.Credentials;
import okhttp3.OkHttpClient;
import okhttp3.Request;

/**
 * The task that allows to authenticate the user.
 */

public class AuthenticationTask extends AsyncTask<Void, Void, AuthenticationResponse> {

	/**
	 * Returned if everything is okay.
	 */

	public static final int SUCCESS = 100;

	/**
	 * Returned if the user doesn't have an account.
	 */

	public static final int NO_ACCOUNT = 200;

	/**
	 * Returned if the calendar was not found.
	 */

	public static final int NOT_FOUND = 300;

	/**
	 * Returned if the user is not permitted to access the specified calendar.
	 */

	public static final int UNAUTHORIZED = 400;

	/**
	 * Returned for any other error.
	 */

	public static final int ERROR = 500;

	/**
	 * The authentication preference file.
	 */

	@Deprecated
	public static final String PREFERENCES_FILE = "authentication";

	/**
	 * The username.
	 */

	@Deprecated
	public static final String PREFERENCES_USERNAME = "data-0";

	/**
	 * The password.
	 */

	@Deprecated
	public static final String PREFERENCES_PASSWORD = "data-1";

	/**
	 * The activity reference.
	 */

	private final WeakReference<AppCompatActivity> activity;

	/**
	 * The authentication listener.
	 */

	private final AuthenticationListener listener;

	/**
	 * The username.
	 */

	private String username;

	/**
	 * The password.
	 */

	private final String password;

	/**
	 * Creates a new authentication task instance.
	 *
	 * @param activity The activity.
	 * @param username The username.
	 * @param password The password.
	 * @param listener The authentication listener.
	 */

	public AuthenticationTask(final AppCompatActivity activity, final String username, final String password, final AuthenticationListener listener) {
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
	protected final AuthenticationResponse doInBackground(final Void... params) {
		try {
			final Activity activity = this.activity.get();
			if(activity == null) {
				throw new NullPointerException("Unable to access to parent activity.");
			}

			// If we don't have the permission, we return the corresponding response.
			if(!Utils.hasPermission(activity, Manifest.permission.INTERNET)) {
				return new AuthenticationResponse(UNAUTHORIZED);
			}

			// Same here for HTTP response codes.
			int code = buildClient().newCall(buildRequest(activity, username, password)).execute().code();
			if(code == HttpURLConnection.HTTP_UNAUTHORIZED && !username.endsWith("@etu.unicaen.fr")) {
				username += "@etu.unicaen.fr";
				code = buildClient().newCall(buildRequest(activity, username, password)).execute().code();
			}

			if(code == HttpURLConnection.HTTP_UNAUTHORIZED) {
				return new AuthenticationResponse(UNAUTHORIZED);
			}

			if(code == HttpURLConnection.HTTP_NOT_FOUND) {
				return new AuthenticationResponse(NOT_FOUND);
			}

			// If nothing occurred, it's good, we return a success !
			return new AuthenticationResponse(SUCCESS, null, username, password);
		}
		catch(final Exception ex) {
			return new AuthenticationResponse(ERROR, ex);
		}
	}

	@Override
	protected final void onPostExecute(final AuthenticationResponse result) {
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
	 * Returns the calendar address.
	 *
	 * @param context We need it to read preferences.
	 * @param account The account.
	 *
	 * @return The calendar address.
	 */

	private static String getCalendarAddress(final Context context, final String account) {
		final SharedPreferences preferences = context.getSharedPreferences(SettingsActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE);

		// We get the two bounds.
		final DateTime minDate = SettingsActivity.getMinStartDate(context);
		final DateTime maxDate = SettingsActivity.getMaxEndDate(context);

		// We get the additional parameters.
		final String additionalParameters = preferences.getString(SettingsActivity.PREFERENCES_ADDITIONAL_PARAMETERS, context.getString(R.string.settings_default_parameters));
		boolean addAnd = !additionalParameters.isEmpty();

		// Then we can build our request !
		final StringBuilder request = new StringBuilder()
				.append(preferences.getString(SettingsActivity.PREFERENCES_SERVER, context.getString(R.string.settings_default_server)))
				.append("/home/")
				.append(account)
				.append("/")
				.append(Uri.encode(preferences.getString(SettingsActivity.PREFERENCES_CALENDAR, context.getString(R.string.settings_default_calendarname))))
				.append("?")
				.append(additionalParameters);

		// If there is a minimum date, we add it.
		if(minDate != null) {
			if(addAnd) {
				request.append("&");
				addAnd = false;
			}
			request.append("start=").append(minDate.toString("yyyy/MM/dd"));
		}

		// Same for maximum date.
		if(maxDate != null) {
			if(addAnd) {
				request.append("&");
			}
			request.append("&end=").append(maxDate.toString("yyyy/MM/dd"));
		}

		// Then we return the request.
		return request.toString();
	}

	/**
	 * Returns the activity.
	 *
	 * @return The activity.
	 */

	public AppCompatActivity getActivity() {
		return activity.get();
	}

	/**
	 * Returns the authentication listener.
	 *
	 * @return The authentication listener.
	 */

	public AuthenticationListener getListener() {
		return listener;
	}

	/**
	 * Represents an authentication listener.
	 */

	public interface AuthenticationListener {

		/**
		 * Triggered when the task has started.
		 */

		void onAuthenticationTaskStarted();

		/**
		 * Triggered when there is a response.
		 *
		 * @param response The response.
		 */

		void onAuthenticationResult(final AuthenticationResponse response);

	}

}
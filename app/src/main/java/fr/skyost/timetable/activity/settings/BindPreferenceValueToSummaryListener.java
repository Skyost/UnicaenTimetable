package fr.skyost.timetable.activity.settings;

import android.app.Activity;
import android.app.NotificationManager;
import android.content.Context;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Build;
import android.preference.Preference;
import android.provider.Settings;
import android.text.TextUtils;
import android.widget.Toast;

import org.joda.time.DateTime;

import java.text.DateFormat;

import fr.skyost.timetable.R;
import fr.skyost.timetable.lesson.ringer.LessonModeManager;

/**
 * The preference change listener that allows to bind the value to the summary.
 */

public class BindPreferenceValueToSummaryListener implements Preference.OnPreferenceChangeListener {

	/**
	 * The activity instance.
	 */

	private final Activity activity;

	/**
	 * Creates a new bind preference value to summary listener.
	 *
	 * @param activity The activity.
	 */

	BindPreferenceValueToSummaryListener(final Activity activity) {
		this.activity = activity;
	}

	@Override
	public boolean onPreferenceChange(final Preference preference, final Object value) {
		return notifyPreferenceChange(preference, value, true);
	}

	/**
	 * Notifies that the preference has changed.
	 *
	 * @param preference The preference.
	 * @param value The value.
	 * @param saveChangedIntervalPreference Whether we should save the changed interval preference.
	 *
	 * @return <b>true</b> if there is no problem, <b>false</b> otherwise.
	 */

	public boolean notifyPreferenceChange(final Preference preference, final Object value, final boolean saveChangedIntervalPreference) {
		final String string = value.toString();
		switch(preference.getKey().toLowerCase()) {
		case SettingsActivity.PREFERENCES_SERVER:
			// It's pretty simple here, we put two lines of summary : first the value, second the default value.
			preference.setSummary(TextUtils.isEmpty(string) ? activity.getString(R.string.settings_default_server) : string);
			preference.setSummary(preference.getSummary() + "\n" + activity.getString(R.string.settings_default, activity.getString(R.string.settings_default_server)));
			break;
		case SettingsActivity.PREFERENCES_CALENDAR:
			// Same here.
			preference.setSummary(TextUtils.isEmpty(string) ? activity.getString(R.string.settings_default_calendarname) : string);
			preference.setSummary(preference.getSummary() + "\n" + activity.getString(R.string.settings_default, activity.getString(R.string.settings_default_calendarname)));
			break;
		case SettingsActivity.PREFERENCES_ADDITIONAL_PARAMETERS:
			// Same here.
			preference.setSummary(TextUtils.isEmpty(string) ? activity.getString(R.string.preferences_server_parameters) : string);
			preference.setSummary(preference.getSummary() + "\n" + activity.getString(R.string.settings_default, activity.getString(R.string.settings_default_parameters)));
			break;
		case SettingsActivity.PREFERENCES_CALENDAR_INTERVAL:
			// We store the min and max date in a variable.
			final DateTime inf = SettingsActivity.getMinStartDate(string);
			final DateTime sup = SettingsActivity.getMaxEndDate(string);

			// And we use them !
			final DateFormat formatter = DateFormat.getDateInstance(DateFormat.MEDIUM);
			preference.setSummary(TextUtils.isEmpty(string) ? activity.getResources().getStringArray(R.array.preferences_server_calendar_interval_keys)[0] : activity.getResources().getStringArray(R.array.preferences_server_calendar_interval_keys)[Integer.valueOf(string)]);
			if(inf == null/* || sup == null*/) {
				preference.setSummary(preference.getSummary() + "\n" + activity.getString(R.string.settings_calendar_interval_description_2));
			}
			else {
				preference.setSummary(preference.getSummary() + "\n" + activity.getString(R.string.settings_calendar_interval_description_1, formatter.format(inf.toDate()), formatter.format(sup.toDate())));
			}

			// And we don't forget to save the "changed interval" preference.
			if(saveChangedIntervalPreference) {
				preference.getContext().getSharedPreferences(SettingsActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE).edit().putBoolean(SettingsActivity.PREFERENCES_CHANGED_INTERVAL, true).apply();
			}
			break;
		case SettingsActivity.PREFERENCES_LESSONS_RINGER_MODE:
			final int mode = TextUtils.isEmpty(string) ? 0 : Integer.parseInt(string);
			preference.getSharedPreferences().edit().putString(preference.getKey(), string).commit(); // We have to immediately apply the preference because it is going to be used in LessonModeManager.

			if(mode == 0) {
				// If mode = 0 (i.e. disabled), we cancel and disable the LessonModeManager.
				AsyncTask.execute(() -> {
					LessonModeManager.cancel(activity);
					if(LessonModeManager.inLesson(activity)) {
						LessonModeManager.disable(activity);
					}
				});
			}
			else {
				// If mode = 1 (i.e. silent), we have to request the required permissions.
				if(mode == 1) {
					final NotificationManager manager = (NotificationManager)activity.getSystemService(Context.NOTIFICATION_SERVICE);
					if(manager == null) {
						return false;
					}

					if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !manager.isNotificationPolicyAccessGranted()) {
						Toast.makeText(activity, R.string.settings_toast_silent, Toast.LENGTH_LONG).show();
						final Intent intent = new Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS);
						activity.startActivityForResult(intent, 0);
						return false;
					}
				}

				// And we can enable the LessonModeManager.
				AsyncTask.execute(() -> {
					LessonModeManager.schedule(activity);
					if(LessonModeManager.inLesson(activity)) {
						LessonModeManager.enable(activity);
					}
				});
			}

			// And we don't forget to update the summary (even if the LessonModeManager is going to be enabled / disabled asynchronously).
			preference.setSummary(activity.getResources().getStringArray(R.array.preferences_application_lessonsringermode_keys)[mode]);
			break;
		}
		return true;
	}

	/**
	 * Returns the activity.
	 *
	 * @return The activity.
	 */

	public Activity getActivity() {
		return activity;
	}

}
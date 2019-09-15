package fr.skyost.timetable.fragment.settings;

import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Build;
import android.os.Bundle;
import android.preference.PreferenceFragment;
import android.view.MenuItem;

import fr.skyost.timetable.R;
import fr.skyost.timetable.activity.settings.SettingsActivity;

/**
 * The server preference fragment.
 */

@TargetApi(Build.VERSION_CODES.HONEYCOMB)
public class ServerPreferenceFragment extends PreferenceFragment {

	@Override
	public void onCreate(final Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		// We set the required parameters.
		SettingsActivity.setDefaultPreferencesFile(this);
		this.addPreferencesFromResource(R.xml.preferences_server);
		this.setHasOptionsMenu(true);

		// And we add the preference listeners.
		final Activity activity = getActivity();
		final SharedPreferences preferences = activity.getSharedPreferences(SettingsActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE);
		SettingsActivity.bindPreferenceValueToSummary(activity, preferences, findPreference(SettingsActivity.PREFERENCES_SERVER));
		SettingsActivity.bindPreferenceValueToSummary(activity, preferences, findPreference(SettingsActivity.PREFERENCES_CALENDAR));
		SettingsActivity.bindPreferenceValueToSummary(activity, preferences, findPreference(SettingsActivity.PREFERENCES_ADDITIONAL_PARAMETERS));
		SettingsActivity.bindPreferenceValueToSummary(activity, preferences, findPreference(SettingsActivity.PREFERENCES_CALENDAR_INTERVAL));
	}

	@Override
	public boolean onOptionsItemSelected(final MenuItem item) {
		switch(item.getItemId()) {
		case android.R.id.home:
			// If the user click on the back button, we brought him back to the settings activity.
			this.startActivity(new Intent(this.getActivity(), SettingsActivity.class));
			return true;
		}
		return super.onOptionsItemSelected(item);
	}

}
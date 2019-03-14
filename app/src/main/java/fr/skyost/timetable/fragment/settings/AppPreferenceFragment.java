package fr.skyost.timetable.fragment.settings;

import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.media.AudioManager;
import android.os.Build;
import android.os.Bundle;
import android.preference.Preference;
import android.preference.PreferenceFragment;
import android.preference.SwitchPreference;
import android.view.MenuItem;

import de.mateware.snacky.Snacky;
import fr.skyost.timetable.R;
import fr.skyost.timetable.activity.MainActivity;
import fr.skyost.timetable.activity.settings.SettingsActivity;

/**
 * The app preference fragment.
 */

@TargetApi(Build.VERSION_CODES.HONEYCOMB)
public class AppPreferenceFragment extends PreferenceFragment {

	@Override
	public void onCreate(final Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		// We set the required parameters.
		SettingsActivity.setDefaultPreferencesFile(this);
		addPreferencesFromResource(R.xml.preferences_application);
		setHasOptionsMenu(true);

		// We add the preference listeners.
		final Activity activity = getActivity();
		final SharedPreferences preferences = activity.getSharedPreferences(MainActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE);
		((SwitchPreference)findPreference(MainActivity.PREFERENCES_AUTOMATICALLY_COLOR_LESSONS)).setChecked(preferences.getBoolean(MainActivity.PREFERENCES_AUTOMATICALLY_COLOR_LESSONS, false));

		final Preference automaticallyToggleSilentMode = findPreference(MainActivity.PREFERENCES_LESSONS_RINGER_MODE);
		SettingsActivity.bindPreferenceValueToSummary(activity, preferences, automaticallyToggleSilentMode);

		((SwitchPreference)findPreference(MainActivity.PREFERENCES_AUTOMATICALLY_OPEN_TODAY_PAGE)).setChecked(preferences.getBoolean(MainActivity.PREFERENCES_AUTOMATICALLY_OPEN_TODAY_PAGE, false));
		findPreference(MainActivity.PREFERENCES_ADS).setOnPreferenceChangeListener((preference, newValue) -> {
			Snacky.builder().setActivity(activity).setText(R.string.preferences_application_enableads_restart).info().show();
			return true;
		});

		// Oh, and we have to disable the automaticallyToggleSilentMode if the current AudioManager doesn't allow to use it.
		final AudioManager manager = (AudioManager)activity.getSystemService(Context.AUDIO_SERVICE);
		if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP && (manager == null || manager.isVolumeFixed())) {
			automaticallyToggleSilentMode.setEnabled(false);
		}
	}

	@Override
	public boolean onOptionsItemSelected(final MenuItem item) {
		switch(item.getItemId()) {
		case android.R.id.home:
			// If the user click on the back button, we brought him back to the settings activity.
			startActivity(new Intent(getActivity(), SettingsActivity.class));
			return true;
		}
		return super.onOptionsItemSelected(item);
	}

}
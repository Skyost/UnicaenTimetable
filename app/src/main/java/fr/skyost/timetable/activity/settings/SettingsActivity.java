package fr.skyost.timetable.activity.settings;

import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.res.Configuration;
import android.os.Build;
import android.os.Bundle;
import android.preference.Preference;
import android.preference.PreferenceFragment;
import android.preference.PreferenceManager;
import android.view.MenuItem;

import org.joda.time.DateTime;
import org.joda.time.DateTimeConstants;

import java.util.List;

import androidx.appcompat.app.ActionBar;
import fr.skyost.timetable.R;
import fr.skyost.timetable.activity.MainActivity;
import fr.skyost.timetable.fragment.settings.AccountPreferenceFragment;
import fr.skyost.timetable.fragment.settings.AppPreferenceFragment;
import fr.skyost.timetable.fragment.settings.ServerPreferenceFragment;
import fr.skyost.timetable.utils.AppCompatPreferenceActivity;

/**
 * The settings activity.
 */

public class SettingsActivity extends AppCompatPreferenceActivity {

	/**
	 * The request code for the IntroActivity.
	 */

	public static final int INTRO_ACTIVITY_RESULT = 100;

	@Override
	protected final void onCreate(final Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		// Setup the ActionBar.
		final ActionBar actionBar = getSupportActionBar();
		if(actionBar != null) {
			actionBar.setDisplayHomeAsUpEnabled(true);
		}
	}

	@Override
	public void onSaveInstanceState(final Bundle outState) {
		super.onSaveInstanceState(outState);
	}

	@Override
	protected final void onActivityResult(final int requestCode, final int resultCode, final Intent data) {
		if(resultCode != Activity.RESULT_OK) {
			return;
		}
		switch(requestCode) {
		case INTRO_ACTIVITY_RESULT:
			// We immediately commit the changes (because MainActivity will use it after).
			getSharedPreferences(MainActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE).edit().putBoolean(MainActivity.PREFERENCES_CHANGED_ACCOUNT, true).commit();
			onBackPressed();
			break;
		}
	}

	@Override
	public boolean onOptionsItemSelected(final MenuItem item) {
		switch(item.getItemId()) {
		case android.R.id.home:
			// Mimic the back press.
			onBackPressed();
			return true;
		}
		return super.onOptionsItemSelected(item);
	}


	@Override
	public boolean onIsMultiPane() {
		return isXLargeTablet(this);
	}

	@Override
	@TargetApi(Build.VERSION_CODES.HONEYCOMB)
	public void onBuildHeaders(final List<Header> target) {
		loadHeadersFromResource(R.xml.preferences_header, target);
	}

	@Override
	protected final boolean isValidFragment(final String fragmentName) {
		return ServerPreferenceFragment.class.getName().equals(fragmentName) || AccountPreferenceFragment.class.getName().equals(fragmentName) || AppPreferenceFragment.class.getName().equals(fragmentName);
	}

	/**
	 * Binds a preference value to its summary.
	 *
	 * @param activity The activity.
	 * @param preferences The SharedPreferences.
	 * @param preference The preference.
	 */

	public static void bindPreferenceValueToSummary(final Activity activity, final SharedPreferences preferences, final Preference preference) {
		final BindPreferenceValueToSummaryListener listener = new BindPreferenceValueToSummaryListener(activity);
		preference.setOnPreferenceChangeListener(listener);
		listener.notifyPreferenceChange(preference, preferences.getString(preference.getKey(), ""), false);
	}

	/**
	 * Sets the default preference file.
	 *
	 * @param fragment The fragment.
	 */

	public static void setDefaultPreferencesFile(final PreferenceFragment fragment) {
		final PreferenceManager manager = fragment.getPreferenceManager();
		manager.setSharedPreferencesName(MainActivity.PREFERENCES_TITLE);
		manager.setSharedPreferencesMode(Context.MODE_PRIVATE);
	}

	/**
	 * Returns whether we are on an extra large tablet.
	 *
	 * @param context The context.
	 *
	 * @return Whether we are on an extra large tablet.
	 */

	private static boolean isXLargeTablet(final Context context) {
		return (context.getResources().getConfiguration().screenLayout & Configuration.SCREENLAYOUT_SIZE_MASK) >= Configuration.SCREENLAYOUT_SIZE_XLARGE;
	}

	/**
	 * Returns the min date of this timetable according to preferences.
	 *
	 * @param context Used to get preferences.
	 *
	 * @return The min date of this timetable according to preferences.
	 */

	public static DateTime getMinStartDate(final Context context) {
		return getMinStartDate(context.getSharedPreferences(MainActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE).getString(MainActivity.PREFERENCES_CALENDAR_INTERVAL, "0"));
	}

	/**
	 * Returns the min date of this timetable according to preferences.
	 *
	 * @param preferenceValue The preference value.
	 *
	 * @return The min date of this timetable according to preferences.
	 */

	public static DateTime getMinStartDate(final String preferenceValue) {
		DateTime time = DateTime.now().withTimeAtStartOfDay().withDayOfWeek(DateTimeConstants.MONDAY);

		// Its simple, we check the value and we remove the corresponding duration.
		switch(preferenceValue) {
		case "1":
			time = time.minusMonths(1);
			break;
		case "2":
			time = time.minusMonths(3);
			break;
		case "3":
			time = null;
			break;
		default:
			time = time.minusWeeks(2);
			break;
		}

		return time;
	}

	/**
	 * Returns the max date of this timetable according to preferences.
	 *
	 * @param context Used to get preferences.
	 *
	 * @return The max date of this timetable according to preferences.
	 */

	public static DateTime getMaxEndDate(final Context context) {
		return getMaxEndDate(context.getSharedPreferences(MainActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE).getString(MainActivity.PREFERENCES_CALENDAR_INTERVAL, "0"));
	}

	/**
	 * Returns the max date of this timetable according to preferences.
	 *
	 * @param preferenceValue The preference value.
	 *
	 * @return The max date of this timetable according to preferences.
	 */

	public static DateTime getMaxEndDate(final String preferenceValue) {
		DateTime time = DateTime.now().withTimeAtStartOfDay();

		// Here we have to check that we are not saturday / sunday.
		final int currentDay = time.getDayOfWeek();
		if(currentDay == DateTimeConstants.SATURDAY || currentDay == DateTimeConstants.SUNDAY) {
			time = time.plusWeeks(1);
		}

		time = time.withDayOfWeek(DateTimeConstants.SUNDAY);

		// Same comment as getMinStartDate.
		switch(preferenceValue) {
		case "1":
			time = time.plusMonths(1);
			break;
		case "2":
			time = time.plusMonths(3);
			break;
		case "3":
			time = null;
			break;
		default:
			time = time.plusWeeks(2);
			break;
		}

		return time;
	}

}
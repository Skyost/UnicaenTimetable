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

import androidx.appcompat.app.ActionBar;

import org.joda.time.DateTime;
import org.joda.time.DateTimeConstants;

import java.util.List;

import fr.skyost.timetable.R;
import fr.skyost.timetable.fragment.settings.AccountPreferenceFragment;
import fr.skyost.timetable.fragment.settings.AppPreferenceFragment;
import fr.skyost.timetable.fragment.settings.ServerPreferenceFragment;
import fr.skyost.timetable.utils.AppCompatPreferenceActivity;

/**
 * The settings activity.
 */

public class SettingsActivity extends AppCompatPreferenceActivity {

	/**
	 * Activity's preferences title.
	 */

	public static final String PREFERENCES_TITLE = "preferences";

	/**
	 * The server preference key.
	 */

	public static final String PREFERENCES_SERVER = "server";

	/**
	 * The calendar preference key.
	 */

	public static final String PREFERENCES_CALENDAR = "calendar-nohtml";

	/**
	 * The additional parameters preference key.
	 */

	public static final String PREFERENCES_ADDITIONAL_PARAMETERS = "additional-parameters";

	/**
	 * The timetable refresh interval preference key.
	 */

	public static final String PREFERENCES_CALENDAR_INTERVAL = "calendar-interval";

	/**
	 * The automatic coloring of lessons preference key.
	 */

	public static final String PREFERENCES_AUTOMATICALLY_COLOR_LESSONS = "color-lessons-automatically";

	/**
	 * The open today page preference key.
	 */

	public static final String PREFERENCES_AUTOMATICALLY_OPEN_TODAY_PAGE = "today-automatically";

	/**
	 * The lessons ringer mode preference key.
	 */

	public static final String PREFERENCES_LESSONS_RINGER_MODE = "lessons-ringer-mode";

	/**
	 * The "pinch to zoom" tip preference key.
	 */

	public static final String PREFERENCES_TIP_SHOW_PINCHTOZOOM = "tip-show-pinchtozoom";

	/**
	 * The "change color" tip preference key.
	 */

	public static final String PREFERENCES_TIP_SHOW_CHANGECOLOR = "tip-show-changecolor";

	/**
	 * The account changed preference key.
	 */

	public static final String PREFERENCES_CHANGED_ACCOUNT = "changed-account";

	/**
	 * The interval changed preference key.
	 */

	public static final String PREFERENCES_CHANGED_INTERVAL = "changed-interval";

	/**
	 * The ads preference key.
	 */

	public static final String PREFERENCES_ADS = "ads";

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
			getSharedPreferences(SettingsActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE).edit().putBoolean(SettingsActivity.PREFERENCES_CHANGED_ACCOUNT, true).commit();
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
		manager.setSharedPreferencesName(SettingsActivity.PREFERENCES_TITLE);
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
		return getMinStartDate(context.getSharedPreferences(SettingsActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE).getString(SettingsActivity.PREFERENCES_CALENDAR_INTERVAL, "0"));
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
		return getMaxEndDate(context.getSharedPreferences(SettingsActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE).getString(SettingsActivity.PREFERENCES_CALENDAR_INTERVAL, "0"));
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
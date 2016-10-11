package fr.skyost.timetable.activities;

import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.os.Build;
import android.os.Bundle;
import android.preference.CheckBoxPreference;
import android.preference.Preference;
import android.support.v7.app.ActionBar;
import android.preference.PreferenceFragment;
import android.preference.PreferenceManager;
import android.text.TextUtils;
import android.view.MenuItem;

import fr.skyost.timetable.R;
import fr.skyost.timetable.tasks.AuthenticationTask;
import fr.skyost.timetable.utils.AppCompatPreferenceActivity;
import fr.skyost.timetable.utils.ObscuredSharedPreferences;

import java.util.List;

public class SettingsActivity extends AppCompatPreferenceActivity {

	private static final int INTRO_ACTIVITY_RESULT = 100;

	protected static boolean accountChanged = false;

	@Override
	protected final void onCreate(final Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		final ActionBar actionBar = this.getSupportActionBar();
		if(actionBar != null) {
			actionBar.setDisplayHomeAsUpEnabled(true);
		}

		if(savedInstanceState != null) {
			accountChanged = savedInstanceState.getBoolean(IntroActivity.INTENT_ACCOUNT_CHANGED, false);
		}
	}

	@Override
	public final void onSaveInstanceState(final Bundle outState) {
		super.onSaveInstanceState(outState);
		outState.putBoolean(IntroActivity.INTENT_ACCOUNT_CHANGED, accountChanged);
	}

	@Override
	protected final void onActivityResult(final int requestCode, final int resultCode, final Intent data) {
		if(resultCode != Activity.RESULT_OK) {
			return;
		}
		switch(requestCode) {
		case INTRO_ACTIVITY_RESULT:
			accountChanged = data.getBooleanExtra(IntroActivity.INTENT_ACCOUNT_CHANGED, true);
			onBackPressed();
			break;
		}
	}

	@Override
	public final void onBackPressed() {
		super.onBackPressed();

		this.setResult(Activity.RESULT_OK);
		this.finish();
	}

	@Override
	public final boolean onOptionsItemSelected(final MenuItem item) {
		switch(item.getItemId()) {
		case android.R.id.home:
			this.onBackPressed();
			return true;
		}
		return super.onOptionsItemSelected(item);
	}


	@Override
	public final boolean onIsMultiPane() {
		return isXLargeTablet(this);
	}

	private static final boolean isXLargeTablet(final Context context) {
		return (context.getResources().getConfiguration().screenLayout & Configuration.SCREENLAYOUT_SIZE_MASK) >= Configuration.SCREENLAYOUT_SIZE_XLARGE;
	}

	@Override
	@TargetApi(Build.VERSION_CODES.HONEYCOMB)
	public final void onBuildHeaders(final List<Header> target) {
		this.loadHeadersFromResource(R.xml.preferences_header, target);
	}

	@Override
	protected final boolean isValidFragment(final String fragmentName) {
		return PreferenceFragment.class.getName().equals(fragmentName) || ServerPreferenceFragment.class.getName().equals(fragmentName) || AccountPreferenceFragment.class.getName().equals(fragmentName) || AppPreferenceFragment.class.getName().equals(fragmentName);
	}

	private static final Preference.OnPreferenceChangeListener sBindPreferenceSummaryToValueListener = new Preference.OnPreferenceChangeListener() {

		@Override
		public final boolean onPreferenceChange(final Preference preference, final Object value) {
			final Resources resources = preference.getContext().getResources();
			final String string = value.toString();
			switch(preference.getKey().toLowerCase()) {
			case MainActivity.PREFERENCES_SERVER:
				preference.setSummary(TextUtils.isEmpty(string) ? resources.getString(R.string.settings_default_server) : string);
				preference.setSummary(preference.getSummary() + "\n" + resources.getString(R.string.settings_default, resources.getString(R.string.settings_default_server)));
				break;
			case MainActivity.PREFERENCES_CALENDAR:
				preference.setSummary(TextUtils.isEmpty(string) ? resources.getString(R.string.settings_default_calendar) : string);
				preference.setSummary(preference.getSummary() + "\n" + resources.getString(R.string.settings_default, resources.getString(R.string.settings_default_calendar)));
				break;
			}
			return true;
		}

	};

	private static final void bindPreferenceSummaryToValue(final Preference preference) {
		preference.setOnPreferenceChangeListener(sBindPreferenceSummaryToValueListener);
		sBindPreferenceSummaryToValueListener.onPreferenceChange(preference, PreferenceManager.getDefaultSharedPreferences(preference.getContext()).getString(preference.getKey(), ""));
	}

	private static final void setDefaultPreferencesFile(final PreferenceFragment fragment) {
		final PreferenceManager manager = fragment.getPreferenceManager();
		manager.setSharedPreferencesName(MainActivity.PREFERENCES_TITLE);
		manager.setSharedPreferencesMode(Context.MODE_PRIVATE);
	}

	@TargetApi(Build.VERSION_CODES.HONEYCOMB)
	public static class ServerPreferenceFragment extends PreferenceFragment {

		@Override
		public final void onCreate(final Bundle savedInstanceState) {
			super.onCreate(savedInstanceState);

			setDefaultPreferencesFile(this);

			this.addPreferencesFromResource(R.xml.preferences_server);
			this.setHasOptionsMenu(true);

			bindPreferenceSummaryToValue(findPreference(MainActivity.PREFERENCES_SERVER));
			bindPreferenceSummaryToValue(findPreference(MainActivity.PREFERENCES_CALENDAR));
		}

		@Override
		public final boolean onOptionsItemSelected(final MenuItem item) {
			switch(item.getItemId()) {
			case android.R.id.home:
				this.startActivity(new Intent(this.getActivity(), SettingsActivity.class));
				return true;
			}
			return super.onOptionsItemSelected(item);
		}

	}

	@TargetApi(Build.VERSION_CODES.HONEYCOMB)
	public static class AccountPreferenceFragment extends PreferenceFragment {

		@Override
		public final void onCreate(final Bundle savedInstanceState) {
			super.onCreate(savedInstanceState);

			setDefaultPreferencesFile(this);

			this.addPreferencesFromResource(R.xml.preferences_account);
			this.setHasOptionsMenu(true);

			final Activity activity = this.getActivity();
			final SharedPreferences preferences = new ObscuredSharedPreferences(activity, activity.getSharedPreferences("authentication", Context.MODE_PRIVATE));

			final Preference account = this.findPreference("account");
			account.setSummary(this.getResources().getString(R.string.settings_account, preferences.getString(AuthenticationTask.PREFERENCES_USERNAME, "")));
			account.setOnPreferenceClickListener(new Preference.OnPreferenceClickListener() {

				@Override
				public final boolean onPreferenceClick(final Preference preference) {
					final Activity activity = AccountPreferenceFragment.this.getActivity();
					final Intent intent = new Intent(activity, IntroActivity.class);
					intent.putExtra(IntroActivity.INTENT_GOTO, IntroActivity.SLIDE_PERMISSION_INTERNET);
					intent.putExtra(IntroActivity.INTENT_ALLOW_BACKWARD, false);
					activity.startActivityForResult(intent, INTRO_ACTIVITY_RESULT);
					return true;
				}
			});
		}

		@Override
		public final boolean onOptionsItemSelected(final MenuItem item) {
			switch(item.getItemId()) {
			case android.R.id.home:
				this.startActivity(new Intent(this.getActivity(), SettingsActivity.class));
				return true;
			}
			return super.onOptionsItemSelected(item);
		}

	}

	@TargetApi(Build.VERSION_CODES.HONEYCOMB)
	public static class AppPreferenceFragment extends PreferenceFragment {

		@Override
		public final void onCreate(final Bundle savedInstanceState) {
			super.onCreate(savedInstanceState);

			setDefaultPreferencesFile(this);

			this.addPreferencesFromResource(R.xml.preferences_application);
			this.setHasOptionsMenu(true);

			final SharedPreferences preferences = this.getActivity().getSharedPreferences(MainActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE);
			((CheckBoxPreference)findPreference(MainActivity.PREFERENCES_ONE_COLOR_PER_COURSE)).setChecked(preferences.getBoolean(MainActivity.PREFERENCES_ONE_COLOR_PER_COURSE, false));
		}

		@Override
		public final boolean onOptionsItemSelected(final MenuItem item) {
			switch(item.getItemId()) {
			case android.R.id.home:
				this.startActivity(new Intent(this.getActivity(), SettingsActivity.class));
				return true;
			}
			return super.onOptionsItemSelected(item);
		}

	}

}
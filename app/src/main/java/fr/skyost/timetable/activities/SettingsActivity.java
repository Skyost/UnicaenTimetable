package fr.skyost.timetable.activities;

import android.accounts.Account;
import android.accounts.AccountManager;
import android.annotation.TargetApi;
import android.app.Activity;
import android.app.NotificationManager;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.media.AudioManager;
import android.os.Build;
import android.os.Bundle;
import android.preference.Preference;
import android.preference.SwitchPreference;
import android.support.v7.app.ActionBar;
import android.preference.PreferenceFragment;
import android.preference.PreferenceManager;
import android.text.TextUtils;
import android.view.MenuItem;
import android.widget.Toast;

import org.joda.time.DateTime;

import fr.skyost.timetable.R;
import fr.skyost.timetable.receivers.ringer.RingerModeManager;
import fr.skyost.timetable.utils.AppCompatPreferenceActivity;

import java.text.DateFormat;
import java.util.List;

public class SettingsActivity extends AppCompatPreferenceActivity {

	private static final int INTRO_ACTIVITY_RESULT = 100;

	private static class BindPreferenceSummaryToValueListener implements Preference.OnPreferenceChangeListener {

		private final Activity activity;

		private BindPreferenceSummaryToValueListener(final Activity activity) {
			this.activity = activity;
		}

		@Override
		public final boolean onPreferenceChange(final Preference preference, final Object value) {
			return notifyPreferenceChange(preference, value, true);
		}

		private boolean notifyPreferenceChange(final Preference preference, final Object value, final boolean savePreference) {
			final Resources resources = preference.getContext().getResources();
			final String string = value.toString();
			switch(preference.getKey().toLowerCase()) {
			case MainActivity.PREFERENCES_SERVER:
				preference.setSummary(TextUtils.isEmpty(string) ? resources.getString(R.string.settings_default_server) : string);
				preference.setSummary(preference.getSummary() + "\n" + resources.getString(R.string.settings_default, resources.getString(R.string.settings_default_server)));
				break;
			case MainActivity.PREFERENCES_CALENDAR:
				preference.setSummary(TextUtils.isEmpty(string) ? resources.getString(R.string.settings_default_calendarname) : string);
				preference.setSummary(preference.getSummary() + "\n" + resources.getString(R.string.settings_default, resources.getString(R.string.settings_default_calendarname)));
				break;
			case MainActivity.PREFERENCES_CALENDAR_INTERVAL:
				DateTime inf = DateTime.now();
				DateTime sup = DateTime.now();

				switch(string) {
				case "1":
					inf = inf.minusMonths(1);
					sup = sup.plusMonths(1);
					break;
				case "2":
					inf = inf.minusMonths(3);
					sup = sup.plusMonths(3);
					break;
				case "3":
					inf = null;
					sup = null;
					break;
				default:
					inf = inf.minusWeeks(2);
					sup = sup.plusWeeks(2);
					break;
				}

				final DateFormat formatter = DateFormat.getDateInstance(DateFormat.MEDIUM);

				preference.setSummary(TextUtils.isEmpty(string) ? resources.getStringArray(R.array.preferences_server_calendar_interval_keys)[0] : resources.getStringArray(R.array.preferences_server_calendar_interval_keys)[Integer.valueOf(string)]);
				if(inf == null/* || sup == null*/) {
					preference.setSummary(preference.getSummary() + "\n" + resources.getString(R.string.settings_calendar_interval_description_2));
				}
				else {
					preference.setSummary(preference.getSummary() + "\n" + resources.getString(R.string.settings_calendar_interval_description_1, formatter.format(inf.toDate()), formatter.format(sup.toDate())));
				}

				if(savePreference) {
					preference.getContext().getSharedPreferences(MainActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE).edit().putBoolean(MainActivity.PREFERENCES_CHANGED_INTERVAL, true).apply();
				}
				break;
			case MainActivity.PREFERENCES_LESSONS_RINGER_MODE:
				final String[] values = resources.getStringArray(R.array.preferences_application_lessonsringermode_keys);
				final int mode = TextUtils.isEmpty(string) ? 0 : Integer.parseInt(string);

				try {
					preference.getSharedPreferences().edit().putString(preference.getKey(), string).commit();

					if(mode == 0) {
						RingerModeManager.cancel(activity);

						if(RingerModeManager.inLesson(activity)) {
							RingerModeManager.disable(activity);
						}
					}
					else {
						if(mode == 1) {
							final NotificationManager manager = (NotificationManager)activity.getSystemService(Context.NOTIFICATION_SERVICE);
							if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !manager.isNotificationPolicyAccessGranted()) {
								final Intent intent = new Intent(android.provider.Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS);
								activity.startActivityForResult(intent, 0);
								return false;
							}
						}

						RingerModeManager.schedule(activity);

						if(RingerModeManager.inLesson(activity)) {
							RingerModeManager.enable(activity);
						}
					}
				}
				catch(final Exception ex) {
					ex.printStackTrace();
					Toast.makeText(activity, ex.getClass().getName(), Toast.LENGTH_LONG).show();
				}

				preference.setSummary(values[mode]);
				break;
			}
			return true;
		}

	}

	@Override
	protected final void onCreate(final Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		final ActionBar actionBar = this.getSupportActionBar();
		if(actionBar != null) {
			actionBar.setDisplayHomeAsUpEnabled(true);
		}
	}

	@Override
	public final void onSaveInstanceState(final Bundle outState) {
		super.onSaveInstanceState(outState);
	}

	@Override
	protected final void onActivityResult(final int requestCode, final int resultCode, final Intent data) {
		if(resultCode != Activity.RESULT_OK) {
			return;
		}
		switch(requestCode) {
		case INTRO_ACTIVITY_RESULT:
			this.getSharedPreferences(MainActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE).edit().putBoolean(MainActivity.PREFERENCES_CHANGED_ACCOUNT, true).apply();
			onBackPressed();
			break;
		}
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

	@Override
	@TargetApi(Build.VERSION_CODES.HONEYCOMB)
	public final void onBuildHeaders(final List<Header> target) {
		this.loadHeadersFromResource(R.xml.preferences_header, target);
	}

	@Override
	protected final boolean isValidFragment(final String fragmentName) {
		return PreferenceFragment.class.getName().equals(fragmentName) || ServerPreferenceFragment.class.getName().equals(fragmentName) || AccountPreferenceFragment.class.getName().equals(fragmentName) || AppPreferenceFragment.class.getName().equals(fragmentName);
	}

	private static void bindPreferenceSummaryToValue(final Activity activity, final SharedPreferences preferences, final Preference preference) {
		final BindPreferenceSummaryToValueListener listener = new BindPreferenceSummaryToValueListener(activity);
		preference.setOnPreferenceChangeListener(listener);
		listener.notifyPreferenceChange(preference, preferences.getString(preference.getKey(), ""), false);
	}

	private static void setDefaultPreferencesFile(final PreferenceFragment fragment) {
		final PreferenceManager manager = fragment.getPreferenceManager();
		manager.setSharedPreferencesName(MainActivity.PREFERENCES_TITLE);
		manager.setSharedPreferencesMode(Context.MODE_PRIVATE);
	}

	private static boolean isXLargeTablet(final Context context) {
		return (context.getResources().getConfiguration().screenLayout & Configuration.SCREENLAYOUT_SIZE_MASK) >= Configuration.SCREENLAYOUT_SIZE_XLARGE;
	}

	@TargetApi(Build.VERSION_CODES.HONEYCOMB)
	public static class ServerPreferenceFragment extends PreferenceFragment {

		@Override
		public final void onCreate(final Bundle savedInstanceState) {
			super.onCreate(savedInstanceState);

			final Activity activity = this.getActivity();

			setDefaultPreferencesFile(this);

			this.addPreferencesFromResource(R.xml.preferences_server);
			this.setHasOptionsMenu(true);

			final SharedPreferences preferences = this.getActivity().getSharedPreferences(MainActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE);

			bindPreferenceSummaryToValue(activity, preferences, findPreference(MainActivity.PREFERENCES_SERVER));
			bindPreferenceSummaryToValue(activity, preferences, findPreference(MainActivity.PREFERENCES_CALENDAR));
			bindPreferenceSummaryToValue(activity, preferences, findPreference(MainActivity.PREFERENCES_CALENDAR_INTERVAL));
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

			final Account[] accounts = AccountManager.get(activity).getAccountsByType(this.getString(R.string.account_type_authority));

			final Preference account = this.findPreference("account");
			if(accounts.length > 0) {
				account.setSummary(this.getResources().getString(R.string.settings_account, accounts[0].name));
			}
			account.setOnPreferenceClickListener(new Preference.OnPreferenceClickListener() {

				@Override
				public final boolean onPreferenceClick(final Preference preference) {
					final Activity activity = AccountPreferenceFragment.this.getActivity();
					final Intent intent = new Intent(activity, IntroActivity.class);
					intent.putExtra(IntroActivity.INTENT_GOTO, IntroActivity.SLIDE_ACCOUNT);
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

			final Activity activity = this.getActivity();

			setDefaultPreferencesFile(this);

			this.addPreferencesFromResource(R.xml.preferences_application);
			this.setHasOptionsMenu(true);

			final SharedPreferences preferences = this.getActivity().getSharedPreferences(MainActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE);
			((SwitchPreference)findPreference(MainActivity.PREFERENCES_AUTOMATICALLY_COLOR_LESSONS)).setChecked(preferences.getBoolean(MainActivity.PREFERENCES_AUTOMATICALLY_COLOR_LESSONS, false));

			final Preference automaticallyToggleSilentMode = findPreference(MainActivity.PREFERENCES_LESSONS_RINGER_MODE);
			bindPreferenceSummaryToValue(activity, preferences, automaticallyToggleSilentMode);

			((SwitchPreference)findPreference(MainActivity.PREFERENCES_AUTOMATICALLY_OPEN_TODAY_PAGE)).setChecked(preferences.getBoolean(MainActivity.PREFERENCES_AUTOMATICALLY_OPEN_TODAY_PAGE, false));

			final AudioManager manager = (AudioManager)this.getActivity().getSystemService(Context.AUDIO_SERVICE);

			if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP && (manager == null || manager.isVolumeFixed())) {
				automaticallyToggleSilentMode.setEnabled(false);
			}
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
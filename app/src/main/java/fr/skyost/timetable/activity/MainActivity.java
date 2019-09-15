package fr.skyost.timetable.activity;

import android.accounts.Account;
import android.accounts.AccountManager;
import android.app.Activity;
import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.MenuItem;
import android.view.View;
import android.widget.TextView;

import androidx.annotation.IdRes;
import androidx.annotation.NonNull;
import androidx.appcompat.app.ActionBarDrawerToggle;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.core.view.GravityCompat;
import androidx.drawerlayout.widget.DrawerLayout;
import androidx.fragment.app.FragmentTransaction;

import com.google.android.gms.ads.MobileAds;
import com.google.android.material.navigation.NavigationView;
import com.google.android.material.snackbar.Snackbar;
import com.kobakei.ratethisapp.RateThisApp;

import org.joda.time.DateTimeConstants;
import org.joda.time.LocalDate;

import de.mateware.snacky.Snacky;
import fr.skyost.timetable.R;
import fr.skyost.timetable.activity.settings.SettingsActivity;
import fr.skyost.timetable.fragment.day.DayFragment;
import fr.skyost.timetable.fragment.default_.DefaultFragment;
import fr.skyost.timetable.fragment.week.WeekFragment;
import fr.skyost.timetable.receiver.MainActivitySyncReceiver;
import fr.skyost.timetable.sync.TimetableSyncService;
import fr.skyost.timetable.utils.Utils;

/**
 * The main activity.
 */

public class MainActivity extends AppCompatActivity implements NavigationView.OnNavigationItemSelectedListener {

	/**
	 * The IntroActivity result.
	 */

	public static final int INTRO_ACTIVITY_RESULT = 100;

	/**
	 * The SettingsActivity result.
	 */

	private static final int SETTINGS_ACTIVITY_RESULT = 200;

	/**
	 * The refresh timetable intent key.
	 */

	public static final String INTENT_REFRESH_TIMETABLE = "refresh-timetable";

	/**
	 * The date intent key.
	 */

	public static final String INTENT_DATE = "date";

	/**
	 * The current fragment intent key.
	 */

	public static final String INTENT_CURRENT_FRAGMENT = "current-fragment";

	/**
	 * The current displayed date.
	 */

	private LocalDate currentDate;

	/**
	 * The current displayed fragment.
	 */
	
	@IdRes
	private int currentFragment = R.id.nav_home_home;

	/**
	 * The sync receiver.
	 */

	private MainActivitySyncReceiver syncReceiver;

	@Override
	protected void onCreate(final Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main_nav);

		// We initialize AdMob.
		MobileAds.initialize(this, getString(R.string.ADMOB_APP_ID));

		// We try to get the current date by any mean.
		if(currentDate == null && getSharedPreferences(SettingsActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE).getBoolean(SettingsActivity.PREFERENCES_AUTOMATICALLY_OPEN_TODAY_PAGE, false)) {
			final int dayOfWeek = LocalDate.now().getDayOfWeek();
			currentDate = dayOfWeek == DateTimeConstants.SATURDAY || dayOfWeek == DateTimeConstants.SUNDAY ? LocalDate.now().withDayOfWeek(DateTimeConstants.MONDAY).plusWeeks(1) : LocalDate.now();
		}
		if(savedInstanceState != null && savedInstanceState.containsKey(INTENT_DATE)) {
			currentDate = LocalDate.parse(savedInstanceState.getString(INTENT_DATE));
		}
		if(getIntent().hasExtra(INTENT_DATE)) {
			currentDate = LocalDate.parse(getIntent().getStringExtra(INTENT_DATE));
			getIntent().removeExtra(INTENT_DATE);
		}

		// And we try to get the previous fragment.
		if(savedInstanceState != null && savedInstanceState.containsKey(INTENT_CURRENT_FRAGMENT)) {
			currentFragment = savedInstanceState.getInt(INTENT_CURRENT_FRAGMENT, -1);
		}

		// We load our activity.
		onTimetableFirstLoaded();

		// We have to initialize RateThisApp.
		RateThisApp.init(new RateThisApp.Config(5, 10));
		RateThisApp.onCreate(this);
		RateThisApp.showRateDialogIfNeeded(this);
	}

	@Override
	public void onSaveInstanceState(@NonNull final Bundle outState) {
		super.onSaveInstanceState(outState);
		if(currentDate != null) {
			outState.putString(INTENT_DATE, currentDate.toString("yyyy-MM-dd"));
		}
		outState.putInt(INTENT_CURRENT_FRAGMENT, currentFragment);
	}

	@Override
	protected void onResume() {
		super.onResume();
		// Let's register a BroadcastReceiver for each ended synchronization !
		syncReceiver = new MainActivitySyncReceiver(this);
		registerReceiver(syncReceiver, new IntentFilter(MainActivitySyncReceiver.INTENT_ACTION));
	}

	@Override
	protected void onPause() {
		// We can unregister our BroadcastReceiver.
		unregisterReceiver(syncReceiver);
		syncReceiver = null;
		super.onPause();
	}

	@Override
	protected void onActivityResult(final int requestCode, final int resultCode, final Intent data) {
		super.onActivityResult(requestCode, resultCode, data);

		// We first get our accounts and as always, we check if we have at least one account.
		final Account[] accounts = AccountManager.get(this).getAccountsByType(getString(R.string.account_type_authority));
		if(accounts.length == 0) {
			refreshTimetable();
			return;
		}

		switch(requestCode) {
		case INTRO_ACTIVITY_RESULT:
			if(resultCode != Activity.RESULT_OK) {
				return;
			}

			// If our IntroActivity is a result, we have to refresh our header view and our timetable.
			onTimetableFirstLoaded();
			refreshTimetable();
			break;
		case SETTINGS_ACTIVITY_RESULT:
			// If anything has changed, we have to refresh our views, preferences and timetable.
			final SharedPreferences preferences = getSharedPreferences(SettingsActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE);
			if(preferences.getBoolean(SettingsActivity.PREFERENCES_CHANGED_ACCOUNT, false)) {
				refreshTimetable();
				final NavigationView navigationView = findViewById(R.id.main_nav_view);
				if(navigationView == null) {
					break;
				}
				((TextView)navigationView.getHeaderView(0).findViewById(R.id.main_nav_header_textview_email)).setText(getString(R.string.main_nav_email, accounts[0].name));
				preferences.edit().putBoolean(SettingsActivity.PREFERENCES_CHANGED_ACCOUNT, false).apply();
			}
			if(preferences.getBoolean(SettingsActivity.PREFERENCES_CHANGED_INTERVAL, false)) {
				refreshTimetable();
				preferences.edit().putBoolean(SettingsActivity.PREFERENCES_CHANGED_INTERVAL, false).apply();
			}
			break;
		}
	}

	@Override
	public void onBackPressed() {
		// We override the onBackPressed so that we can close the drawer when the user press the back button.
		final DrawerLayout drawer = findViewById(R.id.main_nav_layout);
		if(drawer.isDrawerOpen(GravityCompat.START)) {
			drawer.closeDrawer(GravityCompat.START);
		}
		else {
			super.onBackPressed();
		}
	}

	@Override
	public boolean onNavigationItemSelected(@NonNull final MenuItem item) {
		// The switch statement is pretty easy : if the user clicks on home, we shows a "Saturday" fragment (allows to keep the selected week in memory). Otherwise we shows the corresponding fragment (or activity).
		switch(item.getItemId()) {
		case R.id.nav_home_home:
		case R.id.nav_timetable_week:
			showFragment(item.getItemId());
			break;
		case R.id.nav_timetable_monday:
			showDayFragment(currentDate.withDayOfWeek(DateTimeConstants.MONDAY));
			break;
		case R.id.nav_timetable_tuesday:
			showDayFragment(currentDate.withDayOfWeek(DateTimeConstants.TUESDAY));
			break;
		case R.id.nav_timetable_wednesday:
			showDayFragment(currentDate.withDayOfWeek(DateTimeConstants.WEDNESDAY));
			break;
		case R.id.nav_timetable_thursday:
			showDayFragment(currentDate.withDayOfWeek(DateTimeConstants.THURSDAY));
			break;
		case R.id.nav_timetable_friday:
			showDayFragment(currentDate.withDayOfWeek(DateTimeConstants.FRIDAY));
			break;
		case R.id.nav_others_settings:
			startActivityForResult(new Intent(this, SettingsActivity.class), SETTINGS_ACTIVITY_RESULT);
			break;
		case R.id.nav_others_about:
			startActivity(new Intent(this, AboutActivity.class));
			break;
		}

		// Then we can close our drawer.
		final DrawerLayout drawer = findViewById(R.id.main_nav_layout);
		drawer.closeDrawer(GravityCompat.START);
		return true;
	}

	/**
	 * Shows a fragment.
	 *
	 * @param fragment The menu ID of the fragment to show.
	 */

	public void showFragment(@IdRes final int fragment) {
		currentFragment = fragment;

		final NavigationView navigationView = findViewById(R.id.main_nav_view);
		navigationView.setCheckedItem(currentFragment);
		getSupportFragmentManager()
				.beginTransaction()
				.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_FADE)
				.replace(R.id.main_fragment_container_layout, fragment == R.id.nav_home_home ? new DefaultFragment() : new WeekFragment())
				.commitAllowingStateLoss();
	}

	/**
	 * Shows a day fragment.
	 *
	 * @param date The day to show.
	 */

	public void showDayFragment(LocalDate date) {
		// We check which day has been selected.
		final NavigationView navigationView = findViewById(R.id.main_nav_view);
		switch(date.getDayOfWeek()) {
		case DateTimeConstants.MONDAY:
			navigationView.setCheckedItem(R.id.nav_timetable_monday);
			break;
		case DateTimeConstants.TUESDAY:
			navigationView.setCheckedItem(R.id.nav_timetable_tuesday);
			break;
		case DateTimeConstants.WEDNESDAY:
			navigationView.setCheckedItem(R.id.nav_timetable_wednesday);
			break;
		case DateTimeConstants.THURSDAY:
			navigationView.setCheckedItem(R.id.nav_timetable_thursday);
			break;
		case DateTimeConstants.FRIDAY:
			navigationView.setCheckedItem(R.id.nav_timetable_friday);
			break;
		}

		// We keep it in memory.
		currentDate = date;
		currentFragment = -1;

		// And if it's possible, we show the new fragment.
		if(isFinishing() || isDestroyed()) {
			return;
		}

		getSupportFragmentManager()
				.beginTransaction()
				.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_FADE)
				.replace(R.id.main_fragment_container_layout, DayFragment.newInstance(date), date.toString("yyyy-MM-dd"))
				.commitAllowingStateLoss();
	}

	/**
	 * Triggered when the timetable has been loaded for the first time.
	 */

	private void onTimetableFirstLoaded() {
		// We start the service (if not done before).
		startService(new Intent(this, TimetableSyncService.class));

		// We set the required views.
		final Toolbar toolbar = findViewById(R.id.main_toolbar);
		setSupportActionBar(toolbar);

		final DrawerLayout drawer = findViewById(R.id.main_nav_layout);
		final ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(this, drawer, toolbar, R.string.main_nav_open, R.string.main_nav_close);
		drawer.addDrawerListener(toggle);
		toggle.syncState();

		// We get our accounts.
		final Account[] accounts = AccountManager.get(this).getAccountsByType(getString(R.string.account_type_authority));
		if(accounts.length == 0) {
			refreshTimetable();
			return;
		}

		// We hive the progress bar, register click events and show the good fragment.
		findViewById(R.id.main_progressbar).setVisibility(View.GONE);
		findViewById(R.id.main_fab).setOnClickListener(view -> refreshTimetable());
		if(currentFragment == -1) {
			showDayFragment(currentDate);
		}
		else {
			currentDate = LocalDate.now();
			if(currentDate.getDayOfWeek() == DateTimeConstants.SATURDAY || currentDate.getDayOfWeek() == DateTimeConstants.SUNDAY) {
				currentDate = currentDate.plusWeeks(1);
			}

			showFragment(currentFragment);
		}

		// We setup the navigation view.
		final String name = accounts[0].name;
		final NavigationView navigationView = findViewById(R.id.main_nav_view);
		((TextView)navigationView.getHeaderView(0).findViewById(R.id.main_nav_header_textview_email)).setText(name.contains("@") ? name : getString(R.string.main_nav_email, name));
		navigationView.setNavigationItemSelectedListener(this);

		// If we need to, we refresh the timetable (from network).
		final Intent intent = getIntent();
		if(intent.hasExtra(INTENT_REFRESH_TIMETABLE) && intent.getBooleanExtra(INTENT_REFRESH_TIMETABLE, true)) {
			refreshTimetable();
			intent.removeExtra(INTENT_REFRESH_TIMETABLE);
		}
	}

	/**
	 * Sends a synchronization request to the AccountManager.
	 * This asynchronous method will synchronize the current account (if possible) with network data.
	 */

	private void refreshTimetable() {
		final String authority = getString(R.string.account_type_authority);
		final Account[] accounts = AccountManager.get(this).getAccountsByType(authority);
		// If there is no account, we redirect the user to the login screen located in IntroActivity.
		if(accounts.length == 0) {
			final Snackbar noAccountSnackbar = Snacky.builder().setActivity(this).setText(R.string.main_snackbar_error_noaccount).warning();
			Utils.setSnackBarCallback(noAccountSnackbar, new Snackbar.Callback() {

				@Override
				public void onDismissed(final Snackbar snackbar, final int event) {
					super.onDismissed(snackbar, event);

					final Intent intent = new Intent(MainActivity.this, IntroActivity.class);
					intent.putExtra(IntroActivity.INTENT_GOTO, IntroActivity.SLIDE_ACCOUNT);
					startActivityForResult(intent, INTRO_ACTIVITY_RESULT);
				}

			});
			noAccountSnackbar.show();
			return;
		}

		final Account account = accounts[0];
		// Otherwise, if the synchronization has been turned off, we have to turn it back on !
		if(ContentResolver.getIsSyncable(account, authority) <= 0) {
			Utils.makeAccountSyncable(this, account);
		}

		// Then we have to check that a synchronization is not active.
		if(ContentResolver.isSyncActive(account, getString(R.string.account_type_authority))) {
			Snacky.builder().setActivity(this).setText(R.string.main_snackbar_error_syncactive).error().show();
			return;
		}

		// If everything is okay, we can start the synchronization.
		final Snackbar downloadSnackbar = Snacky.builder().setActivity(this).setText(R.string.main_snackbar_downloading).info();
		Utils.setSnackBarCallback(downloadSnackbar, new Snackbar.Callback() {

			@Override
			public void onDismissed(final Snackbar snackbar, final int event) {
				super.onDismissed(snackbar, event);

				// This method allows to trigger a synchronization.
				final Bundle bundle = new Bundle();
				bundle.putBoolean(ContentResolver.SYNC_EXTRAS_EXPEDITED, true);
				bundle.putBoolean(ContentResolver.SYNC_EXTRAS_MANUAL, true);
				ContentResolver.requestSync(account, getString(R.string.account_type_authority), bundle);
			}

		});
		downloadSnackbar.show();
	}

	/**
	 * Goes to the next day (MONDAY -> TUESDAY -> WEDNESDAY -> THURSDAY -> FRIDAY -> MONDAY -> ...).
	 */

	public void nextDayFragment() {
		// If we are showing the home screen, then we don't need to move anything.
		if(currentDate.getDayOfWeek() == DateTimeConstants.SATURDAY) {
			return;
		}

		// Otherwise, if we're on friday, we have to go to monday and add one week.
		if(currentDate.getDayOfWeek() == DateTimeConstants.FRIDAY) {
			showDayFragment(currentDate.withDayOfWeek(DateTimeConstants.MONDAY).plusWeeks(1));
			return;
		}

		// Else, we just have to add one day.
		showDayFragment(currentDate.plusDays(1));
	}

	/**
	 * Goes to the previous day (MONDAY <- TUESDAY <- WEDNESDAY <- THURSDAY <- FRIDAY <- MONDAY <- ...).
	 */

	public void previousDayFragment() {
		// This method is almost the same as nextDayFragment, so go read its comments !
		if(currentDate.getDayOfWeek() == DateTimeConstants.SATURDAY) {
			return;
		}
		if(currentDate.getDayOfWeek() == DateTimeConstants.MONDAY) {
			showDayFragment(currentDate.withDayOfWeek(DateTimeConstants.FRIDAY).minusWeeks(1));
			return;
		}
		showDayFragment(currentDate.minusDays(1));
	}

	/**
	 * Returns the current date.
	 *
	 * @return The current date.
	 */

	public LocalDate getCurrentDate() {
		return currentDate;
	}

}
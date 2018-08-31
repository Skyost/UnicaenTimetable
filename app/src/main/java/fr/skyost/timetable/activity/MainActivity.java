package fr.skyost.timetable.activity;

import android.accounts.Account;
import android.accounts.AccountManager;
import android.app.Activity;
import android.arch.lifecycle.Observer;
import android.arch.lifecycle.ViewModelProviders;
import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.design.widget.NavigationView;
import android.support.design.widget.Snackbar;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBarDrawerToggle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.View;
import android.widget.TextView;

import com.kobakei.ratethisapp.RateThisApp;

import org.joda.time.DateTimeConstants;
import org.joda.time.LocalDate;

import java.util.List;

import de.mateware.snacky.Snacky;
import fr.skyost.timetable.R;
import fr.skyost.timetable.activity.settings.SettingsActivity;
import fr.skyost.timetable.fragment.DefaultFragment;
import fr.skyost.timetable.fragment.day.DayFragment;
import fr.skyost.timetable.lesson.Lesson;
import fr.skyost.timetable.lesson.LessonModel;
import fr.skyost.timetable.receiver.MainActivitySyncReceiver;
import fr.skyost.timetable.utils.SwipeListener;
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
	 * The refresh timetable intent key.
	 */

	public static final String INTENT_REFRESH_TIMETABLE = "refresh-timetable";

	/**
	 * The date intent key.
	 */

	public static final String INTENT_DATE = "date";

	/**
	 * The current displayed date (SATURDAY = main screen).
	 */

	private LocalDate currentDate;

	/**
	 * The sync receiver.
	 */

	private MainActivitySyncReceiver syncReceiver;

	/**
	 * The swipe listener.
	 */

	private SwipeListener swipeListener;

	@Override
	protected void onCreate(final Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main_nav);

		// We try to get the current date by any mean.
		if(currentDate == null && getSharedPreferences(MainActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE).getBoolean(PREFERENCES_AUTOMATICALLY_OPEN_TODAY_PAGE, false)) {
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

		// We create our ViewModel.
		final LessonModel model = ViewModelProviders.of(this).get(LessonModel.class);
		model.getLessonsLiveData().observe(this, new Observer<List<Lesson>>() {

			@Override
			public void onChanged(@Nullable final List<Lesson> lessons) {
				onTimetableFirstLoaded();
				model.getLessonsLiveData().removeObserver(this);
			}
		});
		model.getLessonsLiveData().observe(this, lessons -> {
			if(currentDate.getDayOfWeek() == DateTimeConstants.SATURDAY) {
				return;
			}
			showFragment(currentDate);
		});

		// We have to initialize RateThisApp.
		RateThisApp.init(new RateThisApp.Config(5, 10));
		RateThisApp.onCreate(this);
		RateThisApp.showRateDialogIfNeeded(this);

		// We set the required views.
		final Toolbar toolbar = findViewById(R.id.main_toolbar);
		setSupportActionBar(toolbar);

		final DrawerLayout drawer = findViewById(R.id.main_nav_layout);
		final ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(this, drawer, toolbar, R.string.main_nav_open, R.string.main_nav_close);
		drawer.addDrawerListener(toggle);
		toggle.syncState();

		// And we register a swipe listener.
		swipeListener = new SwipeListener(this, this::nextDayFragment, this::previousDayFragment);

		// If there is no account, we have to start the intro activity (through refreshTimetable).
		final Account[] accounts = AccountManager.get(this).getAccountsByType(getString(R.string.account_type_authority));
		if(accounts.length == 0) {
			refreshTimetable();
		}
	}

	@Override
	public void onSaveInstanceState(final Bundle outState) {
		super.onSaveInstanceState(outState);
		if(currentDate != null) {
			outState.putString(INTENT_DATE, currentDate.toString("yyyy-MM-dd"));
		}
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
	public boolean dispatchTouchEvent(final MotionEvent event) {
		// We dispatch the touch event to the swipe listener first.
		if(swipeListener != null) {
			swipeListener.dispatchTouchEvent(event);
		}
		return super.dispatchTouchEvent(event);
	}

	@Override
	protected void onActivityResult(final int requestCode, final int resultCode, final Intent data) {
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
			((TextView)((NavigationView)findViewById(R.id.main_nav_view)).getHeaderView(0).findViewById(R.id.main_nav_header_textview_email)).setText(this.getString(R.string.main_nav_email, accounts[0].name));
			refreshTimetable();
			break;
		case SETTINGS_ACTIVITY_RESULT:
			// If anything has changed, we have to refresh our views, preferences and timetable.
			final SharedPreferences preferences = getSharedPreferences(MainActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE);
			if(preferences.getBoolean(PREFERENCES_CHANGED_ACCOUNT, false)) {
				refreshTimetable();
				final NavigationView navigationView = findViewById(R.id.main_nav_view);
				if(navigationView == null) {
					break;
				}
				((TextView)navigationView.getHeaderView(0).findViewById(R.id.main_nav_header_textview_email)).setText(getString(R.string.main_nav_email, accounts[0].name));
				preferences.edit().putBoolean(MainActivity.PREFERENCES_CHANGED_ACCOUNT, false).apply();
			}
			if(preferences.getBoolean(PREFERENCES_CHANGED_INTERVAL, false)) {
				refreshTimetable();
				preferences.edit().putBoolean(MainActivity.PREFERENCES_CHANGED_INTERVAL, false).apply();
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
			showFragment(currentDate.withDayOfWeek(DateTimeConstants.SATURDAY));
			break;
		case R.id.nav_timetable_monday:
			showFragment(currentDate.withDayOfWeek(DateTimeConstants.MONDAY));
			break;
		case R.id.nav_timetable_tuesday:
			showFragment(currentDate.withDayOfWeek(DateTimeConstants.TUESDAY));
			break;
		case R.id.nav_timetable_wednesday:
			showFragment(currentDate.withDayOfWeek(DateTimeConstants.WEDNESDAY));
			break;
		case R.id.nav_timetable_thursday:
			showFragment(currentDate.withDayOfWeek(DateTimeConstants.THURSDAY));
			break;
		case R.id.nav_timetable_friday:
			showFragment(currentDate.withDayOfWeek(DateTimeConstants.FRIDAY));
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
	 * @param date The day to show.
	 */

	public void showFragment(LocalDate date) {
		if(date == null) {
			final int dayOfWeek = LocalDate.now().getDayOfWeek();
			date = LocalDate.now().withDayOfWeek(DateTimeConstants.SATURDAY).plusWeeks(dayOfWeek == DateTimeConstants.SATURDAY || dayOfWeek == DateTimeConstants.SUNDAY ? 1 : 0);
		}

		final NavigationView navigationView = findViewById(R.id.main_nav_view);
		boolean isDay = true;

		// We check which day has been selected.
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
		default:
			navigationView.setCheckedItem(R.id.nav_home_home);
			isDay = false;
			break;
		}

		// We keep it in memory.
		currentDate = date;

		// And if it's possible, we show the new fragment.
		if(isFinishing() || isDestroyed()) {
			return;
		}

		getSupportFragmentManager()
				.beginTransaction()
				.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_FADE)
				.replace(R.id.main_fragment_container_layout, isDay ? DayFragment.newInstance(date) : new DefaultFragment(), date.toString("yyyy-MM-dd"))
				.commitAllowingStateLoss();
	}

	/**
	 * Triggered when the timetable has been loaded for the first time.
	 */

	private void onTimetableFirstLoaded() {
		// We get our accounts.
		final Account[] accounts = AccountManager.get(this).getAccountsByType(getString(R.string.account_type_authority));
		if(accounts.length == 0) {
			refreshTimetable();
			return;
		}

		// We hive the progress bar, register click events and show the good fragment.
		findViewById(R.id.main_progressbar).setVisibility(View.GONE);
		findViewById(R.id.main_fab).setOnClickListener(view -> refreshTimetable());
		showFragment(currentDate);

		// We setup the navigation view.
		final NavigationView navigationView = findViewById(R.id.main_nav_view);
		((TextView)navigationView.getHeaderView(0).findViewById(R.id.main_nav_header_textview_email)).setText(getResources().getString(R.string.main_nav_email, accounts[0].name));
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
		final Account[] accounts = AccountManager.get(this).getAccountsByType(getString(R.string.account_type_authority));
		// If there is no account, we redirect the user to the login screen located in IntroActivity.
		if(accounts.length == 0) {
			final Snackbar noAccountSnackbar = Snacky.builder().setView(findViewById(R.id.main_fab)).setText(R.string.main_snackbar_error_noaccount).warning();
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

		// Otherwise, we have to check that a synchronization is not active.
		final Account account = accounts[0];
		if(ContentResolver.isSyncActive(account, getString(R.string.account_type_authority))) {
			Snacky.builder().setView(findViewById(R.id.main_fab)).setText(R.string.main_snackbar_error_syncactive).error().show();
			return;
		}

		// If everything is okay, we can start the synchronization.
		final Snackbar downloadSnackbar = Snacky.builder().setView(findViewById(R.id.main_fab)).setText(R.string.main_snackbar_downloading).info();
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
			showFragment(currentDate.withDayOfWeek(DateTimeConstants.MONDAY).plusWeeks(1));
			return;
		}

		// Else, we just have to add one day.
		showFragment(currentDate.plusDays(1));
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
			showFragment(currentDate.withDayOfWeek(DateTimeConstants.FRIDAY).minusWeeks(1));
			return;
		}
		showFragment(currentDate.minusDays(1));
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
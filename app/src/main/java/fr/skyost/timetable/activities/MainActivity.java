package fr.skyost.timetable.activities;

import android.accounts.Account;
import android.accounts.AccountManager;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.BroadcastReceiver;
import android.content.ContentResolver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.design.widget.Snackbar;
import android.support.v4.app.FragmentTransaction;
import android.view.View;
import android.support.design.widget.NavigationView;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBarDrawerToggle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.MenuItem;
import android.widget.TextView;

import com.kobakei.ratethisapp.RateThisApp;

import org.joda.time.DateTime;
import org.joda.time.DateTimeConstants;
import org.joda.time.Weeks;

import java.io.FileNotFoundException;
import java.text.DateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.TimeUnit;

import de.mateware.snacky.Snacky;
import fr.skyost.timetable.R;
import fr.skyost.timetable.Timetable;
import fr.skyost.timetable.Timetable.Day;
import fr.skyost.timetable.fragments.DayFragment;
import fr.skyost.timetable.fragments.DefaultFragment;
import fr.skyost.timetable.tasks.AuthenticationTask;
import fr.skyost.timetable.utils.Utils;

public class MainActivity extends AppCompatActivity implements NavigationView.OnNavigationItemSelectedListener {

	private static final int INTRO_ACTIVITY_RESULT = 100;
	private static final int SETTINGS_ACTIVITY_RESULT = 200;

	@Deprecated
	public static final String PREFERENCES_LAST_UPDATE = "last-update";

	public static final String PREFERENCES_TITLE = "preferences";
	public static final String PREFERENCES_SERVER = "server";
	public static final String PREFERENCES_CALENDAR = "calendar-nohtml";
	public static final String PREFERENCES_CALENDAR_INTERVAL = "calendar-interval";
	public static final String PREFERENCES_AUTOMATICALLY_COLOR_LESSONS = "color-lessons-automatically";
	public static final String PREFERENCES_AUTOMATICALLY_OPEN_TODAY_PAGE = "today-automatically";
	public static final String PREFERENCES_LESSONS_RINGER_MODE = "lessons-ringer-mode";
	public static final String PREFERENCES_TIP_SHOW_PINCHTOZOOM = "tip-show-pinchtozoom";
	public static final String PREFERENCES_TIP_SHOW_CHANGECOLOR = "tip-show-changecolor";
	public static final String PREFERENCES_CHANGED_ACCOUNT = "changed-account";
	public static final String PREFERENCES_CHANGED_INTERVAL = "changed-interval";

	public static final String INTENT_TIMETABLE = "timetable";
	public static final String INTENT_REFRESH_TIMETABLE = "refresh-timetable";
	public static final String INTENT_CURRENT_FRAGMENT = "current-fragment";
	public static final String INTENT_DATE = "date";
	public static final String INTENT_BASEWEEK = "base-week";
	public static final String INTENT_SELECTED = "selected";

	public static final String INTENT_SYNC_FINISHED = "sync-finished";
	public static final String INTENT_SYNC_TIMETABLE = "sync-timetable";
	public static final String INTENT_SYNC_RESULT = "sync-result";

	private Timetable timetable;
	public int baseWeek = -1;
	public int currentMenuSelected = -1;

	private final BroadcastReceiver syncReceiver = new BroadcastReceiver() {

		@Override
		public final void onReceive(final Context context, final Intent intent) {
			setTimetable((Timetable)intent.getParcelableExtra(INTENT_SYNC_TIMETABLE), false);
			if(!intent.getBooleanExtra(ContentResolver.SYNC_EXTRAS_MANUAL, false)) {
				return;
			}
			intent.removeExtra(ContentResolver.SYNC_EXTRAS_MANUAL);
			switch(intent.getIntExtra(INTENT_SYNC_RESULT, AuthenticationTask.ERROR)) {
			case AuthenticationTask.SUCCESS:
				Snacky.builder().setView(MainActivity.this.findViewById(R.id.main_fab)).setText(R.string.main_snackbar_success).success().show();
				baseWeek = -1;
				showFragment(currentMenuSelected);
				break;
			case AuthenticationTask.NOT_FOUND:
				if(MainActivity.this.isFinishing()) {
					break;
				}
				final AlertDialog.Builder builder = new AlertDialog.Builder(MainActivity.this);
				builder.setTitle(R.string.dialog_error_notfound_title);
				builder.setMessage(R.string.dialog_error_notfound_message);
				builder.setPositiveButton(R.string.dialog_generic_button_positive, new DialogInterface.OnClickListener() {

					@Override
					public final void onClick(final DialogInterface dialog, final int id) {
						dialog.dismiss();
					}

				});
				builder.create().show();
				break;
			case AuthenticationTask.UNAUTHORIZED: {
				final Snackbar snackbar = Snacky.builder().setView(MainActivity.this.findViewById(R.id.main_fab)).setText(R.string.main_snackbar_error_credentials).warning();
				final Snackbar.Callback callback = new Snackbar.Callback() {

					@Override
					public final void onDismissed(final Snackbar snackbar, final int event) {
						super.onDismissed(snackbar, event);
						final Intent intent = new Intent(MainActivity.this, IntroActivity.class);
						intent.putExtra(IntroActivity.INTENT_GOTO, IntroActivity.SLIDE_ACCOUNT);
						MainActivity.this.startActivityForResult(intent, INTRO_ACTIVITY_RESULT);
					}

				};
				if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.N_MR1) {
					snackbar.addCallback(callback);
				}
				else {
					snackbar.setCallback(callback);
				}
				snackbar.show();
				break;
			}
			case AuthenticationTask.ERROR:
				Snacky.builder().setView(MainActivity.this.findViewById(R.id.main_fab)).setText(R.string.main_snackbar_error_network).error().show();
				break;
			}
		}

	};

	@Override
	protected final void onCreate(final Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		RateThisApp.init(new RateThisApp.Config(5, 10));
		RateThisApp.onCreate(this);

		final Account[] accounts = AccountManager.get(this).getAccountsByType(this.getString(R.string.account_type_authority));
		if(accounts.length == 0) {
			this.startActivityForResult(new Intent(this, IntroActivity.class), INTRO_ACTIVITY_RESULT);
		}
		else {
			RateThisApp.showRateDialogIfNeeded(this);
		}

		this.setContentView(R.layout.activity_main_nav);

		if(savedInstanceState != null) {
			timetable = savedInstanceState.getParcelable(INTENT_TIMETABLE);
			baseWeek = savedInstanceState.getInt(INTENT_BASEWEEK, -1);
			currentMenuSelected = savedInstanceState.getInt(INTENT_SELECTED, -1);
		}
		else if(baseWeek == -1 && currentMenuSelected == -1 && this.getSharedPreferences(MainActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE).getBoolean(PREFERENCES_AUTOMATICALLY_OPEN_TODAY_PAGE, false)) {
			currentMenuSelected = Day.today().getValue();
		}

		if(accounts.length > 0 && timetable == null) {
			loadTimetableFromDisk();
		}

		final Toolbar toolbar = this.findViewById(R.id.main_toolbar);
		this.setSupportActionBar(toolbar);

		this.findViewById(R.id.main_fab).setOnClickListener(new View.OnClickListener() {

			@Override
			public final void onClick(final View view) {
				refreshTimetable();
			}

		});

		final DrawerLayout drawer = this.findViewById(R.id.main_nav_layout);
		final ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(this, drawer, toolbar, R.string.main_nav_open, R.string.main_nav_close);
		drawer.addDrawerListener(toggle);
		toggle.syncState();

		String username = String.valueOf(Calendar.getInstance().get(Calendar.YEAR)).replace("0", "") + "00000";
		if(accounts.length > 0) {
			username = accounts[0].name;
			if(!ContentResolver.isSyncActive(accounts[0], this.getString(R.string.account_type_authority))) {
				Utils.makeAccountSyncable(this, accounts[0]);
			}
		}

		final NavigationView navigationView = this.findViewById(R.id.main_nav_view);
		((TextView)navigationView.getHeaderView(0).findViewById(R.id.main_nav_header_textview_email)).setText(this.getResources().getString(R.string.main_nav_email, username));
		navigationView.setNavigationItemSelectedListener(this);

		final Intent intent = this.getIntent();
		if(intent.hasExtra(INTENT_CURRENT_FRAGMENT)) {
			showFragment(intent.getIntExtra(INTENT_CURRENT_FRAGMENT, -1));
			intent.removeExtra(INTENT_CURRENT_FRAGMENT);
		}
		else if(intent.hasExtra(INTENT_DATE)) {
			final DateTime target = new DateTime(intent.getLongExtra(INTENT_DATE, System.currentTimeMillis()));

			final Calendar now = Calendar.getInstance();
			int day = now.get(Calendar.DAY_OF_WEEK);
			if(day == Calendar.SATURDAY) {
				now.setTimeInMillis(now.getTimeInMillis() + TimeUnit.DAYS.toMillis(2));
			}
			else if(day == Calendar.SUNDAY) {
				now.setTimeInMillis(now.getTimeInMillis() + TimeUnit.DAYS.toMillis(1));
			}
			else {
				now.set(Calendar.DAY_OF_WEEK, Calendar.MONDAY);
			}

			now.set(Calendar.HOUR_OF_DAY, 0);
			now.set(Calendar.MINUTE, 0);
			now.set(Calendar.SECOND, 0);
			now.set(Calendar.MILLISECOND, 0);

			final DateTime start = new DateTime(timetable.getStartDate()).withDayOfWeek(DateTimeConstants.MONDAY).withTime(0, 0, 0, 0);

			final int betweenNowTarget = Weeks.weeksBetween(new DateTime(now), target).getWeeks();
			int betweenStartTarget = Weeks.weeksBetween(start, target).getWeeks();

			baseWeek = betweenNowTarget == 0 ? -1 : betweenStartTarget;

			showFragment(target.toCalendar(Locale.getDefault()).get(Calendar.DAY_OF_WEEK));
			intent.removeExtra(INTENT_DATE);
		}
		else {
			showFragment(currentMenuSelected);
		}

		if(intent.hasExtra(INTENT_REFRESH_TIMETABLE) && intent.getBooleanExtra(INTENT_REFRESH_TIMETABLE, true)) {
			refreshTimetable();
			intent.removeExtra(INTENT_REFRESH_TIMETABLE);
		}
	}

	@Override
	public final void onSaveInstanceState(final Bundle outState) {
		super.onSaveInstanceState(outState);
		outState.putParcelable(INTENT_TIMETABLE, timetable);
		outState.putInt(INTENT_BASEWEEK, baseWeek);
		outState.putInt(INTENT_SELECTED, currentMenuSelected);
	}

	@Override
	protected final void onResume() {
		super.onResume();
		this.registerReceiver(syncReceiver, new IntentFilter(INTENT_SYNC_FINISHED));
	}

	@Override
	protected final void onPause() {
		this.unregisterReceiver(syncReceiver);
		super.onPause();
	}

	@Override
	protected final void onActivityResult(final int requestCode, final int resultCode, final Intent data) {
		final Account[] accounts = AccountManager.get(this).getAccountsByType(this.getString(R.string.account_type_authority));
		switch(requestCode) {
		case INTRO_ACTIVITY_RESULT:
			if(resultCode != Activity.RESULT_OK) {
				return;
			}
			((TextView)((NavigationView)this.findViewById(R.id.main_nav_view)).getHeaderView(0).findViewById(R.id.main_nav_header_textview_email)).setText(accounts.length < 1 ? this.getString(R.string.main_noaccount) : this.getString(R.string.main_nav_email, accounts[0].name));
			refreshTimetable();
			break;
		case SETTINGS_ACTIVITY_RESULT:
			final SharedPreferences preferences = this.getSharedPreferences(MainActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE);
			if(preferences.getBoolean(PREFERENCES_CHANGED_ACCOUNT, false)) {
				refreshTimetable();
				final NavigationView navigationView = this.findViewById(R.id.main_nav_view);
				if(navigationView == null) {
					break;
				}
				((TextView)navigationView.getHeaderView(0).findViewById(R.id.main_nav_header_textview_email)).setText(accounts.length < 1 ? this.getString(R.string.main_noaccount) : this.getString(R.string.main_nav_email, accounts[0].name));
				preferences.edit().putBoolean(MainActivity.PREFERENCES_CHANGED_ACCOUNT, false).apply();
			}
			if(preferences.getBoolean(PREFERENCES_CHANGED_INTERVAL, false)) {
				refreshTimetable();
				preferences.edit().putBoolean(MainActivity.PREFERENCES_CHANGED_INTERVAL, false).apply();
			}
			showFragment(currentMenuSelected);
			break;
		}
	}

	@Override
	public final void onBackPressed() {
		final DrawerLayout drawer = this.findViewById(R.id.main_nav_layout);
		if(drawer.isDrawerOpen(GravityCompat.START)) {
			drawer.closeDrawer(GravityCompat.START);
		}
		else {
			super.onBackPressed();
		}
	}

	@Override
	public final boolean onNavigationItemSelected(@NonNull final MenuItem item) {
		switch(item.getItemId()) {
		case R.id.nav_home_home:
			showFragment(-1);
			break;
		case R.id.nav_week_selector:
			if(timetable == null) {
				final AlertDialog.Builder builder = new AlertDialog.Builder(MainActivity.this);
				builder.setTitle(R.string.dialog_error_notimetable_title);
				builder.setMessage(R.string.dialog_error_notimetable_message);
				builder.setPositiveButton(R.string.dialog_generic_button_positive, new DialogInterface.OnClickListener() {

					@Override
					public final void onClick(final DialogInterface dialog, final int id) {
						dialog.dismiss();
					}

				});
				builder.create().show();
				break;
			}
			final List<DateTime> availableWeeks = timetable.getAvailableWeeks();
			final List<String> dialogData = new ArrayList<>();

			final DateFormat dateFormat = DateFormat.getDateInstance(DateFormat.MEDIUM);
			for(final DateTime availableWeek : availableWeeks) {
				dialogData.add(dateFormat.format(availableWeek.withDayOfWeek(DateTimeConstants.MONDAY).toDate()) + " - " + dateFormat.format(availableWeek.withDayOfWeek(DateTimeConstants.FRIDAY).toDate()));
			}
			dialogData.add(0, this.getString(R.string.dialog_weekselector_default));

			final AlertDialog.Builder builder = new AlertDialog.Builder(this);
			builder.setTitle(R.string.main_nav_week_selector);
			builder.setSingleChoiceItems(dialogData.toArray(new String[dialogData.size()]), baseWeek + 1, new DialogInterface.OnClickListener() {

				@Override
				public final void onClick(final DialogInterface dialog, final int id) {
					baseWeek = id - 1;
					dialog.dismiss();
					showFragment(currentMenuSelected);
				}

			});
			builder.create().show();
			break;
		case R.id.nav_timetable_monday:
			showFragment(Day.MONDAY);
			break;
		case R.id.nav_timetable_tuesday:
			showFragment(Day.TUESDAY);
			break;
		case R.id.nav_timetable_wednesday:
			showFragment(Day.WEDNESDAY);
			break;
		case R.id.nav_timetable_thursday:
			showFragment(Day.THURSDAY);
			break;
		case R.id.nav_timetable_friday:
			showFragment(Day.FRIDAY);
			break;
		case R.id.nav_others_settings:
			this.startActivityForResult(new Intent(this, SettingsActivity.class), SETTINGS_ACTIVITY_RESULT);
			break;
		case R.id.nav_others_about:
			this.startActivity(new Intent(this, AboutActivity.class));
			break;
		}
		final DrawerLayout drawer = this.findViewById(R.id.main_nav_layout);
		drawer.closeDrawer(GravityCompat.START);
		return true;
	}

	/**
	 * Shows a fragment.
	 *
	 * @param menuIndex -1 to show the home screen, or a Day value.
	 */

	public final void showFragment(final int menuIndex) {
		showFragment(menuIndex == -1 ? null : Day.getByValue(menuIndex));
	}

	/**
	 * Shows a fragment.
	 *
	 * @param day null to show the home screen, or a Day to show the specific calendar.
	 */

	public final void showFragment(final Day day) {
		currentMenuSelected = day == null ? -1 : day.getValue();

		final NavigationView navigationView = this.findViewById(R.id.main_nav_view);
		if(day == null) {
			navigationView.setCheckedItem(R.id.nav_home_home);
		}
		else {
			switch(day) {
			case MONDAY:
				navigationView.setCheckedItem(R.id.nav_timetable_monday);
				break;
			case TUESDAY:
				navigationView.setCheckedItem(R.id.nav_timetable_tuesday);
				break;
			case WEDNESDAY:
				navigationView.setCheckedItem(R.id.nav_timetable_wednesday);
				break;
			case THURSDAY:
				navigationView.setCheckedItem(R.id.nav_timetable_thursday);
				break;
			case FRIDAY:
				navigationView.setCheckedItem(R.id.nav_timetable_friday);
				break;
			}
		}

		if(this.isFinishing() || this.isDestroyed()) {
			return;
		}

		final FragmentTransaction transaction = this.getSupportFragmentManager().beginTransaction();
		transaction.replace(R.id.main_fragment_container_layout, currentMenuSelected == -1 ? new DefaultFragment() : DayFragment.newInstance(day), String.valueOf(currentMenuSelected));
		transaction.commitAllowingStateLoss();
	}

	/**
	 * Refresh the current timetable.
	 */

	public final void refreshTimetable() {
		final Account[] accounts = AccountManager.get(MainActivity.this).getAccountsByType(MainActivity.this.getString(R.string.account_type_authority));
		if(accounts.length < 1) {
			final Snackbar noAccountSnackbar = Snacky.builder().setView(MainActivity.this.findViewById(R.id.main_fab)).setText(R.string.main_snackbar_error_noaccount).warning();
			final Snackbar.Callback callback = new Snackbar.Callback() {

				@Override
				public final void onDismissed(final Snackbar snackbar, final int event) {
					super.onDismissed(snackbar, event);
					final Intent intent = new Intent(MainActivity.this, IntroActivity.class);
					intent.putExtra(IntroActivity.INTENT_GOTO, IntroActivity.SLIDE_ACCOUNT);
					MainActivity.this.startActivityForResult(intent, INTRO_ACTIVITY_RESULT);
				}

			};
			if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.N_MR1) {
				noAccountSnackbar.addCallback(callback);
			}
			else {
				noAccountSnackbar.setCallback(callback);
			}
			noAccountSnackbar.show();
			return;
		}

		final Account account = accounts[0];
		if(ContentResolver.isSyncActive(account, MainActivity.this.getString(R.string.account_type_authority))) {
			Snacky.builder().setView(this.findViewById(R.id.main_fab)).setText(R.string.main_snackbar_error_syncactive).error();
			return;
		}

		final Snackbar downloadSnackbar = Snacky.builder().setView(this.findViewById(R.id.main_fab)).setText(R.string.main_snackbar_downloading).info();
		final Snackbar.Callback callback = new Snackbar.Callback() {

			@Override
			public final void onDismissed(final Snackbar snackbar, final int event) {
				super.onDismissed(snackbar, event);

				final Bundle bundle = new Bundle();
				bundle.putBoolean(ContentResolver.SYNC_EXTRAS_EXPEDITED, true);
				bundle.putBoolean(ContentResolver.SYNC_EXTRAS_MANUAL, true);
				ContentResolver.requestSync(account, MainActivity.this.getString(R.string.account_type_authority), bundle);
			}

		};
		if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.N_MR1) {
			downloadSnackbar.addCallback(callback);
		}
		else {
			downloadSnackbar.setCallback(callback);
		}
		downloadSnackbar.show();
	}

	/**
	 * Gets the current timetable.
	 *
	 * @return The current timetable.
	 */

	public final Timetable getTimetable() {
		return timetable;
	}

	/**
	 * Sets the timetable.
	 *
	 * @param timetable The timetable.
	 */

	public final void setTimetable(final Timetable timetable) {
		setTimetable(timetable, true);
	}

	/**
	 * Sets the timetable.
	 *
	 * @param timetable The timetable.
	 * @param refreshFragment Whether the current fragment should be refreshed.
	 */

	public final void setTimetable(final Timetable timetable, final boolean refreshFragment) {
		if(timetable == null) {
			return;
		}
		this.timetable = timetable;
		if(refreshFragment) {
			showFragment(currentMenuSelected);
		}
	}

	/**
	 * Loads the timetable from the disk.
	 */

	public final void loadTimetableFromDisk() {
		try {
			final Timetable timetable = Timetable.loadFromDisk(this);
			setTimetable(timetable);
		}
		catch(final FileNotFoundException ex) {
			refreshTimetable();
		}
		catch(final Exception ex) {
			ex.printStackTrace();
			Snackbar.make(this.findViewById(R.id.main_fab), R.string.main_snackbar_error_loadfromdisk, Snackbar.LENGTH_SHORT).show();
		}
	}

}
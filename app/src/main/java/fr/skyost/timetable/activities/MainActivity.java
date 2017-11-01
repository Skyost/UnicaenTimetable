package fr.skyost.timetable.activities;

import android.accounts.Account;
import android.accounts.AccountManager;
import android.app.Activity;
import android.app.AlertDialog;
import android.appwidget.AppWidgetManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.res.Resources;
import android.os.Build;
import android.os.Bundle;
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
import android.widget.RemoteViews;
import android.widget.TextView;

import org.joda.time.DateTime;
import org.joda.time.DateTimeConstants;

import java.io.FileNotFoundException;
import java.text.DateFormat;
import java.util.ArrayList;
import java.util.List;

import fr.skyost.timetable.R;
import fr.skyost.timetable.Timetable;
import fr.skyost.timetable.Timetable.Day;
import fr.skyost.timetable.fragments.DayFragment;
import fr.skyost.timetable.fragments.DefaultFragment;
import fr.skyost.timetable.receivers.TodayWidgetReceiver;
import fr.skyost.timetable.tasks.AuthenticationTask;
import fr.skyost.timetable.tasks.CalendarTask;
import fr.skyost.timetable.tasks.CalendarTask.CalendarTaskListener;

public class MainActivity extends AppCompatActivity implements CalendarTaskListener, NavigationView.OnNavigationItemSelectedListener {

	private static final int INTRO_ACTIVITY_RESULT = 100;
	private static final int SETTINGS_ACTIVITY_RESULT = 200;

	public static final String PREFERENCES_TITLE = "preferences";
	public static final String PREFERENCES_SHOW_INTRO = "show-intro";
	public static final String PREFERENCES_SERVER = "server";
	public static final String PREFERENCES_CALENDAR = "calendar-nohtml";
	public static final String PREFERENCES_CALENDAR_INTERVAL = "calendar-interval";
	public static final String PREFERENCES_LAST_UPDATE = "last-update";
	public static final String PREFERENCES_AUTOMATICALLY_COLOR_LESSONS = "color-lessons-automatically";
	public static final String PREFERENCES_TIP_SHOW_PINCHTOZOOM = "tip-show-pinchtozoom";
	public static final String PREFERENCES_TIP_SHOW_CHANGECOLOR = "tip-show-changecolor";
	public static final String PREFERENCES_CHANGED_ACCOUNT = "changed-account";
	public static final String PREFERENCES_CHANGED_INTERVAL = "changed-interval";

	public static final String INTENT_TIMETABLE = "timetable";
	public static final String INTENT_REFRESH_TIMETABLE = "refresh-timetable";
	public static final String INTENT_CURRENT_FRAGMENT = "current-fragment";
	public static final String INTENT_BASEWEEK = "base-week";
	public static final String INTENT_SELECTED = "selected";

	private Timetable timetable;
	public int baseWeek = -1;
	public int currentMenuSelected = -1;

	@Override
	protected final void onCreate(final Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		final Account[] accounts = AccountManager.get(this).getAccountsByType(this.getString(R.string.account_type));
		final SharedPreferences preferences = this.getSharedPreferences(PREFERENCES_TITLE, Context.MODE_PRIVATE);
		final SharedPreferences authentication = this.getSharedPreferences(AuthenticationTask.PREFERENCES_FILE, Context.MODE_PRIVATE);
		boolean showIntro = preferences.getBoolean(PREFERENCES_SHOW_INTRO, true) || (accounts.length == 0 && (authentication.contains(AuthenticationTask.PREFERENCES_USERNAME) || authentication.contains(AuthenticationTask.PREFERENCES_PASSWORD)));

		if(showIntro) {
			this.startActivityForResult(new Intent(this, IntroActivity.class), INTRO_ACTIVITY_RESULT);
		}

		this.setContentView(R.layout.activity_main_nav);

		if(savedInstanceState != null) {
			timetable = (Timetable)savedInstanceState.getSerializable(INTENT_TIMETABLE);
			baseWeek = savedInstanceState.getInt(INTENT_BASEWEEK, -1);
			currentMenuSelected = savedInstanceState.getInt(INTENT_SELECTED, -1);
		}
		if(!showIntro && timetable == null) {
			loadTimetableFromDisk();
		}

		final Toolbar toolbar = (Toolbar)findViewById(R.id.main_toolbar);
		this.setSupportActionBar(toolbar);

		this.findViewById(R.id.main_fab).setOnClickListener(new View.OnClickListener() {

			@Override
			public final void onClick(final View view) {
				refreshTimetable();
			}

		});

		final DrawerLayout drawer = (DrawerLayout)findViewById(R.id.main_nav_layout);
		final ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(this, drawer, toolbar, R.string.main_nav_open, R.string.main_nav_close);
		drawer.addDrawerListener(toggle);
		toggle.syncState();

		final String username = accounts.length > 0 ? accounts[0].name : "21700000";

		final NavigationView navigationView = (NavigationView)this.findViewById(R.id.main_nav_view);
		((TextView)navigationView.getHeaderView(0).findViewById(R.id.main_nav_header_textview_email)).setText(this.getResources().getString(R.string.main_nav_email, username));
		navigationView.setNavigationItemSelectedListener(this);

		final Intent intent = this.getIntent();
		if(intent.hasExtra(INTENT_REFRESH_TIMETABLE) && intent.getBooleanExtra(INTENT_REFRESH_TIMETABLE, true)) {
			refreshTimetable();
			intent.removeExtra(INTENT_REFRESH_TIMETABLE);
		}
		if(intent.hasExtra(INTENT_CURRENT_FRAGMENT)) {
			showFragment(intent.getIntExtra(INTENT_CURRENT_FRAGMENT, -1));
			intent.removeExtra(INTENT_CURRENT_FRAGMENT);
		}
		else {
			showFragment(currentMenuSelected);
		}
	}

	@Override
	public final void onSaveInstanceState(final Bundle outState) {
		super.onSaveInstanceState(outState);
		outState.putSerializable(INTENT_TIMETABLE, timetable);
		outState.putInt(INTENT_BASEWEEK, baseWeek);
		outState.putInt(INTENT_SELECTED, currentMenuSelected);
	}

	@Override
	protected final void onActivityResult(final int requestCode, final int resultCode, final Intent data) {
		final Account[] accounts = AccountManager.get(this).getAccountsByType(this.getString(R.string.account_type));
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
				final NavigationView navigationView = (NavigationView)this.findViewById(R.id.main_nav_view);
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
		final DrawerLayout drawer = (DrawerLayout)this.findViewById(R.id.main_nav_layout);
		if(drawer.isDrawerOpen(GravityCompat.START)) {
			drawer.closeDrawer(GravityCompat.START);
		}
		else {
			super.onBackPressed();
		}
	}

	@Override
	public final boolean onNavigationItemSelected(final MenuItem item) {
		switch(item.getItemId()) {
		case R.id.nav_home_home:
			showFragment(-1);
			break;
		case R.id.nav_week_selector:
			final List<DateTime> availableWeeks = timetable.getAvailableWeeks();
			final List<String> dialogData = new ArrayList<String>();

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
		final DrawerLayout drawer = (DrawerLayout)findViewById(R.id.main_nav_layout);
		drawer.closeDrawer(GravityCompat.START);
		return true;
	}

	@Override
	public final void onCalendarTaskStarted() {
		Snackbar.make(this.findViewById(R.id.main_fab), R.string.main_snackbar_downloading, Snackbar.LENGTH_SHORT).show();
	}

	@Override
	public final void onCalendarResult(final CalendarTask.Response response) {
		if(response.ex != null) {
			response.ex.printStackTrace();
		}
		setTimetable(response.timetable);
		if(response.timetable != null) {
			saveTimetableOnDisk();
		}
		switch(response.result) {
		case AuthenticationTask.SUCCESS:
			Snackbar.make(this.findViewById(R.id.main_fab), R.string.main_snackbar_success, Snackbar.LENGTH_SHORT).show();
			baseWeek = -1;
			showFragment(currentMenuSelected);

			final Intent updateIntent = new Intent();
			updateIntent.setAction(AppWidgetManager.ACTION_APPWIDGET_UPDATE);
			updateIntent.putExtra(TodayWidgetReceiver.INTENT_REFRESH_WIDGETS, true);
			this.sendBroadcast(updateIntent);
			break;
		case AuthenticationTask.NO_ACCOUNT: {
			final Snackbar snackbar = Snackbar.make(this.findViewById(R.id.main_fab), R.string.main_snackbar_error_noaccount, Snackbar.LENGTH_SHORT);
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
		case AuthenticationTask.NOT_FOUND:
			final AlertDialog.Builder builder = new AlertDialog.Builder(this);
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
			final Snackbar snackbar = Snackbar.make(this.findViewById(R.id.main_fab), R.string.main_snackbar_error_credentials, Snackbar.LENGTH_SHORT);
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
			Snackbar.make(this.findViewById(R.id.main_fab), R.string.main_snackbar_error_network, Snackbar.LENGTH_SHORT).show();
			break;
		}
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
		final NavigationView navigationView = (NavigationView)this.findViewById(R.id.main_nav_view);
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
		if(!this.isFinishing() && !this.isDestroyed()) {
			final FragmentTransaction transaction = this.getSupportFragmentManager().beginTransaction();
			transaction.replace(R.id.main_fragment_container_layout, currentMenuSelected == -1 ? new DefaultFragment() : DayFragment.newInstance(day), String.valueOf(currentMenuSelected));
			transaction.commitAllowingStateLoss();
		}

	}

	/**
	 * Refresh the current timetable.
	 */

	public final void refreshTimetable() {
		new CalendarTask(this, this).execute();
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
		if(timetable == null) {
			return;
		}
		this.timetable = timetable;
		showFragment(currentMenuSelected);
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

	/**
	 * Saves the timetable on the disk.
	 */

	public final void saveTimetableOnDisk() {
		if(timetable == null) {
			return;
		}
		try {
			timetable.saveOnDisk(this);

			final long updateTime = System.currentTimeMillis();
			final SharedPreferences preferences = this.getSharedPreferences(PREFERENCES_TITLE, Context.MODE_PRIVATE);
			preferences.edit().putLong(PREFERENCES_LAST_UPDATE, updateTime).apply();
		}
		catch(final Exception ex) {
			ex.printStackTrace();
			Snackbar.make(this.findViewById(R.id.main_fab), R.string.main_snackbar_error_saveondisk, Snackbar.LENGTH_SHORT).show();
		}
	}

}
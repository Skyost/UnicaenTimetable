package fr.skyost.timetable.activities;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
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
import android.widget.TextView;

import fr.skyost.timetable.R;
import fr.skyost.timetable.Timetable;
import fr.skyost.timetable.Timetable.Day;
import fr.skyost.timetable.fragments.DayFragment;
import fr.skyost.timetable.fragments.DefaultFragment;
import fr.skyost.timetable.tasks.AuthenticationTask;
import fr.skyost.timetable.tasks.CalendarTask;
import fr.skyost.timetable.tasks.CalendarTask.CalendarTaskListener;
import fr.skyost.timetable.utils.ObscuredSharedPreferences;

public class MainActivity extends AppCompatActivity implements CalendarTaskListener, NavigationView.OnNavigationItemSelectedListener {

	private static final int INTRO_ACTIVITY_RESULT = 100;
	private static final int SETTINGS_ACTIVITY_RESULT = 200;

	public static final String PREFERENCES_TITLE = "preferences";
	public static final String PREFERENCES_SHOW_INTRO = "show-intro";
	public static final String PREFERENCES_SERVER = "server";
	public static final String PREFERENCES_CALENDAR = "calendar";

	public static final String INTENT_TIMETABLE = "timetable";
	public static final String INTENT_SELECTED = "selected";

	private Timetable timetable;
	private int currentMenuSelected = -1;

	@Override
	protected final void onCreate(final Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		final SharedPreferences preferences = this.getSharedPreferences(PREFERENCES_TITLE, Context.MODE_PRIVATE);
		boolean showIntro = preferences.getBoolean(PREFERENCES_SHOW_INTRO, true);
		if(showIntro) {
			this.startActivityForResult(new Intent(this, IntroActivity.class), INTRO_ACTIVITY_RESULT);
		}

		this.setContentView(R.layout.activity_main_nav);

		if(savedInstanceState != null) {
			timetable = (Timetable)savedInstanceState.getSerializable(INTENT_TIMETABLE);
			currentMenuSelected = savedInstanceState.getInt(INTENT_SELECTED, -1);
		}
		if(!showIntro && timetable == null) {
			refreshTimetable();
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

		final String username = new ObscuredSharedPreferences(this, getSharedPreferences(AuthenticationTask.PREFERENCES_FILE, Context.MODE_PRIVATE)).getString(AuthenticationTask.PREFERENCES_USERNAME, "xxxxxxxx");
		final NavigationView navigationView = (NavigationView)this.findViewById(R.id.main_nav_view);
		((TextView)navigationView.getHeaderView(0).findViewById(R.id.main_nav_header_textview_email)).setText(this.getResources().getString(R.string.main_nav_email, username));
		navigationView.setNavigationItemSelectedListener(this);

		showFragment(currentMenuSelected);
	}

	@Override
	public final void onSaveInstanceState(final Bundle outState) {
		super.onSaveInstanceState(outState);
		outState.putSerializable(INTENT_TIMETABLE, timetable);
		outState.putInt(INTENT_SELECTED, currentMenuSelected);
	}

	@Override
	protected final void onActivityResult(final int requestCode, final int resultCode, final Intent data) {
		final String username = new ObscuredSharedPreferences(this, getSharedPreferences(AuthenticationTask.PREFERENCES_FILE, Context.MODE_PRIVATE)).getString(AuthenticationTask.PREFERENCES_USERNAME, "xxxxxxxx");
		switch(requestCode) {
		case INTRO_ACTIVITY_RESULT:
			if(resultCode != Activity.RESULT_OK) {
				return;
			}
			((TextView)((NavigationView)this.findViewById(R.id.main_nav_view)).getHeaderView(0).findViewById(R.id.main_nav_header_textview_email)).setText(this.getResources().getString(R.string.main_nav_email, username));
			refreshTimetable();
			break;
		case SETTINGS_ACTIVITY_RESULT:
			if(SettingsActivity.accountChanged) {
				refreshTimetable();
				final NavigationView navigationView = (NavigationView)this.findViewById(R.id.main_nav_view);
				if(navigationView == null) {
					break;
				}
				((TextView)navigationView.getHeaderView(0).findViewById(R.id.main_nav_header_textview_email)).setText(this.getResources().getString(R.string.main_nav_email, username));
				SettingsActivity.accountChanged = false;
			}
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
	public final void onCalendarResult(final int result, final Timetable timetable, final Exception exception) {
		if(exception != null) {
			exception.printStackTrace();
		}
		setTimetable(timetable);
		switch(result) {
		case AuthenticationTask.SUCCESS:
			Snackbar.make(this.findViewById(R.id.main_fab), R.string.main_snackbar_success, Snackbar.LENGTH_SHORT).show();
			showFragment(currentMenuSelected);
			break;
		case AuthenticationTask.UNAUTHORIZED:
			Snackbar.make(this.findViewById(R.id.main_fab), R.string.main_snackbar_error_credentials, Snackbar.LENGTH_SHORT).setCallback(new Snackbar.Callback() {

				@Override
				public final void onDismissed(final Snackbar snackbar, final int event) {
					super.onDismissed(snackbar, event);
					final Intent intent = new Intent(MainActivity.this, IntroActivity.class);
					intent.putExtra(IntroActivity.INTENT_GOTO, IntroActivity.SLIDE_PERMISSION_INTERNET);
					MainActivity.this.startActivityForResult(intent, INTRO_ACTIVITY_RESULT);
				}

			}).show();
			break;
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

}
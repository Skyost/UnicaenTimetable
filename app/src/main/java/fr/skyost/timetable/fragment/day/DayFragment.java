package fr.skyost.timetable.fragment.day;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.RectF;
import android.os.Bundle;
import android.provider.AlarmClock;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AlertDialog;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;

import com.alamkanak.weekview.DateTimeInterpreter;
import com.alamkanak.weekview.WeekViewEvent;
import com.flask.colorpicker.ColorPickerView;
import com.flask.colorpicker.builder.ColorPickerDialogBuilder;

import org.joda.time.LocalDate;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;

import de.mateware.snacky.Snacky;
import fr.skyost.timetable.R;
import fr.skyost.timetable.activity.MainActivity;
import fr.skyost.timetable.utils.Utils;
import fr.skyost.timetable.utils.weekview.CustomWeekView;

/**
 * The fragment that allows to show lessons.
 */

public class DayFragment extends Fragment implements DateTimeInterpreter, CustomWeekView.EventClickListener, CustomWeekView.EventLongPressListener {

	/**
	 * The preference file that stores lesson colors.
	 */

	public static final String COLOR_PREFERENCES_FILE = "colors";

	/**
	 * The date formatter.
	 */

	private static final DateFormat DATE_FORMAT = DateFormat.getDateInstance(DateFormat.MEDIUM);

	/**
	 * The default hour.
	 */

	static final double DEFAULT_HOUR = 7d;

	/**
	 * The fragment date.
	 */

	private LocalDate date;

	@Override
	public void onCreate(final Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		final Bundle args = getArguments();
		if(args != null) {
			// We get the bundle from the fragment arguments.
			date = LocalDate.parse(args.getString(MainActivity.INTENT_DATE));
		}

		// We create our menu.
		setHasOptionsMenu(true);
	}

	@Override
	public void onCreateOptionsMenu(final Menu menu, final MenuInflater inflater) {
		super.onCreateOptionsMenu(menu, inflater);
		inflater.inflate(R.menu.activity_main_day, menu);
	}

	@Override
	public boolean onOptionsItemSelected(final MenuItem item) {
		final MainActivity activity = (MainActivity)getActivity();
		if(activity == null) {
			return super.onOptionsItemSelected(item);
		}

		// We associate the correct action with its menu item.
		switch(item.getItemId()) {
		case R.id.day_menu_week:
			new WeekPickerDisplayer().execute(this);
			return true;
		case R.id.day_menu_previous:
			activity.previousDayFragment();
			return true;
		case R.id.day_menu_next:
			activity.nextDayFragment();
			return true;
		}

		return super.onOptionsItemSelected(item);
	}

	@Override
	public View onCreateView(@NonNull final LayoutInflater inflater, final ViewGroup container, final Bundle savedInstanceState) {
		final View view = inflater.inflate(R.layout.fragment_main_day, container, false);
		final MainActivity activity = (MainActivity)getActivity();
		if(activity == null) {
			return view;
		}

		// We create our WeekView.
		final CustomWeekView weekView = view.findViewById(R.id.main_day_weekview_day);
		weekView.setSwipeLeftRunnable(activity::nextDayFragment);
		weekView.setSwipeRightRunnable(activity::previousDayFragment);
		weekView.setDateTimeInterpreter(this);
		weekView.setMonthChangeListener((newYear, newMonth) -> new ArrayList<>());
		weekView.setHorizontalFlingEnabled(false);
		weekView.setEventLongPressListener(this);
		weekView.setOnEventClickListener(this);

		// And we don't forget to show the SnackBar (if enabled).
		final SharedPreferences activityPreferences = activity.getSharedPreferences(MainActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE);
		if(activityPreferences.getBoolean(MainActivity.PREFERENCES_TIP_SHOW_PINCHTOZOOM, true)) {
			Snacky.builder().setActivity(activity).setText(R.string.main_snackbar_pinchtozoom).info().show();
			activityPreferences.edit().putBoolean(MainActivity.PREFERENCES_TIP_SHOW_PINCHTOZOOM, false).apply();
		}

		return view;
	}

	@Override
	public void onViewCreated(@NonNull final View view, @Nullable final Bundle savedInstanceState) {
		super.onViewCreated(view, savedInstanceState);

		// We load the View.
		new DayFragmentLoader(this, view).execute(date);
	}

	@Override
	public String interpretDate(final Calendar calendar) {
		final Date date = calendar.getTime();
		return new SimpleDateFormat("E", Locale.getDefault()).format(date) + " " + DATE_FORMAT.format(date);
	}

	@Override
	public String interpretTime(final int hour, final int minutes) {
		return Utils.addZeroIfNeeded(hour) + ":" + Utils.addZeroIfNeeded(minutes);
	}

	@Override
	public void onEventClick(final WeekViewEvent event, final RectF eventRect) {
		final MainActivity activity = (MainActivity)getActivity();
		if(activity == null) {
			return;
		}

		// We show a dialog that displays some info about the event.
		new AlertDialog.Builder(activity)
				.setMessage(event.getName() + "\n" + event.getLocation())
				.setNeutralButton(R.string.dialog_event_button_neutral, (dialog, which) -> {
					try {
						// We can start the alarm manager.
						final Calendar start = event.getStartTime();
						final Intent intent = new Intent(AlarmClock.ACTION_SET_ALARM);
						intent.putExtra(AlarmClock.EXTRA_MESSAGE, event.getName());
						intent.putExtra(AlarmClock.EXTRA_HOUR, start.get(Calendar.HOUR_OF_DAY));
						intent.putExtra(AlarmClock.EXTRA_MINUTES, start.get(Calendar.MINUTE));
						startActivity(intent);
					}
					catch(final Exception ex) {
						Snacky.builder().setActivity(activity).setText(R.string.main_snackbar_error_alarm).error().show();
					}
				})
				.setPositiveButton(R.string.dialog_generic_button_positive, null)
				.setNegativeButton(R.string.dialog_event_button_negative, (dialog, which) -> {
					// The negative button allows to reset the event color.
					final SharedPreferences colorPreferences = activity.getSharedPreferences(COLOR_PREFERENCES_FILE, Context.MODE_PRIVATE);
					colorPreferences.edit().remove(event.getName()).apply();
					dialog.dismiss();
					activity.showFragment(date);
				})
				.show();

		// When an event is clicked, we show a little message in the SnackBar to tell the user that he can change the event color.
		final SharedPreferences activityPreferences = activity.getSharedPreferences(MainActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE);
		if(activityPreferences.getBoolean(MainActivity.PREFERENCES_TIP_SHOW_CHANGECOLOR, true)) {
			Snacky.builder().setActivity(activity).setText(R.string.main_snackbar_changecolor).info().show();
			activityPreferences.edit().putBoolean(MainActivity.PREFERENCES_TIP_SHOW_CHANGECOLOR, false).apply();
		}
	}

	@Override
	public void onEventLongPress(final WeekViewEvent event, final RectF eventRect) {
		final MainActivity activity = (MainActivity)getActivity();
		if(activity == null) {
			return;
		}

		// When the user press longer on an event, we show the color picker dialog.
		final ColorPickerDialogBuilder builder = ColorPickerDialogBuilder.with(activity)
				.setTitle(R.string.dialog_color_title)
				.wheelType(ColorPickerView.WHEEL_TYPE.CIRCLE)
				.setPositiveButton(R.string.dialog_generic_button_positive, (dialog, selectedColor, allColors) -> {
					// Pressing the positive button allows to change the event color.
					final SharedPreferences colorPreferences = activity.getSharedPreferences(COLOR_PREFERENCES_FILE, Context.MODE_PRIVATE);
					colorPreferences.edit().putInt(event.getName(), selectedColor).commit();
					activity.showFragment(date);
				})
				.setNegativeButton(R.string.dialog_generic_button_cancel, (dialog, which) -> dialog.dismiss());

		// If the event already has a custom color, we set it in our builder.
		if(event.getColor() != ContextCompat.getColor(activity, R.color.colorWeekViewEventDefault)) {
			builder.initialColor(event.getColor());
		}
		builder.build().show();
	}

	/**
	 * Creates a new instance of this fragment for the specified date.
	 *
	 * @param day The date.
	 *
	 * @return An instance of this fragment corresponding to the date.
	 */

	public static DayFragment newInstance(final LocalDate day) {
		// We create fragment and we set the arguments.
		final DayFragment instance = new DayFragment();
		final Bundle args = new Bundle();
		args.putString(MainActivity.INTENT_DATE, day.toString("yyyy-MM-dd"));
		instance.setArguments(args);
		return instance;
	}

	/**
	 * Returns the fragment date.
	 *
	 * @return The fragment date.
	 */

	public LocalDate getDate() {
		return date;
	}

	/**
	 * Sets the fragment date.
	 *
	 * @param date The fragment date.
	 */

	public void setDate(final LocalDate date) {
		this.date = date;
	}

}
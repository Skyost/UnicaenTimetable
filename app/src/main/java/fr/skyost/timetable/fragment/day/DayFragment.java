package fr.skyost.timetable.fragment.day;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.RectF;
import android.os.Bundle;
import android.provider.AlarmClock;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;
import androidx.core.content.ContextCompat;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProviders;

import com.alamkanak.weekview.EventClickListener;
import com.alamkanak.weekview.EventLongPressListener;
import com.alamkanak.weekview.WeekView;
import com.alamkanak.weekview.WeekViewEvent;
import com.flask.colorpicker.ColorPickerView;
import com.flask.colorpicker.builder.ColorPickerDialogBuilder;

import org.jetbrains.annotations.NotNull;
import org.joda.time.LocalDate;

import java.util.ArrayList;
import java.util.Calendar;

import de.mateware.snacky.Snacky;
import fr.skyost.timetable.R;
import fr.skyost.timetable.activity.MainActivity;
import fr.skyost.timetable.activity.settings.SettingsActivity;
import fr.skyost.timetable.lesson.Lesson;
import fr.skyost.timetable.lesson.LessonModel;
import fr.skyost.timetable.utils.DefaultDateInterpreter;
import fr.skyost.timetable.utils.SwipeListener;

/**
 * The fragment that allows to show lessons.
 */

public class DayFragment extends Fragment implements EventLongPressListener<Lesson>, EventClickListener<Lesson> {

	/**
	 * The preference file that stores lesson colors.
	 */

	public static final String COLOR_PREFERENCES_FILE = "colors";

	/**
	 * The default hour.
	 */

	static final int DEFAULT_HOUR = 7;

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
	public void onCreateOptionsMenu(@NonNull final Menu menu, @NonNull final MenuInflater inflater) {
		super.onCreateOptionsMenu(menu, inflater);
		inflater.inflate(R.menu.activity_main_day, menu);
	}

	@Override
	public boolean onOptionsItemSelected(@NonNull final MenuItem item) {
		final MainActivity activity = (MainActivity)getActivity();
		if(activity == null) {
			return super.onOptionsItemSelected(item);
		}

		// We associate the correct action with its menu item.
		switch(item.getItemId()) {
		case R.id.day_menu_week:
			new WeekPickerDisplayer(ViewModelProviders.of(activity).get(LessonModel.class)).execute(this);
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

		// We create the swipe listener.
		final SwipeListener swipeListener = new SwipeListener(activity, activity::nextDayFragment, activity::previousDayFragment);

		// We create our WeekView.
		final WeekView<Lesson> weekView = view.findViewById(R.id.main_day_weekview);
		weekView.setOnTouchListener((v, event) -> {
			swipeListener.dispatchTouchEvent(event);
			return false;
		});
		weekView.setDateTimeInterpreter(new DefaultDateInterpreter());
		weekView.setMonthChangeListener((newYear, newMonth) -> new ArrayList<>());
		weekView.setHorizontalFlingEnabled(false);
		weekView.setEventLongPressListener(this);
		weekView.setOnEventClickListener(this);

		// And we don't forget to show the SnackBar (if enabled).
		final SharedPreferences activityPreferences = activity.getSharedPreferences(SettingsActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE);
		if(activityPreferences.getBoolean(SettingsActivity.PREFERENCES_TIP_SHOW_PINCHTOZOOM, true)) {
			Snacky.builder().setActivity(activity).setText(R.string.main_snackbar_pinchtozoom).info().show();
			activityPreferences.edit().putBoolean(SettingsActivity.PREFERENCES_TIP_SHOW_PINCHTOZOOM, false).apply();
		}

		return view;
	}

	@Override
	public void onViewCreated(@NonNull final View view, @Nullable final Bundle savedInstanceState) {
		super.onViewCreated(view, savedInstanceState);

		final MainActivity activity = (MainActivity)getActivity();
		if(activity == null) {
			return;
		}

		// We load the View.
		new DayFragmentLoader(activity, view.findViewById(R.id.main_day_weekview), date).execute(ViewModelProviders.of(this).get(LessonModel.class));
	}

	@Override
	public void onEventClick(final Lesson lesson, @NotNull final RectF rectF) {
		final MainActivity activity = (MainActivity)getActivity();
		if(activity == null) {
			return;
		}

		// We show a dialog that displays some info about the event.
		final WeekViewEvent<Lesson> event = lesson.toWeekViewEvent();
		new AlertDialog.Builder(activity)
				.setMessage(event.getTitle() + "\n" + event.getLocation())
				.setNeutralButton(R.string.dialog_event_button_neutral, (dialog, which) -> {
					try {
						// We can start the alarm manager.
						final Calendar start = event.getStartTime();
						final Intent intent = new Intent(AlarmClock.ACTION_SET_ALARM);
						intent.putExtra(AlarmClock.EXTRA_MESSAGE, event.getTitle());
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
					colorPreferences.edit().remove(event.getTitle()).apply();
					dialog.dismiss();
					activity.showDayFragment(date);
				})
				.show();

		// When an event is clicked, we show a little message in the SnackBar to tell the user that he can change the event color.
		final SharedPreferences activityPreferences = activity.getSharedPreferences(SettingsActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE);
		if(activityPreferences.getBoolean(SettingsActivity.PREFERENCES_TIP_SHOW_CHANGECOLOR, true)) {
			Snacky.builder().setActivity(activity).setText(R.string.main_snackbar_changecolor).info().show();
			activityPreferences.edit().putBoolean(SettingsActivity.PREFERENCES_TIP_SHOW_CHANGECOLOR, false).apply();
		}
	}

	@Override
	public void onEventLongPress(final Lesson lesson, @NotNull final RectF rectF) {
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
					colorPreferences.edit().putInt(lesson.getSummary(), selectedColor).commit();
					activity.showDayFragment(date);
				})
				.setNegativeButton(R.string.dialog_generic_button_cancel, (dialog, which) -> dialog.dismiss());

		// If the event already has a custom color, we set it in our builder.
		if(lesson.getColor() != ContextCompat.getColor(activity, R.color.colorWeekViewEventDefault)) {
			builder.initialColor(lesson.getColor());
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
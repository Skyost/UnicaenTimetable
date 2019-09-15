package fr.skyost.timetable.fragment.day;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProviders;

import com.alamkanak.weekview.WeekView;

import org.joda.time.LocalDate;

import java.util.ArrayList;

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

public class DayFragment extends Fragment {

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
			new WeekPickerDisplayer(ViewModelProviders.of(activity).get(LessonModel.class), selected -> {
				activity.showDayFragment(selected);
				return null;
			}).execute(activity);
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
		final DefaultEventListener listener = new DefaultEventListener(activity);
		final WeekView<Lesson> weekView = view.findViewById(R.id.main_day_weekview);
		weekView.setOnTouchListener((v, event) -> {
			swipeListener.dispatchTouchEvent(event);
			return false;
		});
		weekView.setDateTimeInterpreter(new DefaultDateInterpreter());
		weekView.setMonthChangeListener((newYear, newMonth) -> new ArrayList<>());
		weekView.setHorizontalFlingEnabled(false);
		weekView.setEventLongPressListener(listener);
		weekView.setOnEventClickListener(listener);

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
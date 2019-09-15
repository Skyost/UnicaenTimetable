package fr.skyost.timetable.fragment.week;

import android.content.res.Configuration;
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

import org.joda.time.DateTimeConstants;

import java.util.ArrayList;

import fr.skyost.timetable.R;
import fr.skyost.timetable.activity.MainActivity;
import fr.skyost.timetable.fragment.day.DayFragmentLoader;
import fr.skyost.timetable.fragment.day.DefaultEventListener;
import fr.skyost.timetable.fragment.day.WeekPickerDisplayer;
import fr.skyost.timetable.lesson.Lesson;
import fr.skyost.timetable.lesson.LessonModel;
import fr.skyost.timetable.utils.DefaultDateInterpreter;

/**
 * A fragment that is able to display weeks.
 */

public class WeekFragment extends Fragment {

	/**
	 * The column count.
	 */

	private int columnCount = 2;

	@Override
	public void onCreate(final Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		// We create our menu.
		setHasOptionsMenu(true);

		if(getResources().getConfiguration().orientation == Configuration.ORIENTATION_LANDSCAPE) {
			columnCount = 3;
		}
	}

	@Override
	public void onCreateOptionsMenu(@NonNull final Menu menu, @NonNull final MenuInflater inflater) {
		super.onCreateOptionsMenu(menu, inflater);
		inflater.inflate(R.menu.activity_main_week, menu);
	}

	@Override
	public boolean onOptionsItemSelected(@NonNull final MenuItem item) {
		final MainActivity activity = (MainActivity)getActivity();
		if(activity == null) {
			return super.onOptionsItemSelected(item);
		}

		// We associate the correct action with its menu item.
		if(item.getItemId() == R.id.week_menu_week) {
			new WeekPickerDisplayer(ViewModelProviders.of(activity).get(LessonModel.class), selected -> {
				activity.setCurrentDate(selected);
				activity.showFragment(R.id.nav_timetable_week);
				return null;
			}).execute(activity);

			return true;
		}

		return super.onOptionsItemSelected(item);
	}

	@Override
	public View onCreateView(@NonNull final LayoutInflater inflater, final ViewGroup container, final Bundle savedInstanceState) {
		// We create our WeekView.
		final View view = inflater.inflate(R.layout.fragment_main_week, container, false);
		final MainActivity activity = (MainActivity)getActivity();
		if(activity == null) {
			return view;
		}

		final DefaultEventListener listener = new DefaultEventListener(activity);
		final WeekView<Lesson> weekView = view.findViewById(R.id.main_week_weekview);
		weekView.setDateTimeInterpreter(new DefaultDateInterpreter());
		weekView.setMonthChangeListener((newYear, newMonth) -> new ArrayList<>());
		weekView.setHorizontalFlingEnabled(false);
		weekView.setNumberOfVisibleDays(columnCount);
		weekView.setEventLongPressListener(listener);
		weekView.setOnEventClickListener(listener);

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
		new DayFragmentLoader(activity, view.findViewById(R.id.main_week_weekview), activity.getCurrentDate().withDayOfWeek(DateTimeConstants.MONDAY), 5).execute(ViewModelProviders.of(this).get(LessonModel.class));
	}

}
package fr.skyost.timetable.fragment.day;

import android.arch.lifecycle.ViewModelProviders;
import android.content.Context;
import android.content.SharedPreferences;
import android.os.AsyncTask;
import android.support.v4.content.ContextCompat;
import android.view.View;

import com.alamkanak.weekview.WeekViewEvent;

import org.joda.time.DateTime;
import org.joda.time.LocalDate;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.atomic.AtomicReference;

import fr.skyost.timetable.R;
import fr.skyost.timetable.activity.MainActivity;
import fr.skyost.timetable.lesson.Lesson;
import fr.skyost.timetable.lesson.LessonModel;
import fr.skyost.timetable.utils.weekview.CustomWeekView;

/**
 * The AsyncTask that allows to load the DayFragment view.
 */

public class DayFragmentLoader extends AsyncTask<LocalDate, Void, List<? extends WeekViewEvent>> {

	/**
	 * The DayFragment.
	 */

	private final DayFragment fragment;

	/**
	 * An atomic reference to the fragment view.
	 */

	private final AtomicReference<View> view;

	/**
	 * The hour to display.
	 */

	private double hour = DayFragment.DEFAULT_HOUR;

	/**
	 * Creates a new day fragment loader instance.
	 *
	 * @param fragment The fragment.
	 * @param view The view.
	 */

	DayFragmentLoader(final DayFragment fragment, final View view) {
		this.fragment = fragment;
		this.view = new AtomicReference<>(view);
	}

	@Override
	protected List<? extends WeekViewEvent> doInBackground(final LocalDate... dates) {
		final MainActivity activity = (MainActivity)fragment.getActivity();
		if(activity == null) {
			return new ArrayList<>();
		}

		// Let's create our list of lessons !
		final LocalDate date = dates[0];
		final SharedPreferences activityPreferences = activity.getSharedPreferences(MainActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE);
		final SharedPreferences colorPreferences = activity.getSharedPreferences(DayFragment.COLOR_PREFERENCES_FILE, Context.MODE_PRIVATE);
		final int defaultColor = ContextCompat.getColor(activity, R.color.colorWeekViewEventDefault);

		final List<WeekViewEvent> events = new ArrayList<>();
		final LessonModel model = ViewModelProviders.of(activity).get(LessonModel.class);
		final List<Lesson> lessons = model.getLessons(date.toDateTimeAtStartOfDay(), date.toDateTimeAtStartOfDay().plusDays(1));
		for(final Lesson lesson : lessons) {
			events.add(new TimetableWeekViewEvent(lesson, activityPreferences, colorPreferences, defaultColor));
		}

		// If we are displaying the today's fragment, we go to the current hour.
		if(LocalDate.now().equals(date)) {
			final DateTime now = DateTime.now();
			hour = now.getHourOfDay() + (now.getMinuteOfHour() / 60d);
		}

		return events;
	}

	@Override
	protected void onPostExecute(final List<? extends WeekViewEvent> events) {
		final Calendar calendar = fragment.getDate().toDateTimeAtStartOfDay().toCalendar(Locale.getDefault());
		final View view = this.view.get();
		if(view == null) {
			return;
		}

		// We create our WeekView and we make it visible.
		final CustomWeekView weekView = view.findViewById(R.id.main_day_weekview_day);
		weekView.setMonthChangeListener((newYear, newMonth) -> events);
		weekView.goToDate(calendar);
		weekView.setMinDate(calendar);
		weekView.setMaxDate(calendar);
		weekView.goToHour(hour);
		weekView.setVisibility(View.VISIBLE);

		// We hide the progress bar.
		view.findViewById(R.id.main_day_progressbar).setVisibility(View.GONE);
	}

	/**
	 * Returns the fragment.
	 *
	 * @return The fragment.
	 */

	public DayFragment getFragment() {
		return fragment;
	}

	/**
	 * Returns the view atomic reference.
	 *
	 * @return The view atomic reference.
	 */

	public AtomicReference<View> getView() {
		return view;
	}

	/**
	 * Returns the hour to display.
	 *
	 * @return The hour to display.
	 */

	public double getHour() {
		return hour;
	}

	/**
	 * Sets the hour to display.
	 *
	 * @param hour The hour to display.
	 */

	public void setHour(final double hour) {
		this.hour = hour;
	}
}

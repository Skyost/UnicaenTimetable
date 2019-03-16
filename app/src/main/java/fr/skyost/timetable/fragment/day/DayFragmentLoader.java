package fr.skyost.timetable.fragment.day;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.AsyncTask;
import android.view.View;

import com.alamkanak.weekview.WeekView;
import com.alamkanak.weekview.WeekViewDisplayable;

import org.joda.time.LocalDate;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.atomic.AtomicReference;

import androidx.core.content.ContextCompat;
import fr.skyost.timetable.R;
import fr.skyost.timetable.activity.MainActivity;
import fr.skyost.timetable.lesson.Lesson;
import fr.skyost.timetable.lesson.LessonModel;

/**
 * The AsyncTask that allows to load the DayFragment view.
 */

public class DayFragmentLoader extends AsyncTask<LessonModel, Void, List<WeekViewDisplayable<Lesson>>> {

	/**
	 * The DayFragment.
	 */

	private final DayFragment fragment;

	/**
	 * An atomic reference to the fragment view.
	 */

	private final AtomicReference<View> view;

	/**
	 * The current date.
	 */

	private final LocalDate date;

	/**
	 * Creates a new day fragment loader instance.
	 *
	 * @param fragment The fragment.
	 * @param view The view.
	 */

	DayFragmentLoader(final DayFragment fragment, final View view, final LocalDate date) {
		this.fragment = fragment;
		this.view = new AtomicReference<>(view);
		this.date = date;
	}

	@Override
	protected List<WeekViewDisplayable<Lesson>> doInBackground(final LessonModel... models) {
		final MainActivity activity = (MainActivity)fragment.getActivity();
		if(activity == null) {
			return new ArrayList<>();
		}

		// Let's create our list of lessons !
		final SharedPreferences activityPreferences = activity.getSharedPreferences(MainActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE);
		final SharedPreferences colorPreferences = activity.getSharedPreferences(DayFragment.COLOR_PREFERENCES_FILE, Context.MODE_PRIVATE);
		final int defaultColor = ContextCompat.getColor(activity, R.color.colorWeekViewEventDefault);

		final List<Lesson> lessons = models[0].getLessons(date.toDateTimeAtStartOfDay(), date.toDateTimeAtStartOfDay().plusDays(1));
		final List<WeekViewDisplayable<Lesson>> result = new ArrayList<>();

		for(final Lesson lesson : lessons) {
			lesson.loadColor(activityPreferences, colorPreferences, defaultColor);
			result.add(lesson);
		}

		return result;
	}

	@Override
	protected void onPostExecute(final List<WeekViewDisplayable<Lesson>> lessons) {
		final Calendar calendar = fragment.getDate().toDateTimeAtStartOfDay().toCalendar(Locale.getDefault());
		final View view = this.view.get();
		if(view == null) {
			return;
		}

		// We create our WeekView and we make it visible.
		final WeekView<Lesson> weekView = view.findViewById(R.id.main_day_weekview_day);
		weekView.goToDate(calendar);
		weekView.setMinDate(calendar);
		weekView.setMaxDate(calendar);
		if(LocalDate.now().isEqual(date)) {
			weekView.goToCurrentTime();
		}
		else {
			weekView.goToHour(DayFragment.DEFAULT_HOUR);
		}
		weekView.setMonthChangeListener((startDate, endDate) -> {
			final long date = this.date.toDateTimeAtStartOfDay().getMillis();
			if(LocalDate.fromCalendarFields(startDate).toDateTimeAtStartOfDay().getMillis() <= date && date <= LocalDate.fromCalendarFields(endDate).toDateTimeAtStartOfDay().getMillis()) {
				return lessons;
			}

			return new ArrayList<>();
		});
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
	 * Returns the current date.
	 *
	 * @return The current date.
	 */

	public LocalDate getDate() {
		return date;
	}
}

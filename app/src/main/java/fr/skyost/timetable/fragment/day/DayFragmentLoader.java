package fr.skyost.timetable.fragment.day;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.AsyncTask;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ProgressBar;

import androidx.core.content.ContextCompat;

import com.alamkanak.weekview.WeekView;
import com.alamkanak.weekview.WeekViewDisplayable;

import org.joda.time.LocalDate;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.Locale;

import fr.skyost.timetable.R;
import fr.skyost.timetable.activity.MainActivity;
import fr.skyost.timetable.activity.settings.SettingsActivity;
import fr.skyost.timetable.lesson.Lesson;
import fr.skyost.timetable.lesson.LessonModel;

/**
 * The AsyncTask that allows to load the DayFragment view.
 */

public class DayFragmentLoader extends AsyncTask<LessonModel, Void, List<WeekViewDisplayable<Lesson>>> {

	/**
	 * The main activity.
	 */

	private final WeakReference<MainActivity> activity;

	/**
	 * An atomic reference to the week view.
	 */

	private final WeakReference<WeekView<Lesson>> weekView;

	/**
	 * The current date.
	 */

	private final LocalDate date;

	/**
	 * The range to get.
	 */

	private final int range;

	/**
	 * Creates a new day fragment loader instance.
	 *
	 * @param activity The main activity.
	 * @param weekView The week view.
	 * @param date The date to load.
	 */

	DayFragmentLoader(final MainActivity activity, final WeekView<Lesson> weekView, final LocalDate date) {
		this(activity, weekView, date, 1);
	}

	/**
	 * Creates a new day fragment loader instance.
	 *
	 * @param activity The main activity.
	 * @param weekView The week view.
	 */

	public DayFragmentLoader(final MainActivity activity, final WeekView<Lesson> weekView, final LocalDate date, final int range) {
		this.activity = new WeakReference<>(activity);
		this.weekView = new WeakReference<>(weekView);
		this.date = date;
		this.range = range;
	}

	@Override
	protected List<WeekViewDisplayable<Lesson>> doInBackground(final LessonModel... models) {
		final MainActivity activity = this.activity.get();
		if(activity == null) {
			return new ArrayList<>();
		}

		// Let's create our list of lessons !
		final SharedPreferences activityPreferences = activity.getSharedPreferences(SettingsActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE);
		final SharedPreferences colorPreferences = activity.getSharedPreferences(DefaultEventListener.COLOR_PREFERENCES_FILE, Context.MODE_PRIVATE);
		final int defaultColor = ContextCompat.getColor(activity, R.color.colorWeekViewEventDefault);

		final List<Lesson> lessons = models[0].getLessons(date.toDateTimeAtStartOfDay(), date.toDateTimeAtStartOfDay().plusDays(range));
		final List<WeekViewDisplayable<Lesson>> result = new ArrayList<>();

		for(final Lesson lesson : lessons) {
			lesson.loadColor(activity, activityPreferences, colorPreferences, defaultColor);
			result.add(lesson);
		}

		return result;
	}

	@Override
	protected void onPostExecute(final List<WeekViewDisplayable<Lesson>> lessons) {
		final Calendar min = date.toDateTimeAtStartOfDay().toCalendar(Locale.getDefault());
		final Calendar max = date.plusDays(range - 1).toDateTimeAtStartOfDay().toCalendar(Locale.getDefault());
		final WeekView<Lesson> weekView = this.weekView.get();
		if(weekView == null) {
			return;
		}

		// We create our WeekView and we make it visible.
		weekView.goToDate(min);
		weekView.setMinDate(min);
		weekView.setMaxDate(max);
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
		final ViewGroup parent = (ViewGroup)weekView.getParent();
		int count = parent.getChildCount();
		for (int i = 0; i < count; i++) {
			View view = parent.getChildAt(i);
			if (view instanceof ProgressBar) {
				view.setVisibility(View.GONE);
				return;
			}
		}
	}

	/**
	 * Returns the main activity.
	 *
	 * @return The main activity.
	 */

	public MainActivity getActivity() {
		return activity.get();
	}

	/**
	 * Returns the week view.
	 *
	 * @return The week view.
	 */

	public WeekView<Lesson> getView() {
		return weekView.get();
	}

	/**
	 * Returns the current date.
	 *
	 * @return The current date.
	 */

	public LocalDate getDate() {
		return date;
	}

	/**
	 * Returns the range.
	 *
	 * @return The range.
	 */

	public int getRange() {
		return range;
	}
}

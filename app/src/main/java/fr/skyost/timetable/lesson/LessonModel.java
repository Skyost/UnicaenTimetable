package fr.skyost.timetable.lesson;

import android.app.Application;
import android.arch.lifecycle.AndroidViewModel;
import android.arch.lifecycle.LiveData;
import android.support.annotation.NonNull;

import org.joda.time.DateTime;
import org.joda.time.DateTimeConstants;
import org.joda.time.LocalDate;

import java.text.DateFormat;
import java.util.ArrayList;
import java.util.List;

import fr.skyost.timetable.application.TimetableApplication;
import fr.skyost.timetable.lesson.database.LessonDao;

/**
 * The lesson model.
 */

public class LessonModel extends AndroidViewModel {

	/**
	 * The default week format (used in formatWeek).
	 */

	private static final DateFormat WEEK_FORMAT = DateFormat.getDateInstance(DateFormat.MEDIUM);

	/**
	 * The lesson data access object.
	 */

	private final LessonDao dao;

	/**
	 * The lesson LiveData.
	 */

	private final LiveData<List<Lesson>> lessons;

	/**
	 * The expiration date LiveData.
	 */

	private final LiveData<DateTime> expirationDate;

	/**
	 * Creates a new lesson model instance.
	 *
	 * @param application The application.
	 */

	public LessonModel(@NonNull final Application application) {
		super(application);

		dao = getApplication().getDatabase().getLessonDao();
		lessons = dao.getLessonsLiveData();
		expirationDate = dao.getExpirationDateLiveData();
	}

	/**
	 * Refreshes the DAO from network.
	 *
	 * @return The refresh response.
	 */

	public int refreshFromNetwork() {
		return dao.refreshFromNetwork(getApplication());
	}

	/**
	 * Returns the lessons LiveData.
	 *
	 * @return The lessons LiveData.
	 */

	public LiveData<List<Lesson>> getLessonsLiveData() {
		return lessons;
	}

	/**
	 * Returns the expiration date LiveData.
	 *
	 * @return The expiration date LiveData.
	 */

	public LiveData<DateTime> getExpirationDateLiveData() {
		return expirationDate;
	}

	/**
	 * Returns a list of available weeks.
	 *
	 * @return A list of available weeks.
	 */

	public List<LocalDate> getAvailableWeeks() {
		// We get all start dates, we change the day to monday and we add them to a list (if not previously inserted).
		final List<LocalDate> result = new ArrayList<>();
		for(LocalDate date : dao.getStartDates()) {
			date = date.withDayOfWeek(DateTimeConstants.MONDAY);
			if(!result.contains(date)) {
				result.add(date);
			}
		}
		return result;
	}

	/**
	 * Returns the lessons contained in the specified bounds.
	 *
	 * @param boundA The first bound.
	 * @param boundB The second bound.
	 *
	 * @return The lessons contained in the specified bounds.
	 */

	public List<Lesson> getLessons(final DateTime boundA, final DateTime boundB) {
		return dao.getLessons(boundA, boundB);
	}

	/**
	 * Formats a date and returns a week String.
	 *
	 * @param date The data.
	 *
	 * @return A week String (eg. Monday, 1 January - Friday, 5 January).
	 */

	public String formatWeek(final LocalDate date) {
		return WEEK_FORMAT.format(date.withDayOfWeek(DateTimeConstants.MONDAY).toDate()) + " - " + WEEK_FORMAT.format(date.withDayOfWeek(DateTimeConstants.FRIDAY).toDate());
	}

	@NonNull
	@Override
	public TimetableApplication getApplication() {
		return (TimetableApplication)super.getApplication();
	}

}
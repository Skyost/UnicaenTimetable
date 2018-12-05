package fr.skyost.timetable.lesson;

import android.app.Application;
import android.content.Context;

import org.joda.time.DateTime;
import org.joda.time.DateTimeConstants;
import org.joda.time.LocalDate;

import java.io.IOException;
import java.text.DateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import androidx.annotation.NonNull;
import androidx.lifecycle.AndroidViewModel;
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
	 * Creates a new lesson model instance.
	 *
	 * @param application The application.
	 */

	public LessonModel(@NonNull final Application application) {
		super(application);

		dao = getApplication().getDatabase().getLessonDao();
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
	 * Returns the database last modification time.
	 *
	 * @param context The context.
	 *
	 * @return The database last modification time.
	 *
	 * @throws IOException If any I/O exception occurs.
	 */

	public long getLastModificationTime(final Context context) throws IOException {
		return dao.readLastModificationFile(context);
	}

	/**
	 * Returns the expiration date LiveData.
	 *
	 * @return The expiration date LiveData.
	 */

	public DateTime getMaxEndDate() {
		return dao.getMaxEndDate();
	}

	/**
	 * Returns a list of available weeks.
	 *
	 * @return A list of available weeks.
	 */

	public List<LocalDate> getAvailableWeeks() {
		// We get all start dates, we change the day to monday and we add one week to the minimum until we hit the maximum.
		final List<LocalDate> result = new ArrayList<>();
		LocalDate min = dao.getMinStartDate();
		LocalDate max = dao.getMaxStartDate();

		if(min == null || max == null) {
			return Collections.emptyList();
		}

		min = min.withDayOfWeek(DateTimeConstants.MONDAY);
		max = max.withDayOfWeek(DateTimeConstants.MONDAY);

		LocalDate current = min;
		while(!current.isAfter(max)) {
			result.add(current);
			current = current.plusWeeks(1);
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
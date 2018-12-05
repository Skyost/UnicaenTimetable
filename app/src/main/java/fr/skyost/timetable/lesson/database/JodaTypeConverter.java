package fr.skyost.timetable.lesson.database;

import org.joda.time.DateTime;
import org.joda.time.LocalDate;

import androidx.room.TypeConverter;

/**
 * Allows to convert some Joda objects.
 */

public class JodaTypeConverter {

	/**
	 * Converts a Long to a DateTime.
	 *
	 * @param value The Long value.
	 *
	 * @return The DateTime object.
	 */

	@TypeConverter
	public static DateTime toDateTime(final long value) {
		return new DateTime(value);
	}

	/**
	 * Converts a Long to a LocalDate.
	 *
	 * @param value The Long value.
	 *
	 * @return The LocalDate object.
	 */

	@TypeConverter
	public static LocalDate toLocalDate(final long value) {
		return new LocalDate(value);
	}

	/**
	 * Converts a DateTime to a Long.
	 *
	 * @param value The DateTime value.
	 *
	 * @return The Long object.
	 */

	@TypeConverter
	public static long toString(final DateTime value) {
		return value.getMillis();
	}

}
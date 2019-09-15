package fr.skyost.timetable.utils;

import androidx.annotation.NonNull;

import com.alamkanak.weekview.DateTimeInterpreter;

import org.jetbrains.annotations.NotNull;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;

/**
 * The default date interpreter for week views.
 */

public class DefaultDateInterpreter implements DateTimeInterpreter {

	/**
	 * The date formatter.
	 */

	private static final DateFormat DATE_FORMAT = DateFormat.getDateInstance(DateFormat.MEDIUM);

	@NonNull
	@Override
	public String interpretDate(@NonNull final Calendar calendar) {
		final Date date = calendar.getTime();
		return new SimpleDateFormat("E", Locale.getDefault()).format(date) + " " + DATE_FORMAT.format(date);
	}

	@NotNull
	@Override
	public String interpretTime(final int hour) {
		return Utils.addZeroIfNeeded(hour) + ":00";
	}

}

package fr.skyost.timetable;

import android.content.Context;
import android.graphics.Color;

import net.fortuna.ical4j.data.CalendarBuilder;
import net.fortuna.ical4j.data.ParserException;
import net.fortuna.ical4j.model.Component;
import net.fortuna.ical4j.model.component.CalendarComponent;
import net.fortuna.ical4j.model.component.VEvent;
import net.fortuna.ical4j.model.property.Description;
import net.fortuna.ical4j.model.property.Summary;

import org.joda.time.DateTime;
import org.joda.time.DateTimeConstants;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.Serializable;
import java.text.DateFormat;
import java.util.Calendar;
import java.util.HashSet;
import java.util.Locale;
import java.util.Random;
import java.util.Set;

import fr.skyost.timetable.utils.Utils;

/**
 * A class which represents a timetable.
 */

public class Timetable implements Serializable {

	public static final String TIMETABLE_FILE = "current_timetable";

	private final Set<Integer> usedIds = new HashSet<Integer>();

	private final net.fortuna.ical4j.model.Calendar calendar;
	private final HashSet<Lesson> lessons = new HashSet<Lesson>();

	/**
	 * Creates a new timetable instance.
	 *
	 * @param calendar The corresponding calendar.
	 */

	public Timetable(final net.fortuna.ical4j.model.Calendar calendar) {
		this.calendar = calendar;
		for(final CalendarComponent component : calendar.getComponents(Component.VEVENT)) {
			final VEvent event = (VEvent)component;
			final Calendar start = Calendar.getInstance();
			start.setTime(event.getStartDate().getDate());
			final Calendar end = Calendar.getInstance();
			end.setTime(event.getEndDate().getDate());

			final Summary summary = event.getSummary();
			final Description description = event.getDescription();
			lessons.add(new Lesson(summary == null ? "" : summary.getValue(), description == null ? "" : description.getValue(), Day.getByValue(start.get(Calendar.DAY_OF_WEEK)), start, end));
		}
	}

	/**
	 * Gets the lessons for this timetable.
	 *
	 * @return The lessons.
	 */

	public final Set<Lesson> getLessons() {
		return lessons;
	}

	/**
	 * Gets the calendar of this timetable.
	 *
	 * @return The calendar.
	 */

	public final net.fortuna.ical4j.model.Calendar getCalendar() {
		return calendar;
	}

	/**
	 * Loads a timetable from the disk.
	 *
	 * @param context A context (the timetable will be loaded from the application working directory).
	 *
	 * @throws IOException If an exception occurrs.
	 */

	public static final Timetable loadFromDisk(final Context context) throws IOException, ParserException {
		final FileInputStream input = context.openFileInput(TIMETABLE_FILE);
		final net.fortuna.ical4j.model.Calendar calendar = new CalendarBuilder().build(input);

		input.close();
		return new Timetable(calendar);
	}

	/**
	 * Saves this timetable on the disk.
	 *
	 * @param context A context (the timetable will be saved in the application working directory).
	 *
	 * @throws IOException If an exception occurrs.
	 */

	public final void saveOnDisk(final Context context) throws IOException {
		final FileOutputStream output = context.openFileOutput(TIMETABLE_FILE, Context.MODE_PRIVATE);
		output.write(calendar.toString().getBytes(Utils.UTF_8));
		output.close();
	}

	/**
	 * Gets the min date of this timetable.
	 *
	 * @return The minimal date of this timetable.
	 */

	public static final DateTime getMinStartDate() {
		return DateTime.now()
				.withHourOfDay(0)
				.withMinuteOfHour(0)
				.withSecondOfMinute(0)
				.withSecondOfMinute(0)
				.withDayOfWeek(DateTimeConstants.MONDAY)
				.minusWeeks(1);
	}

	/**
	 * Gets the start date of this timetable.
	 *
	 * @return The start date of this timetable.
	 */

	public final long getStartDate() {
		long start = -1L;

		final Calendar now = Calendar.getInstance();
		for(final CalendarComponent component : calendar.getComponents(Component.VEVENT)) {
			final VEvent event = (VEvent)component;
			now.setTime(event.getStartDate().getDate());

			final long millis = now.getTimeInMillis();
			if(start < 0 || millis < start) {
				start = millis;
			}
		}

		return start;
	}

	/**
	 * Gets the max date of this timetable.
	 *
	 * @return The max date of this timetable.
	 */

	public static final DateTime getMaxEndDate() {
		return DateTime.now()
				.withHourOfDay(0)
				.withMinuteOfHour(0)
				.withSecondOfMinute(0)
				.withSecondOfMinute(0)
				.withDayOfWeek(DateTimeConstants.MONDAY)
				.plusWeeks(2);
	}

	/**
	 * Gets the end date of this timetable.
	 *
	 * @return The end date of this timetable.
	 */

	public final long getEndDate() {
		long end = -1L;

		final Calendar now = Calendar.getInstance();
		for(final CalendarComponent component : calendar.getComponents(Component.VEVENT)) {
			final VEvent event = (VEvent)component;
			now.setTime(event.getEndDate().getDate());

			final long millis = now.getTimeInMillis();
			if(end < 0 || millis > end) {
				end = millis;
			}
		}

		return end;
	}

	/**
	 * A class which represents a lesson.
	 */

	public class Lesson implements Serializable {

		private final int id;
		private final String name;
		private final String description;
		private final Day day;
		private final Calendar start;
		private final Calendar end;

		/**
		 * Creates a lesson.
		 *
		 * @param name The name of this lesson.
		 * @param description The description of this lesson.
		 * @param day The day of this lesson.
		 * @param start The start time of this lesson.
		 * @param end The end time of this lesson.
		 */

		public Lesson(final String name, final String description, final Day day, final Calendar start, final Calendar end) {
			final Random random = new Random();
			int id;
			do {
				id = random.nextInt();
			}
			while(usedIds.contains(id));
			usedIds.add(id);
			this.id = id;

			this.name = name;
			this.description = description;
			this.day = day;
			this.start = start;
			this.end = end;
		}

		/**
		 * Gets the unique id of this lesson.
		 *
		 * @return The unique id of this lesson.
		 */

		public final int getId() {
			return id;
		}

		/**
		 * Gets the name of this lesson.
		 *
		 * @return The name of this lesson.
		 */

		public final String getName() {
			return name;
		}

		/**
		 * Gets the location of this lesson.
		 *
		 * @return The location of this lesson.
		 */

		public final String getDescription() {
			return description;
		}

		/**
		 * Gets the day of this lesson.
		 *
		 * @return The day of this lesson.
		 */

		public final Day getDay() {
			return day;
		}

		/**
		 * Gets the start time of this lesson.
		 *
		 * @return The start time of this lesson.
		 */

		public final Calendar getStart() {
			return start;
		}

		/**
		 * Gets the end time of this lesson.
		 *
		 * @return The end time of this lesson.
		 */

		public final Calendar getEnd() {
			return end;
		}

	}

	/**
	 * A class which represents a day.
	 */

	public enum Day {

		MONDAY(Calendar.MONDAY),
		TUESDAY(Calendar.TUESDAY),
		WEDNESDAY(Calendar.WEDNESDAY),
		THURSDAY(Calendar.THURSDAY),
		FRIDAY(Calendar.FRIDAY);

		private final int value;

		Day(final int value) {
			this.value = value;
		}

		/**
		 * Gets a day by its value.
		 *
		 * @return The day by its value.
		 */

		public static final Day getByValue(final int value) {
			for(final Day day : Day.values()) {
				if(day.value == value) {
					return day;
				}
			}
			return null;
		}

		/**
		 * Gets the value of a day.
		 *
		 * @return The value of a day.
		 */

		public final int getValue() {
			return value;
		}

	}

}
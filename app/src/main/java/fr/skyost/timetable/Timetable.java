package fr.skyost.timetable;

import android.content.Context;
import android.os.Parcel;
import android.os.Parcelable;
import android.support.annotation.NonNull;

import org.joda.time.DateTime;
import org.joda.time.DateTimeConstants;
import org.joda.time.DateTimeFieldType;
import org.joda.time.LocalDate;
import org.joda.time.LocalTime;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collection;
import java.util.Collections;
import java.util.GregorianCalendar;
import java.util.HashSet;
import java.util.List;
import java.util.Random;
import java.util.concurrent.TimeUnit;

import biweekly.Biweekly;
import biweekly.ICalendar;
import biweekly.component.VEvent;
import biweekly.property.Description;
import biweekly.property.Location;
import biweekly.property.Summary;
import fr.skyost.timetable.activities.MainActivity;
import fr.skyost.timetable.utils.HashMultiMap;

/**
 * A class which represents a timetable.
 */

public class Timetable implements Parcelable {

	public static final String TIMETABLE_FILE = "current_timetable";
	public static final Parcelable.Creator<Timetable> CREATOR = new Parcelable.Creator<Timetable>() {

		@Override
		public final Timetable createFromParcel(final Parcel source) {
			return new Timetable(source);
		}

		@Override
		public final Timetable[] newArray(final int size) {
			return new Timetable[size];
		}

	};

	private final HashSet<Integer> usedIds = new HashSet<Integer>();

	private final ICalendar calendar;
	private final HashMultiMap<LocalDate, Lesson> lessons = new HashMultiMap<LocalDate, Lesson>();

	/**
	 * Creates a new timetable instance.
	 *
	 * @param parcel Used to pass arguments.
	 */

	public Timetable(final Parcel parcel) {
		this(Biweekly.parse(parcel.readString()).first());
	}

	/**
	 * Creates a new timetable instance.
	 *
	 * @param calendar The corresponding calendar.
	 */

	public Timetable(final ICalendar calendar) {
		this.calendar = calendar;
		for(final VEvent event : calendar.getEvents()) {
			final Calendar start = Calendar.getInstance();
			start.setTime(event.getDateStart().getValue());
			final Calendar end = Calendar.getInstance();
			end.setTime(event.getDateEnd().getValue());

			lessons.put(new LocalDate(start), new Lesson(event.getSummary(), event.getDescription(), event.getLocation(), Day.getByValue(start.get(Calendar.DAY_OF_WEEK)), start, end));
		}
	}

	@Override
	public final int describeContents() {
		return 0;
	}

	@Override
	public final void writeToParcel(final Parcel parcel, final int flags) {
		parcel.writeString(Biweekly.write(calendar == null ? new ICalendar() : calendar).go());
	}

	/**
	 * Gets the lessons for this timetable.
	 *
	 * @return The lessons.
	 */

	public final Collection<Lesson> getLessons() {
		return lessons.getAllValues();
	}

	/**
	 * Gets all lessons for a specific day.
	 *
	 * @param day The day.
	 *
	 * @return The lessons for a specific day.
	 */

	public final Collection<Lesson> getLessons(final Calendar day) {
		return getLessons(new LocalDate(day));
	}

	/**
	 * Gets all lessons for a specific day.
	 *
	 * @param day The day.
	 *
	 * @return The lessons for a specific day.
	 */

	public final Collection<Lesson> getLessons(final LocalDate day) {
		final Collection<Lesson> lessons = this.lessons.get(day);
		return lessons == null ? new HashSet<Lesson>() : lessons;
	}

	/**
	 * Gets today's lessons for this timetable.
	 *
	 * @return The lessons.
	 */

	public final Collection<Lesson> getLessonsOfToday() {
		return getLessons(Calendar.getInstance());
	}

	/**
	 * Gets the calendar representation of this timetable.
	 *
	 * @return The calendar.
	 */

	public final ICalendar getCalendar() {
		return calendar;
	}

	/**
	 * Loads a timetable from the disk.
	 *
	 * @param context A context (the timetable will be loaded from the application working directory).
	 *
	 * @throws IOException If an exception occurs.
	 */

	public static final Timetable loadFromDisk(final Context context) throws IOException {
		final FileInputStream input = context.openFileInput(TIMETABLE_FILE);
		final ICalendar calendar = Biweekly.parse(input).first();

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
		Biweekly.write(calendar).go(output);
		output.close();
	}

	/**
	 * Gets the min date of this timetable according to preferences.
	 *
	 * @param context Used to get preferences.
	 *
	 * @return The min date of this timetable according to preferences.
	 */

	public static final DateTime getMinStartDate(final Context context) {
		DateTime time = DateTime.now();

		time = time.withHourOfDay(0)
				.withMinuteOfHour(0)
				.withSecondOfMinute(0)
				.withMillisOfSecond(0)
				.withDayOfWeek(DateTimeConstants.MONDAY);

		switch(context.getSharedPreferences(MainActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE).getString(MainActivity.PREFERENCES_CALENDAR_INTERVAL, "0")) {
		case "1":
			time = time.minusMonths(1);
			break;
		case "2":
			time = time.minusMonths(3);
			break;
		case "3":
			time = null;
			break;
		default:
			time = time.minusWeeks(2);
			break;
		}

		return time;
	}

	/**
	 * Gets the start date of this timetable.
	 *
	 * @return The start date of this timetable.
	 */

	public final long getStartDate() {
		LocalDate min = null;
		for(final LocalDate date : lessons.getAllKeys()) {
			if(min != null && date.compareTo(min) >= 0) {
				continue;
			}
			min = date;
		}

		return min == null ? -1L : min.toDateTimeAtCurrentTime().getMillis();
	}

	/**
	 * Gets the max date of this timetable according to preferences.
	 *
	 * @param context Used to get preferences.
	 *
	 * @return The max date of this timetable according to preferences.
	 */

	public static final DateTime getMaxEndDate(final Context context) {
		DateTime time = DateTime.now();

		final int currentDay = time.getDayOfWeek();
		if(currentDay == DateTimeConstants.SATURDAY || currentDay == DateTimeConstants.SUNDAY) {
			time = time.plusWeeks(1);
		}

		time = time.withHourOfDay(0)
				.withMinuteOfHour(0)
				.withSecondOfMinute(0)
				.withMillisOfSecond(0)
				.withDayOfWeek(DateTimeConstants.SUNDAY);

		switch(context.getSharedPreferences(MainActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE).getString(MainActivity.PREFERENCES_CALENDAR_INTERVAL, "0")) {
		case "1":
			time = time.plusMonths(1);
			break;
		case "2":
			time = time.plusMonths(3);
			break;
		case "3":
			time = null;
			break;
		default:
			time = time.plusWeeks(2);
			break;
		}

		return time;
	}

	/**
	 * Gets the end date of this timetable.
	 *
	 * @return The end date of this timetable.
	 */

	public final long getEndDate() {
		LocalDate max = null;
		for(final LocalDate date : lessons.getAllKeys()) {
			if(max != null && date.compareTo(max) <= 0) {
				continue;
			}
			max = date;
		}

		return max == null ? -1L : max.toDateTimeAtCurrentTime().getMillis();
	}

	/**
	 * Gets a list of weeks covered by this timetable.
	 *
	 * @return A list of weeks covered by this timetable.
	 */

	public final List<DateTime> getAvailableWeeks() {
		final long finalStart = getStartDate();
		final long aWeek = TimeUnit.DAYS.toMillis(7);

		int weeksNumber = 0;
		for(long start = finalStart; start < getEndDate(); start += aWeek) {
			weeksNumber++;
		}

		final List<DateTime> weeks = new ArrayList<DateTime>();

		for(int i = 0; i != weeksNumber; i++) {
			weeks.add(new DateTime(finalStart + i * aWeek));
		}

		return weeks;
	}

	/**
	 * Gets remaining lessons of the day.
	 *
	 * @return Remaining lessons of the day.
	 */

	public final Lesson[] getRemainingLessons() {
		final List<Timetable.Lesson> lessons = new ArrayList<Timetable.Lesson>(getLessonsOfToday());
		if(lessons.size() == 0) {
			return new Lesson[0];
		}
		Collections.sort(lessons);
		final Calendar now = Calendar.getInstance();
		for(final Timetable.Lesson lesson : new ArrayList<Timetable.Lesson>(lessons)) {
			if(!now.after(lesson.getEnd())) {
				continue;
			}
			lessons.remove(lesson);
		}
		return lessons.toArray(new Lesson[lessons.size()]);
	}

	/**
	 * Gets the next lesson of the day.
	 *
	 * @return The next lesson of the day.
	 */

	public final Lesson getNextLesson() {
		final Lesson[] nextLessons = getRemainingLessons();
		return nextLessons.length > 0 ? nextLessons[0] : null;
	}

	/**
	 * A class which represents a lesson.
	 */

	public class Lesson implements Serializable, Comparable<Lesson> {

		private final int id;
		private final String summary;
		private final String description;
		private final String location;
		private final Day day;
		private final Calendar start;
		private final Calendar end;

		/**
		 * Creates a lesson.
		 *
		 * @param summary The summary of this lesson.
		 * @param description The description of this lesson.
		 * @param location The location of this lesson.
		 * @param day The day of this lesson.
		 * @param start The start time of this lesson.
		 * @param end The end time of this lesson.
		 */

		public Lesson(final Summary summary, final Description description, final Location location, final Day day, final Calendar start, final Calendar end) {
			final Random random = new Random();
			int id;
			do {
				id = random.nextInt();
			}
			while(usedIds.contains(id));
			usedIds.add(id);
			this.id = id;

			this.summary = summary == null ? null : summary.getValue();
			this.description = description == null ? null : description.getValue();
			this.location = location == null ? null : location.getValue();

			this.day = day;
			this.start = start;
			this.end = end;
		}

		@Override
		public final int compareTo(@NonNull Lesson lesson) {
			return getStart().compareTo(lesson.getStart());
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

		public final String getSummary() {
			return summary;
		}

		/**
		 * Gets the description of this lesson.
		 *
		 * @return The description of this lesson.
		 */

		public final String getDescription() {
			return description;
		}

		/**
		 * Gets the location of this lesson.
		 *
		 * @return The location of this lesson.
		 */

		public final String getLocation() {
			return location;
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
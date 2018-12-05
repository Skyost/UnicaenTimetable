package fr.skyost.timetable.lesson;

import org.joda.time.DateTime;

import androidx.annotation.NonNull;
import androidx.room.Entity;
import androidx.room.Ignore;
import androidx.room.PrimaryKey;
import biweekly.component.VEvent;

/**
 * A class which represents a lesson.
 */

@Entity(tableName = Lesson.TABLE_NAME)
public class Lesson implements Comparable<Lesson> {

	/**
	 * The table.
	 */

	public static final String TABLE_NAME = "lessons";

	/**
	 * The ID.
	 */

	@PrimaryKey
	@NonNull
	private final String id;

	/**
	 * The summary.
	 */

	private final String summary;

	/**
	 * The description.
	 */

	private final String description;

	/**
	 * The location.
	 */

	private final String location;

	/**
	 * The start date.
	 */

	private final DateTime startDate;

	/**
	 * The end date.
	 */

	private final DateTime endDate;

	/**
	 * Creates a lesson.
	 *
	 * @param event The biweekly event.
	 */

	@Ignore
	public Lesson(final VEvent event) {
		this(event.getUid().toString(), event.getSummary() == null ? null : event.getSummary().getValue(), event.getDescription() == null ? null : event.getDescription().getValue(), event.getLocation() == null ? null : event.getLocation().getValue(), new DateTime(event.getDateStart().getValue()), new DateTime(event.getDateEnd().getValue()));
	}

	public Lesson(@NonNull final String id, final String summary, final String description, final String location, final DateTime startDate, final DateTime endDate) {
		this.id = id;
		this.summary = summary;
		this.description = description;
		this.location = location;
		this.startDate = startDate;
		this.endDate = endDate;
	}

	@Override
	public int compareTo(@NonNull final Lesson lesson) {
		return getStartDate().compareTo(lesson.getStartDate());
	}

	/**
	 * Returns the unique id of this lesson.
	 *
	 * @return The unique id of this lesson.
	 */

	public String getId() {
		return String.valueOf(id);
	}

	/**
	 * Returns the name of this lesson.
	 *
	 * @return The name of this lesson.
	 */

	public String getSummary() {
		return summary;
	}

	/**
	 * Returns the description of this lesson.
	 *
	 * @return The description of this lesson.
	 */

	public String getDescription() {
		return description;
	}

	/**
	 * Returns the location of this lesson.
	 *
	 * @return The location of this lesson.
	 */

	public String getLocation() {
		return location;
	}

	/**
	 * Returns the start date of this lesson.
	 *
	 * @return The start date of this lesson.
	 */

	public DateTime getStartDate() {
		return startDate;
	}

	/**
	 * Returns the end date of this lesson.
	 *
	 * @return The end date of this lesson.
	 */

	public DateTime getEndDate() {
		return endDate;
	}

}
package fr.skyost.timetable.lesson;

import android.content.SharedPreferences;

import com.alamkanak.weekview.WeekViewDisplayable;
import com.alamkanak.weekview.WeekViewEvent;

import org.jetbrains.annotations.NotNull;
import org.joda.time.DateTime;

import java.util.Locale;
import java.util.Random;

import androidx.annotation.NonNull;
import androidx.room.Entity;
import androidx.room.Ignore;
import androidx.room.PrimaryKey;
import biweekly.component.VEvent;
import fr.skyost.timetable.activity.MainActivity;
import fr.skyost.timetable.utils.Utils;

/**
 * A class which represents a lesson.
 */

@Entity(tableName = Lesson.TABLE_NAME)
public class Lesson implements WeekViewDisplayable<Lesson>, Comparable<Lesson> {

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
	 * The current color.
	 */

	@Ignore
	private Integer color;

	/**
	 * Creates a lesson.
	 *
	 * @param event The biweekly event.
	 */

	@Ignore
	public Lesson(final VEvent event) {
		this(event.getUid().getValue(), event.getSummary() == null ? null : event.getSummary().getValue(), event.getDescription() == null ? null : event.getDescription().getValue(), event.getLocation() == null ? null : event.getLocation().getValue(), new DateTime(event.getDateStart().getValue()), new DateTime(event.getDateEnd().getValue()));
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

	/**
	 * Loads the lesson color.
	 *
	 * @param activityPreferences The activity preferences.
	 * @param colorPreferences The color preferences.
	 * @param defaultColor The default color.
	 */

	public void loadColor(final SharedPreferences activityPreferences, final SharedPreferences colorPreferences, final int defaultColor) {
		if(colorPreferences.contains(summary)) {
			// If our event has a custom color, we return it.
			this.color = colorPreferences.getInt(summary, defaultColor);
			return;
		}
		else if(activityPreferences.getBoolean(MainActivity.PREFERENCES_AUTOMATICALLY_COLOR_LESSONS, false)) {
			// Else if the automatic lessons color are enabled, we return a random color (based on the event name).
			this.color = Utils.randomColor(150, Utils.splitEqually(summary, 3));
			return;
		}
		// Otherwise we return the default color.
		this.color = defaultColor;
	}

	/**
	 * Returns the color.
	 *
	 * @return The color.
	 */

	public Integer getColor() {
		return color;
	}

	/**
	 * Sets the color.
	 *
	 * @param color The color.
	 */

	public void setColor(final Integer color) {
		this.color = color;
	}

	@NotNull
	@Override
	public WeekViewEvent<Lesson> toWeekViewEvent() {
		long id;
		try {
			id = Long.parseLong(this.id.split("@")[0]);
		}
		catch(final Exception ex) {
			id = new Random().nextLong();
		}

		return new WeekViewEvent<>(
				id,
				summary,
				startDate.toCalendar(Locale.getDefault()),
				endDate.toCalendar(Locale.getDefault()),
				Utils.addZeroIfNeeded(startDate.getHourOfDay()) + ":" + Utils.addZeroIfNeeded(startDate.getMinuteOfHour()) + " - " + Utils.addZeroIfNeeded(endDate.getHourOfDay()) + ":" + Utils.addZeroIfNeeded(endDate.getMinuteOfHour()) + (description == null ? "" : "\n\n" + description),
				color,
				false,
				this
		);
	}

}
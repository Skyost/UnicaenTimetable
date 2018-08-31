package fr.skyost.timetable.fragment.day;

import android.content.SharedPreferences;

import com.alamkanak.weekview.WeekViewEvent;

import java.util.Locale;

import fr.skyost.timetable.activity.MainActivity;
import fr.skyost.timetable.lesson.Lesson;
import fr.skyost.timetable.utils.Utils;

/**
 * Represents a WeekView event.
 */

public class TimetableWeekViewEvent extends WeekViewEvent {

	/**
	 * A reference to the activity preferences.
	 */

	private final SharedPreferences activityPreferences;

	/**
	 * A reference to the color preferences.
	 */

	private final SharedPreferences colorPreferences;

	/**
	 * The default color.
	 */

	private final int defaultColor;

	TimetableWeekViewEvent(final Lesson lesson, final SharedPreferences activityPreferences, final SharedPreferences colorPreferences, final int defaultColor) {
		super(lesson.getId(), lesson.getSummary(), Utils.addZeroIfNeeded(lesson.getStartDate().getHourOfDay()) + ":" + Utils.addZeroIfNeeded(lesson.getStartDate().getMinuteOfHour()) + " - " + Utils.addZeroIfNeeded(lesson.getEndDate().getHourOfDay()) + ":" + Utils.addZeroIfNeeded(lesson.getEndDate().getMinuteOfHour()) + (lesson.getDescription() == null ? "" : "\n\n" + lesson.getDescription()), lesson.getStartDate().toCalendar(Locale.getDefault()), lesson.getEndDate().toCalendar(Locale.getDefault()));
		this.activityPreferences = activityPreferences;
		this.colorPreferences = colorPreferences;
		this.defaultColor = defaultColor;
	}

	@Override
	public int getColor() {
		final String name = getName();
		if(colorPreferences.contains(name)) {
			// If our event has a custom color, we return it.
			return colorPreferences.getInt(name, defaultColor);
		}
		else if(activityPreferences.getBoolean(MainActivity.PREFERENCES_AUTOMATICALLY_COLOR_LESSONS, false)) {
			// Else if the automatic lessons color are enabled, we return a random color (based on the event name).
			return Utils.randomColor(150, Utils.splitEqually(name, 3));
		}
		// Otherwise we return the default color.
		return defaultColor;
	}

	@Override
	public void setColor(final int color) {}

}
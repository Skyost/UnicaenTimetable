package fr.skyost.timetable.widget;

import org.joda.time.LocalDate;

/**
 * The today's widget date manager.
 */

public class TodayWidgetDateManager {

	/**
	 * Relative day (from today).
	 */

	private int relativeDay = 0;

	/**
	 * The instance holder.
	 */

	private static class Holder {

		/**
		 * The instance.
		 */

		private static final TodayWidgetDateManager INSTANCE = new TodayWidgetDateManager();

	}

	/**
	 * Returns the class instance.
	 *
	 * @return The class instance.
	 */

	public static TodayWidgetDateManager getInstance() {
		return Holder.INSTANCE;
	}

	/**
	 * Returns the relative day.
	 *
	 * @return The relative day.
	 */

	public int getRelativeDay() {
		return relativeDay;
	}

	/**
	 * Adds a day to the relative day count.
	 */

	public void plusRelativeDay() {
		this.relativeDay++;
	}

	/**
	 * Subtracts a day to the relative day count.
	 */

	public void minusRelativeDay() {
		this.relativeDay--;
	}

	/**
	 * Sets the relative day.
	 *
	 * @param relativeDay The relative day.
	 */

	public void setRelativeDay(final int relativeDay) {
		this.relativeDay = relativeDay;
	}

	/**
	 * Returns the current absolute day.
	 *
	 * @return The current absolute day.
	 */

	public LocalDate getAbsoluteDay() {
		return LocalDate.now().plusDays(relativeDay);
	}

}
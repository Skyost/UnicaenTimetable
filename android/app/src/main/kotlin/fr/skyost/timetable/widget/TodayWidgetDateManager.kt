package fr.skyost.timetable.widget

import org.joda.time.LocalDate

/**
 * The today's widget date manager.
 */
class TodayWidgetDateManager {
    /**
     * Relative day (from today).
     */
    var relativeDay = 0

    /**
     * The instance holder.
     */
    private object Holder {
        /**
         * The instance.
         */
        internal val INSTANCE = TodayWidgetDateManager()
    }

    /**
     * Adds a day to the relative day count.
     */
    fun plusRelativeDay() {
        relativeDay++
    }

    /**
     * Subtracts a day to the relative day count.
     */
    fun minusRelativeDay() {
        relativeDay--
    }

    /**
     * Returns the current absolute day.
     *
     * @return The current absolute day.
     */
    val absoluteDay: LocalDate
        get() = LocalDate.now().plusDays(relativeDay)

    companion object {
        /**
         * Returns the class instance.
         *
         * @return The class instance.
         */
        val instance: TodayWidgetDateManager
            get() = Holder.INSTANCE
    }
}
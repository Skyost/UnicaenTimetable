package fr.skyost.timetable.widget

import java.time.LocalDate

/**
 * Statically holds a relative day per widget.
 */
class TodayWidgetDateManager private constructor() {
    companion object {
        /**
         * The holders map.
         */
        private val holders: MutableMap<Int, Int> = HashMap()

        /**
         * Returns the class instance.
         *
         * @param widgetId The widget id.
         *
         * @return The class instance.
         */
        fun getRelativeDay(widgetId: Int): Int {
            var relativeDay = holders[widgetId]
            if (relativeDay == null) {
                relativeDay = 0
                changeRelativeDay(widgetId, relativeDay)
            }
            return relativeDay
        }

        /**
         * Returns the current absolute day.
         *
         * @param widgetId The widget id.
         *
         * @return The current absolute day.
         */
        fun resolveAbsoluteDay(widgetId: Int): LocalDate {
            return LocalDate.now().plusDays(getRelativeDay(widgetId).toLong())
        }

        /**
         * Returns the class instance.
         *
         * @param widgetId The widget id.
         * @param relativeDay The new relative day?
         *
         * @return The class instance.
         */
        fun changeRelativeDay(widgetId: Int, relativeDay: Int) {
            holders[widgetId] = relativeDay
        }
    }
}

package fr.skyost.timetable

import android.content.Context
import java.time.LocalDate
import java.time.LocalDateTime

/**
 * Represents a lesson.
 *
 * @param name The lesson name.
 * @param start The lesson start.
 * @param end The lesson end.
 * @param location The lesson location.
 */
data class Lesson(
    val name: String,
    val start: LocalDateTime,
    val end: LocalDateTime,
    val location: String?
) {
    companion object {
        /**
         * Reads the lesson list stored on the device for a specific date.
         *
         * @param context The context.
         * @param date The date.
         *
         * @return The lesson list.
         */
        fun readList(context: Context, date: LocalDate): List<Lesson> {

        }
    }
}

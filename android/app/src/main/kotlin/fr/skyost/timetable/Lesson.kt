package fr.skyost.timetable

import android.content.Context
import com.grack.nanojson.JsonArray
import com.grack.nanojson.JsonObject
import com.grack.nanojson.JsonParser
import io.flutter.util.PathUtils
import java.io.File
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.ZoneOffset
import java.time.format.DateTimeFormatter

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
            val file = File(PathUtils.getFilesDir(context), "lessons.json")
            if (!file.exists()) {
                return listOf()
            }
            val targetKey = date.format(DateTimeFormatter.ISO_LOCAL_DATE)
            val json: JsonObject = JsonParser.`object`().from(file.readText())
            for (key: String in json.keys) {
                if (key != targetKey) {
                    continue
                }
                val lessons: ArrayList<Lesson> = ArrayList()
                val jsonLessons: JsonArray = json.getArray(key)
                for (i in 0 until jsonLessons.size) {
                    val jsonLesson: JsonObject = jsonLessons.getObject(i)
                    lessons.add(
                        Lesson(
                            jsonLesson.getString("name"),
                            LocalDateTime.ofEpochSecond(
                                jsonLesson.getLong("start"),
                                0,
                                ZoneOffset.UTC
                            ),
                            LocalDateTime.ofEpochSecond(
                                jsonLesson.getLong("end"),
                                0,
                                ZoneOffset.UTC
                            ),
                            jsonLesson.getString("location")
                        )
                    )
                }
                return lessons
            }
            return listOf()
        }
    }
}

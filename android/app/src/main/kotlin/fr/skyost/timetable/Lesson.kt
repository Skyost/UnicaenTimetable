package fr.skyost.timetable

import android.content.Context
import com.grack.nanojson.JsonArray
import com.grack.nanojson.JsonObject
import com.grack.nanojson.JsonParser
import org.joda.time.DateTime
import org.joda.time.DateTimeFieldType
import org.joda.time.LocalDate
import java.io.File

class LessonRepository {
    private val lessons : HashMap<Long, ArrayList<Lesson>> = HashMap()

    fun load(context: Context) {
        val filesDir = File(context.getFilesDir().parentFile, "app_flutter")
        if(!filesDir.exists()) {
            return
        }

        val json : JsonObject = JsonParser.`object`().from(File(filesDir, "android_lessons.json").readText())
        for(key: String in json.keys) {
            val lessons: ArrayList<Lesson> = ArrayList()
            val jsonLessons : JsonArray = json.getArray(key)

            for(i in 0 until jsonLessons.size) {
                val jsonLesson: JsonObject = jsonLessons.getObject(i)
                lessons.add(Lesson(jsonLesson.getString("name"), DateTime(jsonLesson.getLong("start")), DateTime(jsonLesson.getLong("end")), jsonLesson.getString("location")))
            }

            this.lessons[key.toLong()] = lessons
        }
    }

    fun getLessonsForDate(date: LocalDate) : ArrayList<Lesson> {
        return lessons[date.toDateTimeAtStartOfDay().millis] ?: ArrayList()
    }

    /**
     * Returns the remaining lessons of the day.
     *
     * @return The remaining lessons of the day.
     */
    fun getRemainingLessons(): List<Lesson> {
        // We get the today's lessons.
        val now: DateTime = DateTime.now()
        val result: MutableList<Lesson> = getLessonsForDate(LocalDate.now())
        for (lesson in ArrayList(result)) {
            // If we are past the lesson, we remove it from the list.
            if (!now.isAfter(lesson.end)) {
                continue
            }
            result.remove(lesson)
        }
        return result
    }
}

data class Lesson(val name: String, val start: DateTime, val end: DateTime, val location: String?)
package fr.skyost.timetable.widget

import android.content.Context
import android.os.Build
import android.text.Html
import android.widget.AdapterView
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import fr.skyost.timetable.Lesson
import fr.skyost.timetable.LessonRepository
import fr.skyost.timetable.R
import fr.skyost.timetable.utils.Utils
import org.joda.time.DateTime
import org.joda.time.LocalDate
import java.util.*

/**
 * The today's widget RemoteViews factory.
 */
class TodayWidgetViewsFactory internal constructor(private val context: Context) : RemoteViewsService.RemoteViewsFactory {

    /**
     * The current items to display.
     */
    private var items: MutableList<String>? = null

    override fun getCount(): Int {
        return if (items == null) 0 else items!!.size
    }

    override fun getViewAt(i: Int): RemoteViews {
        val row = RemoteViews(context.packageName, R.layout.widget_today_row)
        if (i == AdapterView.INVALID_POSITION || i < 0 || i >= items!!.size) {
            return row
        }
        // We update the TextView text according to the SDK version.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            row.setTextViewText(R.id.widget_today_row, Html.fromHtml(items!![i], Html.FROM_HTML_MODE_COMPACT))
        } else {
            row.setTextViewText(R.id.widget_today_row, Html.fromHtml(items!![i]))
        }
        return row
    }

    override fun getItemId(position: Int): Long {
        return position.toLong()
    }

    override fun onCreate() {
        items = ArrayList()
    }

    override fun onDestroy() {
        if (items != null) {
            items!!.clear()
        }
    }

    override fun onDataSetChanged() {
        try {
            if (items == null) {
                return
            }
            items!!.clear()
            val date: LocalDate = TodayWidgetDateManager.instance.absoluteDay
            val repository = LessonRepository()
            repository.load(context)
            val lessons: List<Lesson> = repository.getLessonsForDate(date)
            if (lessons.isEmpty()) {
                // If there is nothing today, we show a message.
                items!!.add("<i>" + context.resources.getString(R.string.widget_today_nothing) + "</i>")
                return
            }
            val now: DateTime = DateTime.now()
            var nextLesson: Lesson? = null
            for (lesson in lessons) {
                if (!now.isAfter(lesson.end)) {
                    // If the lesson is not passed, we add it to the items list.
                    var content = "<b>" + lesson.name + "</b> :<br/>" + Utils.addLeadingZero(lesson.start.hourOfDay) + ":" + Utils.addLeadingZero(lesson.start.minuteOfHour) + " - " + Utils.addLeadingZero(lesson.end.hourOfDay) + ":" + Utils.addLeadingZero(lesson.end.minuteOfHour)
                    if (lesson.location != null) {
                        content += "<br/>" + "<i>" + lesson.location + "</i>"
                    }
                    items!!.add(content)
                    // We keep a reference to the next lesson.
                    if (nextLesson == null || lesson.end.isBefore(nextLesson.end)) {
                        nextLesson = lesson
                    }
                }
            }
            if (nextLesson == null) { // If there is nothing remaining, we also show a message.
                items!!.add("<i>" + context.resources.getString(R.string.widget_today_nothingremaining) + "</i>")
            }
        } catch (ex: Exception) {
            ex.printStackTrace()
            items!!.add("<i>" + context.resources.getString(R.string.widget_today_error) + "</i>")
        }
    }

    override fun getLoadingView(): RemoteViews {
        return RemoteViews(context.packageName, R.layout.widget_today_row)
    }

    override fun getViewTypeCount(): Int {
        return 1
    }

    override fun hasStableIds(): Boolean {
        return true
    }
}
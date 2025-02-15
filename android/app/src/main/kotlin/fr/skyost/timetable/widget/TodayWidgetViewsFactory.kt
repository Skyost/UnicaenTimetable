package fr.skyost.timetable.widget

import android.content.Context
import android.os.Build
import android.text.Html
import android.widget.AdapterView
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import fr.skyost.timetable.Lesson
import fr.skyost.timetable.R
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

/**
 * The today's widget RemoteViews factory.
 */
class TodayWidgetViewsFactory internal constructor(
    private val context: Context,
    private val widgetId: Int
) :
    RemoteViewsService.RemoteViewsFactory {

    companion object {
        /**
         * Converts today's lesson list to HTML.
         *
         * @param context The context.
         * @param lessons The lessons.
         *
         * @return The list of HTML items.
         */
        fun todayLessonListToHtml(context: Context, lessons: List<Lesson>): List<String> {
            val result = ArrayList<String>()
            if (lessons.isEmpty()) {
                // If there is nothing today, we show a message.
                result.add("<i>" + context.resources.getString(R.string.today_widget_nothing) + "</i>")
                return result
            }
            val now: LocalDateTime = LocalDateTime.now()
            var nextLesson: Lesson? = null
            val format = DateTimeFormatter.ofPattern("HH:mm")
            for (lesson in lessons) {
                if (!now.isAfter(lesson.end)) {
                    // If the lesson is not passed, we add it to the items list.
                    var content =
                        "<b>" + lesson.name + "</b> :<br/>" + lesson.start.format(format) + " - " + lesson.end.format(
                            format
                        )
                    if (lesson.location != null) {
                        content += "<br/>" + "<i>" + lesson.location + "</i>"
                    }
                    result.add(content)
                    // We keep a reference to the next lesson.
                    if (nextLesson == null || lesson.end.isBefore(nextLesson.end)) {
                        nextLesson = lesson
                    }
                }
            }
            if (nextLesson == null) { // If there is nothing remaining, we also show a message.
                result.add("<i>" + context.resources.getString(R.string.today_widget_nothingremaining) + "</i>")
            }

            return result
        }

        /**
         * Converts an HTML lesson to a remote views.
         *
         * @param context The context.
         * @param htmlLesson The HTML lesson.
         *
         * @return The remote views.
         */
        fun htmlLessonToRemoteView(context: Context, htmlLesson: String): RemoteViews {
            val row = RemoteViews(context.packageName, R.layout.today_widget_row)
            // We update the TextView text according to the SDK version.
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                row.setTextViewText(
                    R.id.today_widget_row,
                    Html.fromHtml(htmlLesson, Html.FROM_HTML_MODE_COMPACT)
                )
            } else {
                row.setTextViewText(R.id.today_widget_row, Html.fromHtml(htmlLesson))
            }
            return row
        }
    }


    /**
     * The current items to display.
     */
    private var items: MutableList<String>? = null

    override fun getCount(): Int {
        return if (items == null) 0 else items!!.size
    }

    override fun getViewAt(i: Int): RemoteViews {
        val row = RemoteViews(context.packageName, R.layout.today_widget_row)
        if (i == AdapterView.INVALID_POSITION || i < 0 || i >= items!!.size) {
            return row
        }
        return htmlLessonToRemoteView(context, items!![i])
    }

    override fun getItemId(position: Int): Long {
        return position.toLong()
    }

    override fun onCreate() {
        items = ArrayList()
    }

    override fun onDestroy() {
        if (items != null) {
            items = null
        }
    }

    override fun onDataSetChanged() {
        try {
            items?.clear()
            val date: LocalDate = TodayWidgetDateManager.resolveAbsoluteDay(widgetId)
            val lessons: List<Lesson> = Lesson.readList(context, date)
            items?.addAll(todayLessonListToHtml(context, lessons))
        } catch (ex: Exception) {
            ex.printStackTrace()
            items?.add("<i>" + context.resources.getString(R.string.today_widget_error) + "</i>")
        }
    }

    override fun getLoadingView(): RemoteViews {
        return RemoteViews(context.packageName, R.layout.today_widget_row)
    }

    override fun getViewTypeCount(): Int {
        return 1
    }

    override fun hasStableIds(): Boolean {
        return true
    }
}

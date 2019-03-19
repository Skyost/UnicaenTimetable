package fr.skyost.timetable.widget;

import android.content.Context;
import android.os.Build;
import android.text.Html;
import android.widget.AdapterView;
import android.widget.RemoteViews;
import android.widget.RemoteViewsService;

import org.joda.time.DateTime;

import java.util.ArrayList;
import java.util.List;

import fr.skyost.timetable.R;
import fr.skyost.timetable.lesson.Lesson;
import fr.skyost.timetable.lesson.database.AppDatabase;
import fr.skyost.timetable.utils.Utils;

/**
 * The today's widget RemoteViews factory.
 */

public class TodayWidgetViewsFactory implements RemoteViewsService.RemoteViewsFactory {

	/**
	 * The current items to display.
	 */

	private List<String> items;

	/**
	 * The current context.
	 */

	private final Context context;

	/**
	 * The application database.
	 */

	private final AppDatabase database;

	/**
	 * Creates a new today's widget RemoteViews factory instance.
	 *
	 * @param context The context.
	 * @param database The database.
	 */

	TodayWidgetViewsFactory(final Context context, final AppDatabase database) {
		this.context = context;
		this.database = database;
	}

	@Override
	public int getCount() {
		return items == null ? 0 : items.size();
	}

	@Override
	public RemoteViews getViewAt(final int i) {
		final RemoteViews row = new RemoteViews(context.getPackageName(), R.layout.widget_today_row);
		if(i == AdapterView.INVALID_POSITION || i < 0 || i >= items.size()) {
			return row;
		}

		// We update the TextView text according to the SDK version.
		if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
			row.setTextViewText(R.id.widget_today_row, Html.fromHtml(items.get(i), Html.FROM_HTML_MODE_COMPACT));
		}
		else {
			row.setTextViewText(R.id.widget_today_row, Html.fromHtml(items.get(i)));
		}
		return row;
	}

	@Override
	public long getItemId(final int position) {
		return position;
	}

	@Override
	public void onCreate() {
		items = new ArrayList<>();
	}

	@Override
	public void onDestroy() {
		if(items != null) {
			items.clear();
		}
	}

	@Override
	public void onDataSetChanged() {
		try {
			if(items == null) {
				return;
			}

			items.clear();

			final DateTime date = TodayWidgetDateManager.getInstance().getAbsoluteDay().toDateTimeAtStartOfDay();
			final List<Lesson> lessons = database.getLessonDao().getLessons(date, date.plusDays(1).withTimeAtStartOfDay());
			if(lessons.isEmpty()) {
				// If there is nothing today, we show a message.
				items.add("<i>" + context.getResources().getString(R.string.widget_today_nothing) + "</i>");
				return;
			}

			final DateTime now = DateTime.now();
			Lesson nextLesson = null;
			for(final Lesson lesson : lessons) {
				if(!now.isAfter(lesson.getEndDate())) {
					// If the lesson is not passed, we add it to the items list.
					String content = "<b>" + lesson.getSummary() + "</b> :<br/>" + Utils.addZeroIfNeeded(lesson.getStartDate().getHourOfDay()) + ":" + Utils.addZeroIfNeeded(lesson.getStartDate().getMinuteOfHour()) + " - " + Utils.addZeroIfNeeded(lesson.getEndDate().getHourOfDay()) + ":" + Utils.addZeroIfNeeded(lesson.getEndDate().getMinuteOfHour());
					if(lesson.getLocation() != null) {
						content += "<br/>" + "<i>" + lesson.getLocation() + "</i>";
					}
					items.add(content);

					// We keep a reference to the next lesson.
					if(nextLesson == null || lesson.getEndDate().isBefore(nextLesson.getEndDate())) {
						nextLesson = lesson;
					}
				}
			}

			if(nextLesson == null) {
				// If there is nothing remaining, we also show a message.
				items.add("<i>" + context.getResources().getString(R.string.widget_today_nothingremaining) + "</i>");
			}
		}
		catch(final Exception ex) {
			ex.printStackTrace();
			items.add("<i>" + context.getResources().getString(R.string.widget_today_error) + "</i>");
		}
	}

	@Override
	public RemoteViews getLoadingView() {
		return null;
	}

	@Override
	public int getViewTypeCount() {
		return 1;
	}

	@Override
	public boolean hasStableIds() {
		return true;
	}

	/**
	 * Returns the context.
	 *
	 * @return The context.
	 */

	public Context getContext() {
		return context;
	}

	/**
	 * Returns the database.
	 *
	 * @return The database.
	 */

	public AppDatabase getDatabase() {
		return database;
	}

}
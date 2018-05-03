package fr.skyost.timetable.services;

import android.content.Context;
import android.os.Build;
import android.text.Html;
import android.widget.RemoteViews;
import android.widget.RemoteViewsService;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import fr.skyost.timetable.R;
import fr.skyost.timetable.Timetable;
import fr.skyost.timetable.receivers.TodayWidgetReceiver;
import fr.skyost.timetable.utils.Utils;

public class TodayWidgetViewsFactory implements RemoteViewsService.RemoteViewsFactory {

	private final Context context;

	private String[] items;

	protected TodayWidgetViewsFactory(final Context context) {
		this.context = context;
	}

	@Override
	public final int getCount() {
		return items == null ? 0 : items.length;
	}

	@Override
	public final RemoteViews getViewAt(final int i) {
		final RemoteViews row = new RemoteViews(context.getPackageName(), R.layout.widget_today_row);
		if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
			row.setTextViewText(R.id.widget_today_row, Html.fromHtml(items[i], Html.FROM_HTML_MODE_COMPACT));
		}
		else {
			row.setTextViewText(R.id.widget_today_row, Html.fromHtml(items[i]));
		}
		return row;
	}

	@Override
	public final long getItemId(final int i) {
		return i;
	}

	@Override
	public final void onCreate() {}

	@Override
	public final void onDestroy() {}

	@Override
	public final void onDataSetChanged() {
		final List<String> items = new ArrayList<>();
		try {
			final List<Timetable.Lesson> lessons = new ArrayList<>(Timetable.loadFromDisk(context).getLessons(TodayWidgetReceiver.WidgetDateManager.getInstance().getAbsoluteDay()));
			if(lessons.size() == 0) {
				items.add("<i>" + context.getResources().getString(R.string.widget_today_nothing) + "</i>");
			}
			else {
				Collections.sort(lessons, new Comparator<Timetable.Lesson>() {

					@Override
					public final int compare(final Timetable.Lesson lesson1, final Timetable.Lesson lesson2) {
						return lesson1.getStart().compareTo(lesson2.getStart());
					}

				});

				final Calendar now = Calendar.getInstance();
				Timetable.Lesson nextLesson = null;
				for(final Timetable.Lesson lesson : lessons) {
					if(!now.after(lesson.getEnd())) {
						String content = "<b>" + lesson.getSummary() + "</b> :<br/>" + Utils.addZeroIfNeeded(lesson.getStart().get(Calendar.HOUR_OF_DAY)) + ":" + Utils.addZeroIfNeeded(lesson.getStart().get(Calendar.MINUTE)) + " - " + Utils.addZeroIfNeeded(lesson.getEnd().get(Calendar.HOUR_OF_DAY)) + ":" + Utils.addZeroIfNeeded(lesson.getEnd().get(Calendar.MINUTE));
						if(lesson.getLocation() != null) {
							content += "<br/>" + "<i>" + lesson.getLocation() + "</i>";
						}
						items.add(content);

						if(nextLesson == null || lesson.getEnd().getTimeInMillis() < nextLesson.getEnd().getTimeInMillis()) {
							nextLesson = lesson;
						}
					}
				}

				if(nextLesson == null) {
					items.add("<i>" + context.getResources().getString(R.string.widget_today_nothingremaining) + "</i>");
				}
			}
		}
		catch(final Exception ex) {
			ex.printStackTrace();
			items.add("<i>" + context.getResources().getString(R.string.widget_today_error) + "</i>");
		}
		this.items = items.toArray(new String[items.size()]);
	}

	@Override
	public final RemoteViews getLoadingView() {
		return null;
	}

	@Override
	public final int getViewTypeCount() {
		return 1;
	}

	@Override
	public final boolean hasStableIds() {
		return true;
	}

}
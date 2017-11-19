package fr.skyost.timetable.services;

import android.os.Build;
import android.text.Html;
import android.widget.RemoteViews;
import android.widget.RemoteViewsService;

import fr.skyost.timetable.R;

public class TodayWidgetViewsFactory implements RemoteViewsService.RemoteViewsFactory {

	private String packageName;
	private String[] items;

	public TodayWidgetViewsFactory(final String packageName, final String[] items) {
		this.packageName = packageName;
		this.items = items;
	}

	@Override
	public final int getCount() {
		return items.length;
	}

	@Override
	public final RemoteViews getViewAt(final int i) {
		final RemoteViews row = new RemoteViews(packageName, R.layout.widget_today_row);
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
	public final void onDataSetChanged() {}

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
package fr.skyost.timetable.fragments;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.res.Resources;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.content.ContextCompat;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.style.ForegroundColorSpan;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import java.text.DateFormat;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import fr.skyost.timetable.R;

import fr.skyost.timetable.activities.MainActivity;
import hotchemi.android.rate.AppRate;

public class DefaultFragment extends Fragment {

	@Override
	public final View onCreateView(final LayoutInflater inflater, final ViewGroup container, final Bundle savedInstanceState) {
		final Activity activity = this.getActivity();
		AppRate.with(activity).setInstallDays(3).showRateDialogIfMeetsConditions(activity);

		final View view = inflater.inflate(R.layout.fragment_main_default, container, false);

		final TextView description = (TextView)view.findViewById(R.id.main_default_textview_description);
		if(description == null) {
			return view;
		}

		final SharedPreferences preferences = this.getActivity().getSharedPreferences(MainActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE);
		final long updateTime = preferences.getLong(MainActivity.PREFERENCES_LAST_UPDATE, -1L);
		final Resources resources = this.getResources();
		final HashMap<String, Integer> colors = new HashMap<String, Integer>();

		if(updateTime == -1L) {
			final String never = resources.getString(R.string.main_default_description_never);
			description.setText(resources.getString(R.string.main_default_description, never));
			colors.put(never, ContextCompat.getColor(activity, R.color.colorUpdateRequired));

			description.setText(addColors(description.getText().toString(), colors));
			return view;
		}

		final Calendar current = Calendar.getInstance();
		current.setTimeInMillis(updateTime);

		final String date = DateFormat.getDateTimeInstance().format(current.getTime());
		if(Calendar.getInstance().getTimeInMillis() - updateTime > TimeUnit.DAYS.toMillis(7)) {
			final String text = date + " " + resources.getString(R.string.main_default_description_updaterequired);
			description.setText(resources.getString(R.string.main_default_description, text));

			colors.put(text, ContextCompat.getColor(activity, R.color.colorUpdateRequired));
		}
		else {
			description.setText(resources.getString(R.string.main_default_description, date));

			colors.put(date, ContextCompat.getColor(activity, R.color.colorUpdated));
		}
		description.setText(addColors(description.getText().toString(), colors));

		return view;
	}

	/**
	 * Add some colors to the text.
	 *
	 * @param text The text.
	 * @param colors The links (text : color).
	 *
	 * @return The Spannable, ready to use.
	 */

	private final Spannable addColors(final String text, final Map<String, Integer> colors) {
		final Spannable spannable = new SpannableString(text);
		for(final Map.Entry<String, Integer> entry : colors.entrySet()) {
			final String colorText = entry.getKey();
			spannable.setSpan(new ForegroundColorSpan(entry.getValue()), text.indexOf(colorText), text.indexOf(colorText) + colorText.length(), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
		}
		System.out.println(spannable);
		return spannable;
	}

}
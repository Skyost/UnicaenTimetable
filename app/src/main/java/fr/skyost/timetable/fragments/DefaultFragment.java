package fr.skyost.timetable.fragments;

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

import fr.skyost.timetable.R;

import fr.skyost.timetable.Timetable;
import fr.skyost.timetable.activities.MainActivity;

public class DefaultFragment extends Fragment {

	@Override
	public final View onCreateView(final LayoutInflater inflater, final ViewGroup container, final Bundle savedInstanceState) {
		final MainActivity activity = (MainActivity)this.getActivity();
		final View view = inflater.inflate(R.layout.fragment_main_default, container, false);

		final TextView description = view.findViewById(R.id.main_default_textview_description);
		if(description == null) {
			return view;
		}

		final Timetable timetable = activity.getTimetable();

		final Resources resources = this.getResources();
		final HashMap<String, Integer> colors = new HashMap<>();

		if(timetable == null || timetable.getLastModificationTime(activity) == -1) {
			final String never = resources.getString(R.string.main_default_description_never);
			description.setText(resources.getString(R.string.main_default_description, never));
			colors.put(never, ContextCompat.getColor(activity, R.color.colorUpdateRequired));

			description.setText(addColors(description.getText().toString(), colors));
			return view;
		}

		final Calendar updateCalendar = Calendar.getInstance();
		updateCalendar.setTimeInMillis(timetable.getLastModificationTime(activity));

		final String date = DateFormat.getDateTimeInstance().format(updateCalendar.getTime());
		if(Calendar.getInstance().getTimeInMillis() > timetable.getEndDate()) {
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

	private Spannable addColors(final String text, final Map<String, Integer> colors) {
		final Spannable spannable = new SpannableString(text);
		for(final Map.Entry<String, Integer> entry : colors.entrySet()) {
			final String colorText = entry.getKey();
			spannable.setSpan(new ForegroundColorSpan(entry.getValue()), text.indexOf(colorText), text.indexOf(colorText) + colorText.length(), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
		}
		return spannable;
	}

}
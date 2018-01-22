package fr.skyost.timetable.fragments;

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

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.text.DateFormat;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Map;

import fr.skyost.timetable.R;

import fr.skyost.timetable.Timetable;
import fr.skyost.timetable.activities.MainActivity;

public class DefaultFragment extends Fragment {

	public static final String UPDATE_TIME_FILE = "update_time";

	@Override
	public final View onCreateView(final LayoutInflater inflater, final ViewGroup container, final Bundle savedInstanceState) {
		final MainActivity activity = (MainActivity)this.getActivity();
		final View view = inflater.inflate(R.layout.fragment_main_default, container, false);

		final TextView description = view.findViewById(R.id.main_default_textview_description);
		if(description == null) {
			return view;
		}

		final long updateTime = getUpdateTime();

		final Resources resources = this.getResources();
		final HashMap<String, Integer> colors = new HashMap<>();

		final Timetable timetable = activity.getTimetable();
		if(updateTime == -1L || timetable == null) {
			final String never = resources.getString(R.string.main_default_description_never);
			description.setText(resources.getString(R.string.main_default_description, never));
			colors.put(never, ContextCompat.getColor(activity, R.color.colorUpdateRequired));

			description.setText(addColors(description.getText().toString(), colors));
			return view;
		}

		final Calendar updateCalendar = Calendar.getInstance();
		updateCalendar.setTimeInMillis(updateTime);

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

	/**
	 * Gets the last update time.
	 *
	 * @return The last update time.
	 */

	private long getUpdateTime() {
		final SharedPreferences preferences = this.getActivity().getSharedPreferences(MainActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE);
		long updateTime = preferences.getLong(MainActivity.PREFERENCES_LAST_UPDATE, -1L);
		preferences.edit().remove(MainActivity.PREFERENCES_LAST_UPDATE).apply();

		try {
			final InputStream input = this.getActivity().openFileInput(UPDATE_TIME_FILE);

			final InputStreamReader streamReader = new InputStreamReader(input);
			final BufferedReader bufferedReader = new BufferedReader(streamReader);

			final String line = bufferedReader.readLine();
			if(line != null) {
				updateTime = Long.parseLong(line);
			}

			bufferedReader.close();
			streamReader.close();
			input.close();
		}
		catch(final FileNotFoundException ex) {
			return updateTime;
		}
		catch(final Exception ex) {
			ex.printStackTrace();
		}

		return updateTime;
	}

}
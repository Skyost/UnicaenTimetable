package fr.skyost.timetable.fragment;

import android.arch.lifecycle.ViewModelProviders;
import android.content.Context;
import android.content.res.Resources;
import android.os.Bundle;
import android.support.annotation.NonNull;
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

import org.joda.time.DateTime;

import java.text.DateFormat;
import java.util.HashMap;
import java.util.Map;

import fr.skyost.timetable.R;
import fr.skyost.timetable.activity.MainActivity;
import fr.skyost.timetable.lesson.LessonModel;
import fr.skyost.timetable.lesson.database.LessonDao;

/**
 * The default fragment.
 */

public class DefaultFragment extends Fragment {

	@Override
	public View onCreateView(@NonNull final LayoutInflater inflater, final ViewGroup container, final Bundle savedInstanceState) {
		// We get the required variables.
		final View view = inflater.inflate(R.layout.fragment_main_default, container, false);

		final MainActivity activity = (MainActivity)this.getActivity();
		final TextView description = view.findViewById(R.id.main_default_textview_description);
		if(activity == null || description == null) {
			return view;
		}

		// And we listen to our "expiration" date.
		final LessonModel model = ViewModelProviders.of(activity).get(LessonModel.class);
		model.getExpirationDateLiveData().observe(this, expiration -> {
			final Resources resources = this.getResources();
			final HashMap<String, Integer> colors = new HashMap<>();

			// We get a reference to the last modification time.
			final long lastModificationTime = activity.getSharedPreferences(LessonDao.PREFERENCE_FILE, Context.MODE_PRIVATE).getLong(LessonDao.PREFERENCE_LAST_MODIFICATION, -1);
			if(lastModificationTime == -1) {
				// If never modified (-1), we update the text in consequence.
				final String never = resources.getString(R.string.main_default_description_never);
				description.setText(resources.getString(R.string.main_default_description, never));
				colors.put(never, ContextCompat.getColor(activity, R.color.colorUpdateRequired));
				description.setText(addColors(description.getText().toString(), colors));
				return;
			}

			final DateTime update = new DateTime(lastModificationTime);
			final String date = DateFormat.getDateTimeInstance().format(update.toDate());
			if(DateTime.now().isAfter(expiration)) {
				// If we're past the expiration, it's not good !
				final String text = date + " " + resources.getString(R.string.main_default_description_updaterequired);
				description.setText(resources.getString(R.string.main_default_description, text));
				colors.put(text, ContextCompat.getColor(activity, R.color.colorUpdateRequired));
			}
			else {
				// Otherwise everything is fine.
				description.setText(resources.getString(R.string.main_default_description, date));
				colors.put(date, ContextCompat.getColor(activity, R.color.colorUpdated));
			}
			description.setText(addColors(description.getText().toString(), colors));
		});

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
		// cf. createLinks from AboutActivity (~ the same thing).
		final Spannable spannable = new SpannableString(text);
		for(final Map.Entry<String, Integer> entry : colors.entrySet()) {
			final String colorText = entry.getKey();
			spannable.setSpan(new ForegroundColorSpan(entry.getValue()), text.indexOf(colorText), text.indexOf(colorText) + colorText.length(), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
		}
		return spannable;
	}

}
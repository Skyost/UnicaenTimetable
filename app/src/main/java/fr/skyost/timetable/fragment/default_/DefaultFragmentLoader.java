package fr.skyost.timetable.fragment.default_;

import android.os.AsyncTask;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.style.ForegroundColorSpan;
import android.view.View;
import android.widget.TextView;

import org.joda.time.DateTime;

import java.text.DateFormat;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.atomic.AtomicReference;

import androidx.core.content.ContextCompat;
import androidx.fragment.app.FragmentActivity;
import androidx.lifecycle.ViewModelProviders;
import fr.skyost.timetable.R;
import fr.skyost.timetable.lesson.LessonModel;

/**
 * The task that allows to load the default fragment.
 */

public class DefaultFragmentLoader extends AsyncTask<Void, Void, DateTime> {

	/**
	 * The default fragment.
	 */

	private DefaultFragment fragment;

	/**
	 * The view reference.
	 */

	private AtomicReference<View> view;

	/**
	 * Creates a new default fragment loader instance.
	 *
	 * @param fragment The fragment.
	 * @param view The view.
	 */

	DefaultFragmentLoader(final DefaultFragment fragment, final View view) {
		this.fragment = fragment;
		this.view = new AtomicReference<>(view);
	}

	@Override
	protected DateTime doInBackground(final Void... voids) {
		final FragmentActivity activity = fragment.getActivity();
		if(activity == null) {
			return null;
		}

		final LessonModel model = ViewModelProviders.of(activity).get(LessonModel.class);
		return model.getMaxEndDate();
	}

	@Override
	protected void onPostExecute(DateTime expiration) {
		if(expiration == null) {
			expiration = DateTime.now().minusSeconds(1);
		}

		final FragmentActivity activity = fragment.getActivity();
		final View view = this.view.get();
		if(activity == null || view == null) {
			return;
		}

		final TextView description = view.findViewById(R.id.main_default_textview_description);
		final HashMap<String, Integer> colors = new HashMap<>();

		// We get a reference to the last modification time.
		long lastModificationTime = -1;
		try {
			lastModificationTime = ViewModelProviders.of(activity).get(LessonModel.class).getLastModificationTime(activity);
		}
		catch(final Exception ex) {
			ex.printStackTrace();
		}

		if(lastModificationTime == -1) {
			// If never modified (-1), we update the text in consequence.
			final String never = fragment.getString(R.string.main_default_description_never);
			description.setText(fragment.getString(R.string.main_default_description, never));
			colors.put(never, ContextCompat.getColor(activity, R.color.colorUpdateRequired));
			description.setText(addColors(description.getText().toString(), colors));
			return;
		}

		final DateTime update = new DateTime(lastModificationTime);
		final String date = DateFormat.getDateTimeInstance().format(update.toDate());
		if(DateTime.now().isAfter(expiration)) {
			// If we're past the expiration, it's not good !
			final String text = date + " " + fragment.getString(R.string.main_default_description_updaterequired);
			description.setText(fragment.getString(R.string.main_default_description, text));
			colors.put(text, ContextCompat.getColor(activity, R.color.colorUpdateRequired));
		}
		else {
			// Otherwise everything is fine.
			description.setText(fragment.getString(R.string.main_default_description, date));
			colors.put(date, ContextCompat.getColor(activity, R.color.colorUpdated));
		}
		description.setText(addColors(description.getText().toString(), colors));
	}

	/**
	 * Returns the fragment.
	 *
	 * @return The fragment.
	 */

	public DefaultFragment getFragment() {
		return fragment;
	}

	/**
	 * Returns the view atomic reference.
	 *
	 * @return The view atomic reference.
	 */

	public AtomicReference<View> getView() {
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
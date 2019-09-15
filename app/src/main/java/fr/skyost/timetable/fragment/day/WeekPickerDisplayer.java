package fr.skyost.timetable.fragment.day;

import android.os.AsyncTask;

import androidx.appcompat.app.AlertDialog;
import androidx.arch.core.util.Function;

import org.joda.time.DateTimeConstants;
import org.joda.time.LocalDate;

import java.util.ArrayList;
import java.util.List;

import fr.skyost.timetable.R;
import fr.skyost.timetable.activity.MainActivity;
import fr.skyost.timetable.lesson.LessonModel;

/**
 * The AsyncTask that allows to display the week picker.
 */

public class WeekPickerDisplayer extends AsyncTask<MainActivity, Void, AlertDialog.Builder> {

	/**
	 * The lesson model.
	 */

	private final LessonModel model;

	/**
	 * The callback.
	 */

	private final Function<LocalDate, Void> callback;

	/**
	 * Creates a new week picker displayer instance.
	 *
	 * @param callback The callback.
	 */

	public WeekPickerDisplayer(final LessonModel model, final Function<LocalDate, Void> callback) {
		this.model = model;
		this.callback = callback;
	}

	@Override
	protected void onPreExecute() {
		super.onPreExecute();
	}

	@Override
	protected AlertDialog.Builder doInBackground(final MainActivity... activities) {
		final MainActivity activity = activities[0];
		final List<LocalDate> availableWeeks = model.getAvailableWeeks();

		// If there is no available week, we tell the user.
		if(availableWeeks == null || availableWeeks.isEmpty()) {
			return new AlertDialog.Builder(activity)
					.setTitle(R.string.dialog_error_notimetable_title)
					.setMessage(R.string.dialog_error_notimetable_message)
					.setPositiveButton(R.string.dialog_generic_button_positive, null);
		}

		// We create a list of strings (from the previous list).
		final List<String> formattedWeeks = new ArrayList<>();
		for(final LocalDate date : availableWeeks) {
			formattedWeeks.add(model.formatWeek(date));
		}

		// And we return our builder.
		final LocalDate date = activity.getCurrentDate();
		return new AlertDialog.Builder(activity)
				.setTitle(R.string.day_menu_week)
				.setSingleChoiceItems(formattedWeeks.toArray(new String[0]), availableWeeks.indexOf(date.withDayOfWeek(DateTimeConstants.MONDAY)), (dialog, id) -> {
					// We show the fragment of the selected date.
					final LocalDate selected = availableWeeks.get(id).withDayOfWeek(date.getDayOfWeek());
					callback.apply(selected);
					dialog.dismiss();
				});
	}

	@Override
	protected void onPostExecute(final AlertDialog.Builder builder) {
		super.onPostExecute(builder);

		// Finally, we can show the dialog to the user.
		if(builder != null) {
			builder.show();
		}
	}

	/**
	 * Returns the current lesson model.
	 *
	 * @return The current lesson model.
	 */

	public LessonModel getModel() {
		return model;
	}

	/**
	 * Returns the callback.
	 *
	 * @return The callback.
	 */

	public Function<LocalDate, Void> getCallback() {
		return callback;
	}

}
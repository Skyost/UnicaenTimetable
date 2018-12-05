package fr.skyost.timetable.fragment.day;

import android.os.AsyncTask;

import org.joda.time.DateTimeConstants;
import org.joda.time.LocalDate;

import java.util.ArrayList;
import java.util.List;

import androidx.appcompat.app.AlertDialog;
import androidx.lifecycle.ViewModelProviders;
import fr.skyost.timetable.R;
import fr.skyost.timetable.activity.MainActivity;
import fr.skyost.timetable.lesson.LessonModel;

/**
 * The AsyncTask that allows to display the week picker.
 */

public class WeekPickerDisplayer extends AsyncTask<DayFragment, Void, AlertDialog.Builder> {

	@Override
	protected AlertDialog.Builder doInBackground(final DayFragment... fragments) {
		final DayFragment fragment = fragments[0];
		final MainActivity activity = (MainActivity)fragment.getActivity();
		if(activity == null) {
			return null;
		}

		final LessonModel model = ViewModelProviders.of(activity).get(LessonModel.class);
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
		return new AlertDialog.Builder(activity)
				.setTitle(R.string.day_menu_week)
				.setSingleChoiceItems(formattedWeeks.toArray(new String[0]), availableWeeks.indexOf(fragment.getDate().withDayOfWeek(DateTimeConstants.MONDAY)), (dialog, id) -> {
					// We show the fragment of the selected date.
					final LocalDate selected = availableWeeks.get(id).withDayOfWeek(fragment.getDate().getDayOfWeek());
					activity.showFragment(selected);
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

}
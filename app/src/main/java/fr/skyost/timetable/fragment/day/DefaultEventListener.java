package fr.skyost.timetable.fragment.day;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.RectF;
import android.provider.AlarmClock;

import androidx.appcompat.app.AlertDialog;
import androidx.core.content.ContextCompat;

import com.alamkanak.weekview.EventClickListener;
import com.alamkanak.weekview.EventLongPressListener;
import com.alamkanak.weekview.WeekViewEvent;
import com.flask.colorpicker.ColorPickerView;
import com.flask.colorpicker.builder.ColorPickerDialogBuilder;

import org.jetbrains.annotations.NotNull;

import java.util.Calendar;

import de.mateware.snacky.Snacky;
import fr.skyost.timetable.R;
import fr.skyost.timetable.activity.MainActivity;
import fr.skyost.timetable.activity.settings.SettingsActivity;
import fr.skyost.timetable.lesson.Lesson;

/**
 * The default event listener class.
 */

public class DefaultEventListener implements EventLongPressListener<Lesson>, EventClickListener<Lesson> {

	/**
	 * The preference file that stores lesson colors.
	 */

	public static final String COLOR_PREFERENCES_FILE = "colors";

	/**
	 * The main activity.
	 */

	private final MainActivity activity;

	/**
	 * The default event listener.
	 *
	 * @param activity The main activity.
	 */

	public DefaultEventListener(final MainActivity activity) {
		this.activity = activity;
	}

	@Override
	public void onEventClick(final Lesson lesson, @NotNull final RectF rectF) {
		// We show a dialog that displays some info about the event.
		final WeekViewEvent<Lesson> event = lesson.toWeekViewEvent();
		new AlertDialog.Builder(activity)
				.setMessage(event.getTitle() + "\n" + event.getLocation())
				.setNeutralButton(R.string.dialog_event_button_neutral, (dialog, which) -> {
					try {
						// We can start the alarm manager.
						final Calendar start = event.getStartTime();
						final Intent intent = new Intent(AlarmClock.ACTION_SET_ALARM);
						intent.putExtra(AlarmClock.EXTRA_MESSAGE, event.getTitle());
						intent.putExtra(AlarmClock.EXTRA_HOUR, start.get(Calendar.HOUR_OF_DAY));
						intent.putExtra(AlarmClock.EXTRA_MINUTES, start.get(Calendar.MINUTE));
						activity.startActivity(intent);
					}
					catch(final Exception ex) {
						Snacky.builder().setActivity(activity).setText(R.string.main_snackbar_error_alarm).error().show();
					}
				})
				.setPositiveButton(R.string.dialog_generic_button_positive, null)
				.setNegativeButton(R.string.dialog_event_button_negative, (dialog, which) -> {
					// The negative button allows to reset the event color.
					final SharedPreferences colorPreferences = activity.getSharedPreferences(COLOR_PREFERENCES_FILE, Context.MODE_PRIVATE);
					colorPreferences.edit().remove(event.getTitle()).apply();
					dialog.dismiss();
					activity.refreshCurrentFragment();
				})
				.show();

		// When an event is clicked, we show a little message in the SnackBar to tell the user that he can change the event color.
		final SharedPreferences activityPreferences = activity.getSharedPreferences(SettingsActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE);
		if(activityPreferences.getBoolean(SettingsActivity.PREFERENCES_TIP_SHOW_CHANGECOLOR, true)) {
			Snacky.builder().setActivity(activity).setText(R.string.main_snackbar_changecolor).info().show();
			activityPreferences.edit().putBoolean(SettingsActivity.PREFERENCES_TIP_SHOW_CHANGECOLOR, false).apply();
		}
	}

	@Override
	public void onEventLongPress(final Lesson lesson, @NotNull final RectF rectF) {
		// When the user press longer on an event, we show the color picker dialog.
		final ColorPickerDialogBuilder builder = ColorPickerDialogBuilder.with(activity)
				.setTitle(R.string.dialog_color_title)
				.wheelType(ColorPickerView.WHEEL_TYPE.CIRCLE)
				.setPositiveButton(R.string.dialog_generic_button_positive, (dialog, selectedColor, allColors) -> {
					// Pressing the positive button allows to change the event color.
					final SharedPreferences colorPreferences = activity.getSharedPreferences(COLOR_PREFERENCES_FILE, Context.MODE_PRIVATE);
					colorPreferences.edit().putInt(lesson.getSummary(), selectedColor).commit();
					activity.refreshCurrentFragment();
				})
				.setNegativeButton(R.string.dialog_generic_button_cancel, (dialog, which) -> dialog.dismiss());

		// If the event already has a custom color, we set it in our builder.
		if(lesson.getColor() != ContextCompat.getColor(activity, R.color.colorWeekViewEventDefault)) {
			builder.initialColor(lesson.getColor());
		}
		builder.build().show();
	}

	/**
	 * Returns the main activity.
	 *
	 * @return The main activity.
	 */

	public MainActivity getActivity() {
		return activity;
	}

}

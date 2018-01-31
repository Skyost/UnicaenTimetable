package fr.skyost.timetable.fragments;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.graphics.RectF;
import android.os.Bundle;
import android.provider.AlarmClock;
import android.support.annotation.NonNull;
import android.support.v4.app.Fragment;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AlertDialog;
import android.text.format.DateFormat;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Toast;

import com.alamkanak.weekview.DateTimeInterpreter;
import com.alamkanak.weekview.MonthLoader;
import com.alamkanak.weekview.WeekViewEvent;
import com.flask.colorpicker.ColorPickerView;
import com.flask.colorpicker.builder.ColorPickerClickListener;
import com.flask.colorpicker.builder.ColorPickerDialogBuilder;

import org.joda.time.DateTime;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.TimeUnit;

import de.mateware.snacky.Snacky;
import fr.skyost.timetable.R;
import fr.skyost.timetable.Timetable;
import fr.skyost.timetable.Timetable.Day;
import fr.skyost.timetable.Timetable.Lesson;
import fr.skyost.timetable.activities.MainActivity;
import fr.skyost.timetable.utils.Utils;
import fr.skyost.timetable.utils.WeekView;

public class DayFragment extends Fragment {

	private static final int ALARM_SET_REQUEST_CODE = 100;

	private static final double DEFAULT_HOUR = 7d;

	private static final String COLOR_PREFERENCES_FILE = "colors";

	private Day day;

	@Override
	public final void onCreate(final Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		final Bundle args = this.getArguments();
		if(args != null) {
			day = Day.valueOf(args.getString(Day.class.getName().toLowerCase()));
		}
	}

	@Override
	public final View onCreateView(final LayoutInflater inflater, final ViewGroup container, final Bundle savedInstanceState) {
		final View view = inflater.inflate(R.layout.fragment_main_day, container, false);
		final MainActivity activity = (MainActivity)DayFragment.this.getActivity();

		final WeekView weekView = view.findViewById(R.id.main_day_weekview_day);
		weekView.setDateTimeInterpreter(new DateTimeInterpreter() {

			@Override
			public final String interpretDate(final Calendar calendar) {
				final Date date = calendar.getTime();
				return new SimpleDateFormat("E", Locale.getDefault()).format(date) + " " + DateFormat.getDateFormat(activity).format(date);
			}

			@Override
			public final String interpretTime(final int hour, final int minutes) {
				return Utils.addZeroIfNeeded(hour) + ":" + Utils.addZeroIfNeeded(minutes);
			}

		});

		final SharedPreferences activityPreferences = activity.getSharedPreferences(MainActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE);
		final SharedPreferences colorPreferences = activity.getSharedPreferences(COLOR_PREFERENCES_FILE, Context.MODE_PRIVATE);

		final Calendar calendar = Calendar.getInstance();
		if(activity.baseWeek != -1) {
			final List<DateTime> availableWeeks = activity.getTimetable().getAvailableWeeks();
			if(availableWeeks.size() > activity.baseWeek) {
				calendar.setTimeInMillis(availableWeeks.get(activity.baseWeek).getMillis());
			}
			else if(!availableWeeks.isEmpty()) {
				final int size = availableWeeks.size() - 1;
				calendar.setTimeInMillis(availableWeeks.get(size).getMillis() + TimeUnit.DAYS.toMillis(7 * (activity.baseWeek - size)));
			}
		}
		final int currentDay = calendar.get(Calendar.DAY_OF_WEEK);
		if(currentDay == Calendar.SATURDAY || currentDay == Calendar.SUNDAY) {
			final long aWeek = TimeUnit.DAYS.toMillis(7);
			calendar.setTimeInMillis(calendar.getTimeInMillis() + aWeek);
		}
		calendar.set(Calendar.DAY_OF_WEEK, day.getValue());

		weekView.setMinDate(calendar);
		weekView.setMaxDate(calendar);
		weekView.goToDate(calendar);
		weekView.setHorizontalFlingEnabled(false);
		weekView.goToHour(DEFAULT_HOUR);
		weekView.setMonthChangeListener(new MonthLoader.MonthChangeListener() {

			@Override
			public final List<? extends WeekViewEvent> onMonthChange(final int newYear, final int newMonth) {
				final List<WeekViewEvent> events = new ArrayList<>();

				final Timetable timetable = activity.getTimetable();
				if(timetable == null) {
					return events;
				}

				for(final Lesson lesson : timetable.getLessons(calendar)) {
					events.add(new TimetableWeekViewEvent(lesson, activityPreferences, colorPreferences));
				}

				return events;
			}
		});
		weekView.setEventLongPressListener(new WeekView.EventLongPressListener() {

			@Override
			public final void onEventLongPress(final WeekViewEvent event, final RectF eventRect) {
				final ColorPickerDialogBuilder builder = ColorPickerDialogBuilder.with(DayFragment.this.getContext());
				builder.setTitle(R.string.dialog_color_title);
				builder.wheelType(ColorPickerView.WHEEL_TYPE.CIRCLE);
				builder.setPositiveButton(R.string.dialog_generic_button_positive, new ColorPickerClickListener() {

					@Override
					public final void onClick(final DialogInterface dialog, final int selectedColor, final Integer[] allColors) {
						colorPreferences.edit().putInt(event.getName(), selectedColor).apply();
						activity.showFragment(activity.currentMenuSelected);
					}

				});
				builder.setNegativeButton(R.string.dialog_generic_button_cancel, new DialogInterface.OnClickListener() {

					@Override
					public void onClick(final DialogInterface dialog, final int which) {
						dialog.dismiss();
					}

				});
				if(event.getColor() != ContextCompat.getColor(activity, R.color.colorWeekViewEventDefault)) {
					builder.initialColor(event.getColor());
				}
				builder.build().show();
			}

		});
		weekView.setOnEventClickListener(new WeekView.EventClickListener() {

			@Override
			public final void onEventClick(final WeekViewEvent event, final RectF eventRect) {
				final AlertDialog.Builder builder = new AlertDialog.Builder(activity);
				final String name = event.getName();
				builder.setMessage(name + "\n" + event.getLocation());
				builder.setNeutralButton(R.string.dialog_event_button_neutral, new DialogInterface.OnClickListener() {

					@Override
					public final void onClick(final DialogInterface dialog, final int which) {
						final Calendar start = event.getStartTime();

						final Intent intent = activity.getIntent();
						intent.putExtra(AlarmClock.EXTRA_MESSAGE, name);
						intent.putExtra(AlarmClock.EXTRA_HOUR, start.get(Calendar.HOUR_OF_DAY));
						intent.putExtra(AlarmClock.EXTRA_MINUTES, start.get(Calendar.MINUTE));

						DayFragment.this.requestPermissions(new String[]{Manifest.permission.SET_ALARM}, ALARM_SET_REQUEST_CODE);
					}

				}).setPositiveButton(R.string.dialog_generic_button_positive, new DialogInterface.OnClickListener() {

					@Override
					public final void onClick(final DialogInterface dialog, final int which) {
						dialog.dismiss();
					}

				}).setNegativeButton(R.string.dialog_event_button_negative, new DialogInterface.OnClickListener() {

					@Override
					public final void onClick(final DialogInterface dialog, final int which) {
						colorPreferences.edit().remove(event.getName()).apply();
						dialog.dismiss();
						activity.showFragment(activity.currentMenuSelected);
					}

				});
				builder.create().show();
				if(activityPreferences.getBoolean(MainActivity.PREFERENCES_TIP_SHOW_CHANGECOLOR, true)) {
					Snacky.builder().setView(activity.findViewById(R.id.main_fab)).setText(R.string.main_snackbar_changecolor).info().show();
					activityPreferences.edit().putBoolean(MainActivity.PREFERENCES_TIP_SHOW_CHANGECOLOR, false).apply();
				}
			}

		});

		if(activityPreferences.getBoolean(MainActivity.PREFERENCES_TIP_SHOW_PINCHTOZOOM, true)) {
			Snacky.builder().setView(activity.findViewById(R.id.main_fab)).setText(R.string.main_snackbar_pinchtozoom).info().show();
			activityPreferences.edit().putBoolean(MainActivity.PREFERENCES_TIP_SHOW_PINCHTOZOOM, false).apply();
		}
		return view;
	}

	@Override
	public final void onAttach(final Context context) {
		super.onAttach(context);
	}

	@Override
	public final void onDetach() {
		super.onDetach();
	}

	@Override
	public final void onRequestPermissionsResult(final int requestCode, @NonNull final String permissions[], @NonNull final int[] grantResults) {
		switch(requestCode) {
		case ALARM_SET_REQUEST_CODE:
			if(grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
				final Intent activityIntent = DayFragment.this.getActivity().getIntent();

				final Intent alarmIntent = new Intent(AlarmClock.ACTION_SET_ALARM);
				alarmIntent.putExtra(AlarmClock.EXTRA_MESSAGE, activityIntent.getStringExtra(AlarmClock.EXTRA_MESSAGE));
				alarmIntent.putExtra(AlarmClock.EXTRA_HOUR, activityIntent.getIntExtra(AlarmClock.EXTRA_HOUR, 0));
				alarmIntent.putExtra(AlarmClock.EXTRA_MINUTES, activityIntent.getIntExtra(AlarmClock.EXTRA_MINUTES, 0));

				activityIntent.removeExtra(AlarmClock.EXTRA_MESSAGE);
				activityIntent.removeExtra(AlarmClock.EXTRA_HOUR);
				activityIntent.removeExtra(AlarmClock.EXTRA_MINUTES);

				this.startActivity(alarmIntent);
				break;
			}
			Toast.makeText(this.getActivity(), R.string.main_toast_nopermission, Toast.LENGTH_LONG).show();
			break;
		}
	}

	/**
	 * Creates a new instance of this fragment for the specified day.
	 *
	 * @param day The day.
	 *
	 * @return An instance of this fragment corresponding to the day.
	 */

	public static DayFragment newInstance(final Day day) {
		final DayFragment instance = new DayFragment();
		final Bundle args = new Bundle();
		args.putString(Day.class.getName().toLowerCase(), day.name());
		instance.setArguments(args);
		return instance;
	}

	public class TimetableWeekViewEvent extends WeekViewEvent {

		private final SharedPreferences activityPreferences;
		private final SharedPreferences colorPreferences;

		private TimetableWeekViewEvent(final Lesson lesson, final SharedPreferences activityPreferences, final SharedPreferences colorPreferences) {
			super(lesson.getId(), lesson.getSummary(), Utils.addZeroIfNeeded(lesson.getStart().get(Calendar.HOUR_OF_DAY)) + ":" + Utils.addZeroIfNeeded(lesson.getStart().get(Calendar.MINUTE)) + " - " + Utils.addZeroIfNeeded(lesson.getEnd().get(Calendar.HOUR_OF_DAY)) + ":" + Utils.addZeroIfNeeded(lesson.getEnd().get(Calendar.MINUTE)) + "\n\n" + lesson.getDescription(), lesson.getStart(), lesson.getEnd());
			this.activityPreferences = activityPreferences;
			this.colorPreferences = colorPreferences;
		}

		@Override
		public final int getColor() {
			final Activity activity = DayFragment.this.getActivity();
			final String name = this.getName();
			if(colorPreferences.contains(name)) {
				return colorPreferences.getInt(name, ContextCompat.getColor(activity, R.color.colorWeekViewEventDefault));
			}
			else if(activityPreferences.getBoolean(MainActivity.PREFERENCES_AUTOMATICALLY_COLOR_LESSONS, false)) {
				return Utils.randomColor(150, Utils.splitEqually(name, 3));
			}
			return ContextCompat.getColor(activity, R.color.colorWeekViewEventDefault);
		}

		@Override
		public final void setColor(final int color) {}

	}

}
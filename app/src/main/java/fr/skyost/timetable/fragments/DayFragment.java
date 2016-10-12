package fr.skyost.timetable.fragments;

import android.Manifest;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.RectF;
import android.os.Bundle;
import android.provider.AlarmClock;
import android.support.annotation.NonNull;
import android.support.v4.app.Fragment;
import android.support.v7.app.AlertDialog;
import android.text.format.DateFormat;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Toast;

import com.alamkanak.weekview.DateTimeInterpreter;
import com.alamkanak.weekview.MonthLoader;
import com.alamkanak.weekview.WeekView;
import com.alamkanak.weekview.WeekViewEvent;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.concurrent.TimeUnit;

import fr.skyost.timetable.R;
import fr.skyost.timetable.Timetable;
import fr.skyost.timetable.Timetable.Day;
import fr.skyost.timetable.Timetable.Lesson;
import fr.skyost.timetable.activities.MainActivity;
import fr.skyost.timetable.utils.Utils;

public class DayFragment extends Fragment {

	private static final int ALARM_SET_REQUEST_CODE = 100;

	private static final double DEFAULT_HOUR = 7d;

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

		final boolean withColors = DayFragment.this.getActivity().getSharedPreferences(MainActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE).getBoolean(MainActivity.PREFERENCES_ONE_COLOR_PER_COURSE, false);

		/* https://github.com/Quivr/Android-Week-View */
		final WeekView weekView = (WeekView)view.findViewById(R.id.main_day_weekview_day);
		weekView.setDateTimeInterpreter(new DateTimeInterpreter() {

			@Override
			public final String interpretDate(final Calendar calendar) {
				final Date date = calendar.getTime();
				return new SimpleDateFormat("E").format(date) + " " + DateFormat.getDateFormat(DayFragment.this.getActivity()).format(date);
			}

			@Override
			public final String interpretTime(final int hour, final int minutes) {
				return Utils.addZeroIfNeeded(hour) + ":" + Utils.addZeroIfNeeded(minutes);
			}

		});

		final Calendar calendar = Calendar.getInstance();
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
				final List<WeekViewEvent> events = new ArrayList<WeekViewEvent>();
				if(weekView.getFirstVisibleDay().get(Calendar.MONTH) + 1 != newMonth) {
					return events;
				}

				final Timetable timetable = ((MainActivity)DayFragment.this.getActivity()).getTimetable();
				if(timetable == null) {
					return events;
				}

				for(final Lesson lesson : timetable.getLessons()) {
					final Calendar start = lesson.getStart();
					if(start.get(Calendar.DAY_OF_MONTH) != calendar.get(Calendar.DAY_OF_MONTH)) {
						continue;
					}
					final String name = lesson.getName();
					final Calendar end = lesson.getEnd();
					final String description = Utils.addZeroIfNeeded(start.get(Calendar.HOUR_OF_DAY)) + ":" + Utils.addZeroIfNeeded(start.get(Calendar.MINUTE)) + " - " + Utils.addZeroIfNeeded(end.get(Calendar.HOUR_OF_DAY)) + ":" + Utils.addZeroIfNeeded(end.get(Calendar.MINUTE)) + "\n\n" + lesson.getDescription();

					final WeekViewEvent event = new WeekViewEvent(lesson.getId(), lesson.getName(), description, start, end);
					if(withColors) {
						event.setColor(Utils.randomColor(150, Utils.splitEqually(name, 3)));
					}

					events.add(event);
				}

				return events;
			}
		});
		weekView.setOnEventClickListener(new WeekView.EventClickListener() {

			@Override
			public final void onEventClick(final WeekViewEvent event, final RectF eventRect) {
				final AlertDialog.Builder builder = new AlertDialog.Builder(DayFragment.this.getActivity());
				final String name = event.getName();
				builder.setMessage(name + "\n" + event.getLocation());
				builder.setNeutralButton(R.string.dialog_event_button_neutral, new DialogInterface.OnClickListener() {

					@Override
					public final void onClick(final DialogInterface dialog, final int which) {
						final Calendar start = event.getStartTime();

						final Intent intent = DayFragment.this.getActivity().getIntent();
						intent.putExtra(AlarmClock.EXTRA_MESSAGE, name);
						intent.putExtra(AlarmClock.EXTRA_HOUR, start.get(Calendar.HOUR_OF_DAY));
						intent.putExtra(AlarmClock.EXTRA_MINUTES, start.get(Calendar.MINUTE));

						DayFragment.this.requestPermissions(new String[]{Manifest.permission.SET_ALARM}, ALARM_SET_REQUEST_CODE);
					}

				}).setPositiveButton(R.string.dialog_event_button_positive, new DialogInterface.OnClickListener() {

					@Override
					public final void onClick(final DialogInterface dialog, final int which) {
						dialog.dismiss();
					}

				});
				builder.create().show();
			}

		});
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

	public static final DayFragment newInstance(final Day day) {
		final DayFragment instance = new DayFragment();
		final Bundle args = new Bundle();
		args.putString(Day.class.getName().toLowerCase(), day.name());
		instance.setArguments(args);
		return instance;
	}

}
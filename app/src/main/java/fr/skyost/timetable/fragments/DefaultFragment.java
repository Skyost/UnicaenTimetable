package fr.skyost.timetable.fragments;

import android.app.Activity;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import fr.skyost.timetable.R;

import hotchemi.android.rate.AppRate;

public class DefaultFragment extends Fragment {

	@Override
	public final View onCreateView(final LayoutInflater inflater, final ViewGroup container, final Bundle savedInstanceState) {
		final Activity activity = this.getActivity();
		AppRate.with(activity).setInstallDays(3).showRateDialogIfMeetsConditions(activity);

		return inflater.inflate(R.layout.fragment_main_default, container, false);
	}

}
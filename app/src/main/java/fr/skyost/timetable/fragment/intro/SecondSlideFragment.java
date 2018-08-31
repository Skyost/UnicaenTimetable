package fr.skyost.timetable.fragment.intro;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import fr.skyost.timetable.R;
import fr.skyost.timetable.activity.IntroActivity;

/**
 * The second slide intro fragment.
 */

public class SecondSlideFragment extends IntroFragment {

	@Override
	public void onFragmentVisible(final IntroActivity activity) {
		activity.setNextPageSwipeLock(true);
		activity.showLoginDialog();
	}

	@Override
	public View onCreateView(final LayoutInflater inflater, final ViewGroup container, final Bundle savedInstanceState) {
		return inflater.inflate(R.layout.fragment_intro_slide_2, container, false);
	}

}
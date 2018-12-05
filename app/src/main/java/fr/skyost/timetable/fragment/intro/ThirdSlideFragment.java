package fr.skyost.timetable.fragment.intro;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import fr.skyost.timetable.R;
import fr.skyost.timetable.activity.IntroActivity;

/**
 * The third slide intro fragment.
 */

public class ThirdSlideFragment extends IntroFragment {

	@Override
	public void onFragmentVisible(final IntroActivity activity) {
		activity.setSwipeLock(true);
		activity.setProgressButtonEnabled(true);
	}

	@Override
	public View onCreateView(@NonNull final LayoutInflater inflater, final ViewGroup container, final Bundle savedInstanceState) {
		return inflater.inflate(R.layout.fragment_intro_slide_3, container, false);
	}

}
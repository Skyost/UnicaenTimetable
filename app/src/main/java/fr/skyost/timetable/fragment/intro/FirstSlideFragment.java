package fr.skyost.timetable.fragment.intro;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import fr.skyost.timetable.R;
import fr.skyost.timetable.activity.IntroActivity;

/**
 * The first slide intro fragment.
 */

public class FirstSlideFragment extends IntroFragment {

	@Override
	public void onFragmentVisible(final IntroActivity activity) {
		// If the activity has the goto intent parameter, we go to the specified slide.
		final int slide = activity.getIntent().getIntExtra(IntroActivity.INTENT_GOTO, IntroActivity.SLIDE_PRESENTATION);
		if(slide != IntroActivity.SLIDE_PRESENTATION) {
			activity.getPager().setCurrentItem(slide);
			activity.getIntent().removeExtra(IntroActivity.INTENT_GOTO);
		}
	}

	@Override
	public View onCreateView(final LayoutInflater inflater, final ViewGroup container, final Bundle savedInstanceState) {
		return inflater.inflate(R.layout.fragment_intro_slide_1, container, false);
	}

}
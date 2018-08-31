package fr.skyost.timetable.fragment.intro;

import android.support.v4.app.Fragment;

import fr.skyost.timetable.activity.IntroActivity;

/**
 * Represents an intro fragment.
 */

public abstract class IntroFragment extends Fragment {

	/**
	 * Called when the IntroActivity switches to the current fragment.
	 *
	 * @param activity The IntroActivity.
	 */

	public abstract void onFragmentVisible(final IntroActivity activity);

}
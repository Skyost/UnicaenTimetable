package fr.skyost.timetable.fragment.default_;

import android.content.Context;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.AdView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProviders;
import fr.skyost.timetable.R;
import fr.skyost.timetable.activity.MainActivity;
import fr.skyost.timetable.lesson.LessonModel;

/**
 * The default fragment.
 */

public class DefaultFragment extends Fragment {

	@Override
	public View onCreateView(@NonNull final LayoutInflater inflater, final ViewGroup container, final Bundle savedInstanceState) {
		// We get the required variables and we inflate the view.
		final View view = inflater.inflate(R.layout.fragment_main_default, container, false);
		final MainActivity activity = (MainActivity)getActivity();
		if(activity == null) {
			return view;
		}

		// And we toggle ads if needed.
		final AdView adView = view.findViewById(R.id.main_default_adview);
		if(activity.getSharedPreferences(MainActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE).getBoolean(MainActivity.PREFERENCES_ADS, true)) {
			adView.loadAd(new AdRequest.Builder().build());
		}
		else {
			adView.setVisibility(View.GONE);
		}

		return view;
	}

	@Override
	public void onViewCreated(@NonNull final View view, @Nullable final Bundle savedInstanceState) {
		super.onViewCreated(view, savedInstanceState);

		// We load the View.
		new DefaultFragmentLoader(this, view).execute(ViewModelProviders.of(this).get(LessonModel.class));
	}

}
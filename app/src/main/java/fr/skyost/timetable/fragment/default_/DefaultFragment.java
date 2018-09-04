package fr.skyost.timetable.fragment.default_;

import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import fr.skyost.timetable.R;
import fr.skyost.timetable.activity.MainActivity;

/**
 * The default fragment.
 */

public class DefaultFragment extends Fragment {

	@Override
	public View onCreateView(@NonNull final LayoutInflater inflater, final ViewGroup container, final Bundle savedInstanceState) {
		// We get the required variables.
		final View view = inflater.inflate(R.layout.fragment_main_default, container, false);

		final MainActivity activity = (MainActivity)this.getActivity();
		final TextView description = view.findViewById(R.id.main_default_textview_description);
		if(activity == null || description == null) {
			return view;
		}

		return view;
	}

	@Override
	public void onViewCreated(@NonNull final View view, @Nullable
	final Bundle savedInstanceState) {
		super.onViewCreated(view, savedInstanceState);

		// We load the View.
		new DefaultFragmentLoader(this, view).execute();
	}

}
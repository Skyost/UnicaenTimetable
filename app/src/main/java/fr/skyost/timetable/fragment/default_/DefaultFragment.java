package fr.skyost.timetable.fragment.default_;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import fr.skyost.timetable.R;

/**
 * The default fragment.
 */

public class DefaultFragment extends Fragment {

	@Override
	public View onCreateView(@NonNull final LayoutInflater inflater, final ViewGroup container, final Bundle savedInstanceState) {
		// We get the required variables.
		return inflater.inflate(R.layout.fragment_main_default, container, false);
	}

	@Override
	public void onViewCreated(@NonNull final View view, @Nullable final Bundle savedInstanceState) {
		super.onViewCreated(view, savedInstanceState);

		// We load the View.
		new DefaultFragmentLoader(this, view).execute();
	}

}
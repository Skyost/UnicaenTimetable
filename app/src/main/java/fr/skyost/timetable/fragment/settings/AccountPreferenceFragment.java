package fr.skyost.timetable.fragment.settings;

import android.accounts.Account;
import android.accounts.AccountManager;
import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.preference.Preference;
import android.preference.PreferenceFragment;
import android.view.MenuItem;

import fr.skyost.timetable.R;
import fr.skyost.timetable.activity.IntroActivity;
import fr.skyost.timetable.activity.settings.SettingsActivity;

/**
 * The account preference fragment.
 */

@TargetApi(Build.VERSION_CODES.HONEYCOMB)
public class AccountPreferenceFragment extends PreferenceFragment {

	@Override
	public void onCreate(final Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		// We set the required parameters.
		SettingsActivity.setDefaultPreferencesFile(this);
		addPreferencesFromResource(R.xml.preferences_account);
		setHasOptionsMenu(true);

		final Activity activity = getActivity();
		final Account[] accounts = AccountManager.get(activity).getAccountsByType(getString(R.string.account_type_authority));
		final Preference account = findPreference("account");
		if(accounts.length > 0) {
			account.setSummary(getString(R.string.settings_account, accounts[0].name));
		}

		// And we add a preference click listener (allows to switch account).
		account.setOnPreferenceClickListener(preference -> {
			final Intent intent = new Intent(activity, IntroActivity.class);
			intent.putExtra(IntroActivity.INTENT_GOTO, IntroActivity.SLIDE_ACCOUNT);
			intent.putExtra(IntroActivity.INTENT_ALLOW_BACKWARD, false);
			activity.startActivityForResult(intent, SettingsActivity.INTRO_ACTIVITY_RESULT);
			return true;
		});
	}

	@Override
	public boolean onOptionsItemSelected(final MenuItem item) {
		switch(item.getItemId()) {
		case android.R.id.home:
			// If the user click on the back button, we brought him back to the settings activity.
			startActivity(new Intent(getActivity(), SettingsActivity.class));
			return true;
		}
		return super.onOptionsItemSelected(item);
	}

}
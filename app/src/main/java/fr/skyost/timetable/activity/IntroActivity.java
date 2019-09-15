package fr.skyost.timetable.activity;

import android.Manifest;
import android.accounts.Account;
import android.accounts.AccountManager;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.View;
import android.widget.EditText;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;

import com.github.paolorotolo.appintro.AppIntro2;

import java.io.File;

import fr.skyost.timetable.R;
import fr.skyost.timetable.activity.settings.SettingsActivity;
import fr.skyost.timetable.fragment.intro.FirstSlideFragment;
import fr.skyost.timetable.fragment.intro.IntroFragment;
import fr.skyost.timetable.fragment.intro.SecondSlideFragment;
import fr.skyost.timetable.fragment.intro.ThirdSlideFragment;
import fr.skyost.timetable.sync.authentication.AuthenticationResponse;
import fr.skyost.timetable.sync.authentication.AuthenticationTask;
import fr.skyost.timetable.sync.authentication.AuthenticationTask.AuthenticationListener;
import fr.skyost.timetable.utils.Utils;

/**
 * The intro activity.
 */

public class IntroActivity extends AppIntro2 implements AuthenticationListener {

	/**
	 * The first slide.
	 */

	public static final int SLIDE_PRESENTATION = 0;

	/**
	 * The second slide.
	 */

	public static final int SLIDE_ACCOUNT = 1;

	/**
	 * The third slide.
	 */

	public static final int SLIDE_DONE = 2;

	/**
	 * The goto intent key.
	 */

	public static final String INTENT_GOTO = "goto";

	/**
	 * The allow backward intent key.
	 */

	public static final String INTENT_ALLOW_BACKWARD = "allow-backward";

	/**
	 * The account changed intent key.
	 */

	public static final String INTENT_ACCOUNT_CHANGED = "account-changed";

	/**
	 * The current progress dialog.
	 */

	private ProgressDialog dialog;

	/**
	 * Whether we should allow backward.
	 */

	private boolean allowBackward = true;

	/**
	 * Whether the current account has changed.
	 */

	private boolean accountChanged = false;

	@Override
	protected void onCreate(final Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		// Initializes AppIntro : slides, progress indicator, ...
		setProgressIndicator();
		setProgressButtonEnabled(false);
		setBackButtonVisibilityWithDone(false);
		showSkipButton(false);

		addSlide(new FirstSlideFragment());
		addSlide(new SecondSlideFragment());
		addSlide(new ThirdSlideFragment());

		// If we have a saved instance state, we can already load our parameters.
		if(savedInstanceState != null) {
			allowBackward = savedInstanceState.getBoolean(INTENT_ALLOW_BACKWARD, true);
			accountChanged = savedInstanceState.getBoolean(INTENT_ACCOUNT_CHANGED, false);
			return;
		}

		// Otherwise we load them from intent parameters.
		allowBackward = getIntent().getBooleanExtra(INTENT_ALLOW_BACKWARD, true);

		// We can let our users to upgrade to the new authentication system.
		final SharedPreferences authentication = getSharedPreferences(AuthenticationTask.PREFERENCES_FILE, Context.MODE_PRIVATE);
		if(authentication.contains(AuthenticationTask.PREFERENCES_USERNAME) || authentication.contains(AuthenticationTask.PREFERENCES_PASSWORD)) {
			// If we find old preferences, we can delete them.
			new AlertDialog.Builder(this)
					.setTitle(R.string.dialog_error_newauth_title)
					.setMessage(R.string.dialog_error_newauth_message)
					.setPositiveButton(R.string.dialog_generic_button_positive, (dialog, id) -> {
						authentication.edit().clear().apply();
						final File preferenceFile = new File(getFilesDir().getParent() + "/shared_prefs/" + AuthenticationTask.PREFERENCES_FILE + ".xml");
						if(preferenceFile.exists()) {
							preferenceFile.delete();
						}
					})
					.show();
		}
	}

	@Override
	public void onSaveInstanceState(final Bundle outState) {
		super.onSaveInstanceState(outState);
		outState.putBoolean(INTENT_ALLOW_BACKWARD, allowBackward);
		outState.putBoolean(INTENT_ACCOUNT_CHANGED, accountChanged);
	}

	@Override
	public void onBackPressed() {}

	@Override
	public void onDonePressed(final Fragment currentFragment) {
		// We have to set the result and then we can finish the activity.
		super.onDonePressed(currentFragment);

		final Intent intent = new Intent();
		intent.putExtra(INTENT_ACCOUNT_CHANGED, accountChanged);

		setResult(AppCompatActivity.RESULT_OK, intent);
		finish();
	}

	@Override
	public void onSlideChanged(final @Nullable Fragment oldFragment, final @Nullable Fragment newFragment) {
		super.onSlideChanged(oldFragment, newFragment);

		// We set the go back lock.
		setGoBackLock(!allowBackward);

		// And we trigger the event.
		final IntroFragment fragment = (IntroFragment)newFragment;
		if(fragment != null) {
			fragment.onFragmentVisible(this);
		}
	}

	@Override
	public void onAuthenticationTaskStarted() {
		// We create a progress dialog and we show it.
		dialog = new ProgressDialog(this);
		dialog.setMessage(getResources().getString(R.string.intro_dialog_wait));
		dialog.setCancelable(false);
		dialog.show();
	}

	@Override
	public void onAuthenticationResult(final AuthenticationResponse response) {
		// We try to dismiss the dialog.
		if(dialog != null && dialog.isShowing() && !this.isFinishing() && !this.isDestroyed()) {
			try {
				dialog.dismiss();
			}
			catch(final IllegalArgumentException ex) {}
			dialog = null;
		}

		// If an error has been returned, we print it.
		if(response.getException() != null) {
			response.getException().printStackTrace();
		}
		switch(response.getResult()) {
		case AuthenticationTask.SUCCESS:
			// If the authentication is a success, we can go to the next slide.
			setNextPageSwipeLock(true);
			getPager().setCurrentItem(SLIDE_DONE);

			final AccountManager manager = AccountManager.get(this);
			final Account[] accounts = manager.getAccountsByType(getString(R.string.account_type_authority));

			// If success, we add our account.
			final Runnable ifSuccess = () -> {
				final Account account = new Account(response.getUsername(), getString(R.string.account_type_authority));
				if(manager.addAccountExplicitly(account, Utils.base64Encode(this, response.getPassword()), null)) {
					Utils.makeAccountSyncable(this, account);
				}
				accountChanged = true;
			};

			// We delete existing accounts.
			if(accounts.length != 0) {
				Utils.removeAccount(manager, accounts[0], this, ifSuccess, () -> Toast.makeText(this, R.string.intro_toast_error_account, Toast.LENGTH_LONG).show());
				return;
			}
			ifSuccess.run();
			break;
		case AuthenticationTask.NOT_FOUND:
			// If we don't have the internet permission, we show a toast (it shouldn't happen).
			if(!Utils.hasPermission(this, Manifest.permission.INTERNET)) {
				Toast.makeText(this, R.string.intro_toast_error_permission, Toast.LENGTH_LONG).show();
				setNextPageSwipeLock(false);
				getPager().setCurrentItem(SLIDE_PRESENTATION);
				break;
			}

			// If we cannot find the calendar, we tell the user.
			new AlertDialog.Builder(this)
					.setTitle(R.string.dialog_error_notfound_title)
					.setMessage(R.string.dialog_error_notfound_message)
					.setCancelable(false)
					.setPositiveButton(R.string.dialog_generic_button_positive, (dialog, id) -> showLoginDialog())
					.show();
			break;
		case AuthenticationTask.UNAUTHORIZED:
			// If we don't have the internet permission, we show a toast (it shouldn't happen).
			if(!Utils.hasPermission(this, Manifest.permission.INTERNET)) {
				Toast.makeText(this, R.string.intro_toast_error_permission, Toast.LENGTH_LONG).show();
				setNextPageSwipeLock(false);
				getPager().setCurrentItem(SLIDE_PRESENTATION);
				break;
			}

			// Shows a new login dialog.
			showLoginDialog();
			Toast.makeText(this, R.string.intro_toast_error_credentials, Toast.LENGTH_LONG).show();
			break;
		case AuthenticationTask.ERROR:
			// Shows the error.
			Toast.makeText(this, R.string.intro_toast_error_network, Toast.LENGTH_LONG).show();
			setNextPageSwipeLock(false);
			getPager().setCurrentItem(SLIDE_PRESENTATION);
			break;
		}
	}

	/**
	 * Shows the login dialog.
	 */

	public void showLoginDialog() {
		final AlertDialog.Builder builder = new AlertDialog.Builder(this);
		final View layout = getLayoutInflater().inflate(R.layout.dialog_login_layout, null);
		builder.setView(layout);

		createDialog(builder, layout.findViewById(R.id.dialog_login_edittext_username), layout.findViewById(R.id.dialog_login_edittext_password), null, null, null);

		builder.setNeutralButton(R.string.dialog_login_button_more, (dialog, id) -> {
			dialog.dismiss();
			showAdvancedLoginDialog();
		});
		builder.create().show();
	}

	/**
	 * Shows the advanced login dialog.
	 */

	private void showAdvancedLoginDialog() {
		final AlertDialog.Builder builder = new AlertDialog.Builder(this);
		final View layout = getLayoutInflater().inflate(R.layout.dialog_advancedlogin_layout, null);
		builder.setView(layout);

		createDialog(builder, layout.findViewById(R.id.dialog_advancedlogin_edittext_username), layout.findViewById(R.id.dialog_advancedlogin_edittext_password), layout.findViewById(R.id.dialog_advancedlogin_edittext_server), layout.findViewById(R.id.dialog_advancedlogin_edittext_calendar), layout.findViewById(R.id.dialog_advancedlogin_edittext_parameters));

		builder.setNeutralButton(R.string.dialog_advancedlogin_button_less, (dialog, id) -> {
			dialog.dismiss();
			showLoginDialog();
		});
		builder.create().show();
	}

	/**
	 * Adds default views to the specified AlertDialog builder.
	 *
	 * @param builder The builder.
	 * @param usernameEditText The username edit text.
	 * @param passwordEditText The password edit text.
	 * @param serverEditText The server edit text.
	 * @param calendarEditText The calendar edit text.
	 * @param additionalParametersEditText The additional parameters edit text.
	 */

	private void createDialog(final AlertDialog.Builder builder, final EditText usernameEditText, final EditText passwordEditText, final EditText serverEditText, final EditText calendarEditText, final EditText additionalParametersEditText) {
		// We get the account.
		final Account[] accounts = AccountManager.get(this).getAccountsByType(getString(R.string.account_type_authority));
		final Account account = accounts.length > 0 ? accounts[0] : null;

		// We add the account credentials to the views.
		if(account != null) {
			usernameEditText.setText(account.name);
			passwordEditText.setText(Utils.base64Decode(this, account));
		}

		// And we add the preferences to the views.
		if(serverEditText != null && calendarEditText != null && additionalParametersEditText != null) {
			final SharedPreferences preferences = getSharedPreferences(SettingsActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE);
			serverEditText.setText(preferences.getString(SettingsActivity.PREFERENCES_SERVER, getString(R.string.settings_default_server)));
			calendarEditText.setText(preferences.getString(SettingsActivity.PREFERENCES_CALENDAR, getString(R.string.settings_default_calendarname)));
			additionalParametersEditText.setText(preferences.getString(SettingsActivity.PREFERENCES_ADDITIONAL_PARAMETERS, getString(R.string.settings_default_parameters)));
		}

		// We set the title.
		builder.setTitle(R.string.dialog_login_title);
		builder.setPositiveButton(R.string.dialog_login_button_positive, (dialog, id) -> {
			// If the user clicks on "Log in", well let's login him !
			dialog.dismiss();

			// If the user changed something to the views, we have to save those changes.
			if(serverEditText != null && calendarEditText != null && additionalParametersEditText != null) {
				final SharedPreferences.Editor editor = getSharedPreferences(SettingsActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE).edit();
				editor.putString(SettingsActivity.PREFERENCES_SERVER, serverEditText.getText().toString());
				editor.putString(SettingsActivity.PREFERENCES_CALENDAR, calendarEditText.getText().toString());
				editor.putString(SettingsActivity.PREFERENCES_ADDITIONAL_PARAMETERS, additionalParametersEditText.getText().toString());
				editor.commit(); // But we have to apply those changes immediately as our task will use them.
			}
			new AuthenticationTask(this, usernameEditText.getText().toString(), passwordEditText.getText().toString(), this).execute();
		}).setNegativeButton(R.string.dialog_generic_button_cancel, (dialog, id) -> {
			// If the user has dismissed the dialog, we have to either close the activity or go back (depends on the allowBackward field).
			if(!allowBackward) {
				setResult(AppCompatActivity.RESULT_CANCELED);
				finish();
				return;
			}
			setNextPageSwipeLock(true);
			getPager().setCurrentItem(SLIDE_PRESENTATION);
		});
		builder.setCancelable(false);
	}

}
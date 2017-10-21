package fr.skyost.timetable.activities;

import android.Manifest;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.ActivityCompat;
import android.support.v4.app.Fragment;
import android.view.View;
import android.widget.EditText;
import android.widget.Toast;

import com.github.paolorotolo.appintro.AppIntro2;

import fr.skyost.timetable.R;
import fr.skyost.timetable.fragments.FirstSlideFragment;
import fr.skyost.timetable.fragments.FourthSlideFragment;
import fr.skyost.timetable.fragments.SecondSlideFragment;
import fr.skyost.timetable.fragments.ThirdSlideFragment;
import fr.skyost.timetable.tasks.AuthenticationTask;
import fr.skyost.timetable.tasks.AuthenticationTask.AuthenticationListener;
import fr.skyost.timetable.utils.ObscuredSharedPreferences;
import fr.skyost.timetable.utils.Utils;

public class IntroActivity extends AppIntro2 implements AuthenticationListener {

	private static final int INTERNET_REQUEST_CODE = 100;

	public static final int SLIDE_PRESENTATION = 0;
	public static final int SLIDE_PERMISSION_INTERNET = 1;
	public static final int SLIDE_ACCOUNT = 2;
	public static final int SLIDE_DONE = 3;

	public static final String INTENT_GOTO = "goto";
	public static final String INTENT_ALLOW_BACKWARD = "allow-backward";
	public static final String INTENT_ACCOUNT_CHANGED = "account-changed";

	private ProgressDialog dialog;
	private boolean allowBackward = true;
	private boolean accountChanged = false;

	@Override
	protected final void onCreate(final Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		this.setProgressIndicator();

		this.addSlide(new FirstSlideFragment());
		this.addSlide(new SecondSlideFragment());
		this.addSlide(new ThirdSlideFragment());
		this.addSlide(new FourthSlideFragment());

		this.setProgressButtonEnabled(false);

		if(savedInstanceState != null) {
			allowBackward = savedInstanceState.getBoolean(INTENT_ALLOW_BACKWARD, true);
			accountChanged = savedInstanceState.getBoolean(INTENT_ACCOUNT_CHANGED, false);
			return;
		}

		final Intent intent = this.getIntent();
		if(intent == null) {
			return;
		}
		allowBackward = intent.getBooleanExtra(INTENT_ALLOW_BACKWARD, true);
	}

	@Override
	public final void onSaveInstanceState(final Bundle outState) {
		super.onSaveInstanceState(outState);
		outState.putBoolean(INTENT_ALLOW_BACKWARD, allowBackward);
		outState.putBoolean(INTENT_ACCOUNT_CHANGED, accountChanged);
	}

	@Override
	public final void onBackPressed() {}

	@Override
	public final void onDonePressed(final Fragment currentFragment) {
		final SharedPreferences preferences = this.getSharedPreferences(MainActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE);
		preferences.edit().putBoolean(MainActivity.PREFERENCES_SHOW_INTRO, false).apply();

		final Intent intent = new Intent();
		intent.putExtra(INTENT_ACCOUNT_CHANGED, accountChanged);

		this.setResult(Activity.RESULT_OK, intent);
		this.finish();

		super.onDonePressed(currentFragment);
	}

	@Override
	public final void onSlideChanged(final @Nullable Fragment oldFragment, final @Nullable Fragment newFragment) {
		super.onSlideChanged(oldFragment, newFragment);

		this.setGoBackLock(!allowBackward);
		if(newFragment instanceof FirstSlideFragment) {
			final Intent intent = this.getIntent();
			if(intent == null) {
				return;
			}
			final int slide = intent.getIntExtra(INTENT_GOTO, SLIDE_PRESENTATION);
			if(slide != SLIDE_PRESENTATION) {
				this.getPager().setCurrentItem(slide);
			}
		}
		else if(newFragment instanceof SecondSlideFragment) {
			this.setNextPageSwipeLock(true);
			ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.INTERNET}, INTERNET_REQUEST_CODE);
		}
		else if(newFragment instanceof ThirdSlideFragment) {
			this.setNextPageSwipeLock(true);
			showLoginDialog();
		}
		else if(newFragment instanceof FourthSlideFragment) {
			this.setSwipeLock(true);
			this.setProgressButtonEnabled(true);
		}
	}

	@Override
	public final void onRequestPermissionsResult(final int requestCode, @NonNull final String permissions[], @NonNull final int[] grantResults) {
		switch(requestCode) {
		case INTERNET_REQUEST_CODE:
			if(grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
				this.getPager().setCurrentItem(SLIDE_ACCOUNT);
				break;
			}
			this.setNextPageSwipeLock(false);
			this.getPager().setCurrentItem(SLIDE_PRESENTATION);
			break;
		}
	}

	@Override
	public final void onAuthenticationTaskStarted() {
		dialog = new ProgressDialog(this);
		dialog.setMessage(this.getResources().getString(R.string.intro_dialog_wait));
		dialog.setCancelable(false);
		dialog.show();
	}

	@Override
	public final void onAuthenticationResult(final int result, final Exception exception) {
		if(dialog != null && dialog.isShowing()) {
			dialog.dismiss();
			dialog = null;
		}
		if(exception != null) {
			exception.printStackTrace();
		}
		switch(result) {
		case AuthenticationTask.SUCCESS:
			this.setNextPageSwipeLock(true);
			this.getPager().setCurrentItem(SLIDE_DONE);
			break;
		case AuthenticationTask.NOT_FOUND:
			if(!Utils.hasPermission(this, Manifest.permission.INTERNET)) {
				Toast.makeText(this, R.string.intro_toast_error_permission, Toast.LENGTH_LONG).show();
				this.setNextPageSwipeLock(false);
				this.getPager().setCurrentItem(SLIDE_PRESENTATION);
				break;
			}
			final AlertDialog.Builder builder = new AlertDialog.Builder(this);
			builder.setTitle(R.string.dialog_error_notfound_title);
			builder.setMessage(R.string.dialog_error_notfound_message_1);
			builder.setCancelable(false);
			builder.setPositiveButton(R.string.dialog_generic_button_positive, new DialogInterface.OnClickListener() {

				@Override
				public final void onClick(final DialogInterface dialog, final int id) {
					showLoginDialog();
				}

			});
			builder.create().show();
			break;
		case AuthenticationTask.UNAUTHORIZED:
			if(!Utils.hasPermission(this, Manifest.permission.INTERNET)) {
				Toast.makeText(this, R.string.intro_toast_error_permission, Toast.LENGTH_LONG).show();
				this.setNextPageSwipeLock(false);
				this.getPager().setCurrentItem(SLIDE_PRESENTATION);
				break;
			}
			showLoginDialog();
			Toast.makeText(this, R.string.intro_toast_error_credentials, Toast.LENGTH_LONG).show();
			break;
		case AuthenticationTask.ERROR:
			exception.printStackTrace();
			Toast.makeText(this, R.string.intro_toast_error_network, Toast.LENGTH_LONG).show();
			this.setNextPageSwipeLock(false);
			this.getPager().setCurrentItem(SLIDE_PRESENTATION);
			break;
		}
	}

	/**
	 * Shows the login dialog.
	 */

	private final void showLoginDialog() {
		final AlertDialog.Builder builder = new AlertDialog.Builder(this);
		final View layout = this.getLayoutInflater().inflate(R.layout.dialog_login_layout, null);
		builder.setView(layout);

		createDialog(builder, (EditText)layout.findViewById(R.id.dialog_login_edittext_username), (EditText)layout.findViewById(R.id.dialog_login_edittext_password), null, null);

		builder.setNeutralButton(R.string.dialog_login_button_more, new DialogInterface.OnClickListener() {

			@Override
			public final void onClick(final DialogInterface dialog, final int id) {
				dialog.dismiss();
				showAdvancedLoginDialog();
			}

		});
		builder.create().show();
	}

	/**
	 * Shows the advanced login dialog.
	 */

	private final void showAdvancedLoginDialog() {
		final AlertDialog.Builder builder = new AlertDialog.Builder(this);
		final View layout = this.getLayoutInflater().inflate(R.layout.dialog_advancedlogin_layout, null);
		builder.setView(layout);

		createDialog(builder, (EditText)layout.findViewById(R.id.dialog_advancedlogin_edittext_username), (EditText)layout.findViewById(R.id.dialog_advancedlogin_edittext_password), (EditText)layout.findViewById(R.id.dialog_advancedlogin_edittext_server), (EditText)layout.findViewById(R.id.dialog_advancedlogin_edittext_calendar));

		builder.setNeutralButton(R.string.dialog_advancedlogin_button_less, new DialogInterface.OnClickListener() {

			@Override
			public final void onClick(final DialogInterface dialog, final int id) {
				dialog.dismiss();
				showLoginDialog();
			}

		});
		builder.create().show();
	}

	/**
	 * Creates a default dialog.
	 *
	 * @param builder The builder.
	 * @param usernameEditText The username edit text.
	 * @param passwordEditText The password edit text.
	 * @param serverEditText The server edit text.
	 * @param calendarEditText The calendar edit text.
	 */

	private final void createDialog(final AlertDialog.Builder builder, final EditText usernameEditText, final EditText passwordEditText, final EditText serverEditText, final EditText calendarEditText) {
		final SharedPreferences obscuredPreferences = new ObscuredSharedPreferences(this, this.getSharedPreferences(AuthenticationTask.PREFERENCES_FILE, Context.MODE_PRIVATE));

		final String usernamePreferences = obscuredPreferences.getString(AuthenticationTask.PREFERENCES_USERNAME, "");
		final String passwordPreferences = obscuredPreferences.getString(AuthenticationTask.PREFERENCES_PASSWORD, "");

		usernameEditText.setText(usernamePreferences);
		passwordEditText.setText(passwordPreferences);

		if(serverEditText != null && calendarEditText != null) {
			final SharedPreferences preferences = this.getSharedPreferences(MainActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE);
			serverEditText.setText(preferences.getString(MainActivity.PREFERENCES_SERVER, this.getString(R.string.settings_default_server)));
			calendarEditText.setText(preferences.getString(MainActivity.PREFERENCES_CALENDAR, this.getString(R.string.settings_default_calendarname)));
		}

		builder.setTitle(R.string.dialog_login_title);
		builder.setPositiveButton(R.string.dialog_login_button_positive, new DialogInterface.OnClickListener() {

			@Override
			public final void onClick(final DialogInterface dialog, final int id) {
				dialog.dismiss();
				final String username = usernameEditText.getText().toString();
				final String password = passwordEditText.getText().toString();

				if(!username.equals(usernamePreferences) || !password.equals(passwordPreferences)) {
					accountChanged = true;
				}

				final SharedPreferences.Editor obscuredEditor = obscuredPreferences.edit();
				obscuredEditor.putString(AuthenticationTask.PREFERENCES_USERNAME, username);
				obscuredEditor.putString(AuthenticationTask.PREFERENCES_PASSWORD, password);
				obscuredEditor.commit();

				if(serverEditText != null && calendarEditText != null) {
					final SharedPreferences.Editor editor = IntroActivity.this.getSharedPreferences(MainActivity.PREFERENCES_TITLE, Context.MODE_PRIVATE).edit();
					editor.putString(MainActivity.PREFERENCES_SERVER, serverEditText.getText().toString());
					editor.putString(MainActivity.PREFERENCES_CALENDAR, calendarEditText.getText().toString());
					editor.commit();
				}
				new AuthenticationTask(IntroActivity.this, IntroActivity.this).execute();
			}

		}).setNegativeButton(R.string.dialog_generic_button_cancel, new DialogInterface.OnClickListener() {

			@Override
			public final void onClick(final DialogInterface dialog, final int id) {
				dialog.dismiss();
				if(!allowBackward) {
					IntroActivity.this.setResult(Activity.RESULT_CANCELED);
					IntroActivity.this.finish();
					return;
				}
				IntroActivity.this.setNextPageSwipeLock(true);
				IntroActivity.this.getPager().setCurrentItem(SLIDE_PRESENTATION);
			}

		});
		builder.setOnCancelListener(new DialogInterface.OnCancelListener() {

			@Override
			public final void onCancel(final DialogInterface dialog) {
				dialog.dismiss();
				if(!allowBackward) {
					IntroActivity.this.setResult(Activity.RESULT_CANCELED);
					IntroActivity.this.finish();
					return;
				}
				IntroActivity.this.setNextPageSwipeLock(true);
				IntroActivity.this.getPager().setCurrentItem(SLIDE_PRESENTATION);
			}

		});
		builder.setCancelable(false);
	}

}
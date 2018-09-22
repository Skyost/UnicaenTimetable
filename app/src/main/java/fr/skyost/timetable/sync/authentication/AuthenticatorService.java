package fr.skyost.timetable.sync.authentication;

import android.accounts.AbstractAccountAuthenticator;
import android.accounts.Account;
import android.accounts.AccountAuthenticatorResponse;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.IBinder;

/**
 * The authenticator service.
 */

public class AuthenticatorService extends Service {

	/**
	 * The authenticator instance.
	 */

	private Authenticator authenticator;

	@Override
	public void onCreate() {
		authenticator = new Authenticator(this);
	}

	@Override
	public IBinder onBind(final Intent intent) {
		return authenticator.getIBinder();
	}

	/**
	 * Returns the authenticator instance.
	 *
	 * @return The authenticator instance.
	 */

	public Authenticator getAuthenticator() {
		return authenticator;
	}

	/**
	 * Sets the authenticator.
	 *
	 * @param authenticator The authenticator.
	 */

	public void setAuthenticator(final Authenticator authenticator) {
		this.authenticator = authenticator;
	}

	/**
	 * The authenticator.
	 */

	public class Authenticator extends AbstractAccountAuthenticator {

		/**
		 * Creates a new Authenticator instance.
		 *
		 * @param context The context.
		 */

		private Authenticator(final Context context) {
			super(context);
		}

		@Override
		public Bundle editProperties(final AccountAuthenticatorResponse response, final String string) {
			throw new UnsupportedOperationException();
		}

		@Override
		public Bundle addAccount(final AccountAuthenticatorResponse r, final String string, final String string2, final String[] strings, final Bundle bundle) {
			return null;
		}

		@Override
		public Bundle confirmCredentials(final AccountAuthenticatorResponse response, final Account account, final Bundle bundle) {
			return null;
		}

		@Override
		public Bundle getAuthToken(final AccountAuthenticatorResponse response, final Account account, final String string, final Bundle bundle) {
			throw new UnsupportedOperationException();
		}

		@Override
		public String getAuthTokenLabel(final String string) {
			throw new UnsupportedOperationException();
		}

		@Override
		public Bundle updateCredentials(final AccountAuthenticatorResponse response, final Account account, final String string, final Bundle bundle) {
			throw new UnsupportedOperationException();
		}

		@Override
		public Bundle hasFeatures(final AccountAuthenticatorResponse response, final Account account, final String[] strings) {
			throw new UnsupportedOperationException();
		}

	}

}
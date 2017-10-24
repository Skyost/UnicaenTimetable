package fr.skyost.timetable.services;

import android.accounts.AbstractAccountAuthenticator;
import android.accounts.Account;
import android.accounts.AccountAuthenticatorResponse;
import android.accounts.NetworkErrorException;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.IBinder;

public class AuthenticatorService extends Service {

	private Authenticator authenticator;

	@Override
	public final void onCreate() {
		authenticator = new Authenticator(this);
	}

	@Override
	public final IBinder onBind(final Intent intent) {
		return authenticator.getIBinder();
	}

	public class Authenticator extends AbstractAccountAuthenticator {

		public Authenticator(final Context context) {
			super(context);
		}

		@Override
		public final Bundle editProperties(final AccountAuthenticatorResponse response, final String string) {
			throw new UnsupportedOperationException();
		}

		@Override
		public final Bundle addAccount(final AccountAuthenticatorResponse r, final String string, final String string2, final String[] strings, final Bundle bundle) throws NetworkErrorException {
			return null;
		}

		@Override
		public final Bundle confirmCredentials(final AccountAuthenticatorResponse response, final Account account, final Bundle bundle) throws NetworkErrorException {
			return null;
		}

		@Override
		public final Bundle getAuthToken(final AccountAuthenticatorResponse response, final Account account, final String string, final Bundle bundle) throws NetworkErrorException {
			throw new UnsupportedOperationException();
		}

		@Override
		public final String getAuthTokenLabel(final String string) {
			throw new UnsupportedOperationException();
		}

		@Override
		public final Bundle updateCredentials(final AccountAuthenticatorResponse response, final Account account, final String string, final Bundle bundle) throws NetworkErrorException {
			throw new UnsupportedOperationException();
		}

		@Override
		public final Bundle hasFeatures(final AccountAuthenticatorResponse response, final Account account, final String[] strings) throws NetworkErrorException {
			throw new UnsupportedOperationException();
		}

	}

}
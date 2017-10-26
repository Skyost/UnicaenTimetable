package fr.skyost.timetable.utils;

import android.accounts.Account;
import android.accounts.AccountManager;
import android.app.Activity;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.os.Build;
import android.provider.Settings;
import android.support.v4.content.ContextCompat;
import android.util.Base64;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;
import javax.crypto.spec.PBEParameterSpec;

public class Utils {

	public static final String UTF_8 = "UTF-8";

	/**
	 * Adds a leading zero to an int if needed.
	 *
	 * @param integer The Integer.
	 *
	 * @return A String corresponding to the operation.
	 */

	public static final String addZeroIfNeeded(final Integer integer) {
		final String value = String.valueOf(integer);
		if(value.length() < 2) {
			return "0" + value;
		}
		return value;
	}

	/**
	 * Checks if the application has a specified permission.
	 *
	 * @param activity The Activity.
	 * @param permission The permission (can be obtained with Manifest.permission.(...)).
	 *
	 * @return <b>true</b> If it has the permission.
	 * <br><b>false</b> Otherwise.
	 */

	public static final boolean hasPermission(final Activity activity, final String permission) {
		return ContextCompat.checkSelfPermission(activity, permission) == PackageManager.PERMISSION_GRANTED;
	}

	/**
	 * Split a String in separate parts.
	 *
	 * @param text The text.
	 * @param size The parts number.
	 *
	 * @return An array which contains the String.
	 */

	public static final String[] splitEqually(final String text, int size) {
		final List<String> result = new ArrayList<String>();
		int start = 0;
		int end = text.length() / size;
		for(int i = 0; i != size; i++) {
			final StringBuilder builder = new StringBuilder();
			int j;
			for(j = start; j != end; j++) {
				if(j >= text.length()) {
					break;
				}
				builder.append(String.valueOf(text.charAt(j)));
			}
			result.add(builder.toString());
			start = j;
			end += end;
		}
		return result.toArray(new String[result.size()]);
	}

	/**
	 * Creates a random color with seeds.
	 *
	 * @param alpha The opacity.
	 * @param seeds The seeds.
	 *
	 * @return The random color.
	 */

	public static final int randomColor(final int alpha, final String... seeds) {
		if(seeds.length < 3) {
			return Color.WHITE;
		}
		return Color.argb(alpha, new Random(seeds[0].hashCode()).nextInt(256), new Random(seeds[1].hashCode()).nextInt(256), new Random(seeds[2].hashCode()).nextInt(256));
	}

	/**
	 * Removes an account.
	 *
	 * @param manager The accounts manager.
	 * @param account The account.
	 */

	public static final void removeAccount(final AccountManager manager, final Account account) {
		if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.M){
			manager.removeAccountExplicitly(account);
		}
		else {
			manager.removeAccount(account, null, null);
		}
	}

	public static final String a(final Activity activity, final Account account) {
		final String value = AccountManager.get(activity).getPassword(account);
		try {
			final byte[] bytes = value == null ? new byte[0] : Base64.decode(value,Base64.DEFAULT);
			final SecretKeyFactory keyFactory = SecretKeyFactory.getInstance("PBEWithMD5AndDES");
			final SecretKey key = keyFactory.generateSecret(new PBEKeySpec(Settings.Secure.ANDROID_ID.toCharArray()));
			final Cipher pbeCipher = Cipher.getInstance("PBEWithMD5AndDES");
			pbeCipher.init(Cipher.DECRYPT_MODE, key, new PBEParameterSpec(Settings.Secure.getString(activity.getContentResolver(),Settings.Secure.ANDROID_ID).getBytes(Utils.UTF_8), 20));
			return new String(pbeCipher.doFinal(bytes), Utils.UTF_8);
		}
		catch(final Exception ex) {
			ex.printStackTrace();
		}
		return value;
	}

	public static final String b(final Activity activity, final String value) {
		try {
			final byte[] bytes = value == null ? new byte[0] : value.getBytes(UTF_8);
			final SecretKeyFactory keyFactory = SecretKeyFactory.getInstance("PBEWithMD5AndDES");
			final SecretKey key = keyFactory.generateSecret(new PBEKeySpec(Settings.Secure.ANDROID_ID.toCharArray()));
			final Cipher pbeCipher = Cipher.getInstance("PBEWithMD5AndDES");
			pbeCipher.init(Cipher.ENCRYPT_MODE, key, new PBEParameterSpec(Settings.Secure.getString(activity.getContentResolver(), Settings.Secure.ANDROID_ID).getBytes(Utils.UTF_8), 20));
			return new String(Base64.encode(pbeCipher.doFinal(bytes), Base64.NO_WRAP), Utils.UTF_8);
		}
		catch(final Exception ex) {
			ex.printStackTrace();
		}
		return value;
	}

}

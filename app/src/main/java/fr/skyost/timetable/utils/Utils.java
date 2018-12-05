package fr.skyost.timetable.utils;

import android.accounts.Account;
import android.accounts.AccountManager;
import android.content.ContentResolver;
import android.content.Context;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.os.Bundle;
import android.provider.Settings;
import android.util.Base64;

import com.google.android.material.snackbar.Snackbar;

import org.joda.time.DateTime;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;
import java.util.concurrent.TimeUnit;

import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;
import javax.crypto.spec.PBEParameterSpec;

import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.content.res.AppCompatResources;
import androidx.core.content.ContextCompat;
import fr.skyost.timetable.R;

/**
 * Some utilities methods.
 */

public class Utils {

	/**
	 * UTF-8 charset.
	 */

	private static final String UTF_8 = "UTF-8";

	/**
	 * Adds a leading zero to an int if needed.
	 *
	 * @param integer The Integer.
	 *
	 * @return A String corresponding to the operation.
	 */

	public static String addZeroIfNeeded(final Integer integer) {
		final String value = String.valueOf(integer);
		if(value.length() < 2) {
			return "0" + value;
		}
		return value;
	}

	/**
	 * Checks if the application has a specified permission.
	 *
	 * @param context The Context.
	 * @param permission The permission (can be obtained with Manifest.permission.(...)).
	 *
	 * @return <b>true</b> If it has the permission.
	 * <br><b>false</b> Otherwise.
	 */

	public static boolean hasPermission(final Context context, final String permission) {
		return ContextCompat.checkSelfPermission(context, permission) == PackageManager.PERMISSION_GRANTED;
	}

	/**
	 * Splits a String in separate parts.
	 *
	 * @param text The text.
	 * @param size The parts number.
	 *
	 * @return An array which contains the String.
	 */

	public static String[] splitEqually(final String text, int size) {
		final List<String> result = new ArrayList<>();
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

	public static int randomColor(final int alpha, final String... seeds) {
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
	 * @param activity The activity.
	 * @param ifSuccess Runnable to run when the account was removed with success.
	 * @param ifError Runnable to run when the account was not removed.
	 */

	public static void removeAccount(final AccountManager manager, final Account account, final AppCompatActivity activity, final Runnable ifSuccess, final Runnable ifError) {
		if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.M){
			manager.removeAccount(account, activity, accountManagerFuture -> {
				try {
					if(accountManagerFuture.getResult().getBoolean(AccountManager.KEY_BOOLEAN_RESULT, false)) {
						ifSuccess.run();
						return;
					}
				}
				catch(final Exception ex) {
					ex.printStackTrace();
				}
				ifError.run();
			}, null);
			return;
		}

		manager.removeAccount(account, accountManagerFuture -> {
			try {
				if(accountManagerFuture.getResult()) {
					ifSuccess.run();
					return;
				}
			}
			catch(final Exception ex) {
				ex.printStackTrace();
			}
			ifError.run();
		}, null);
	}

	/**
	 * Makes an account syncable.
	 *
	 * @param context A context.
	 * @param account The account.
	 */

	public static void makeAccountSyncable(final Context context, final Account account) {
		final String authority = context.getString(R.string.account_type_authority);

		ContentResolver.setIsSyncable(account, authority, 1);
		ContentResolver.setSyncAutomatically(account, authority, true);
		ContentResolver.addPeriodicSync(account, authority, Bundle.EMPTY, TimeUnit.DAYS.toSeconds(3L));
	}

	/**
	 * Decodes a password.
	 *
	 * @param context The context.
	 * @param account The account.
	 *
	 * @return The decoded password.
	 */

	public static String base64Decode(final Context context, final Account account) {
		final String value = AccountManager.get(context).getPassword(account);
		try {
			final byte[] bytes = value == null ? new byte[0] : Base64.decode(value,Base64.DEFAULT);
			final SecretKeyFactory keyFactory = SecretKeyFactory.getInstance("PBEWithMD5AndDES");
			final SecretKey key = keyFactory.generateSecret(new PBEKeySpec(Settings.Secure.ANDROID_ID.toCharArray()));
			final Cipher pbeCipher = Cipher.getInstance("PBEWithMD5AndDES");
			pbeCipher.init(Cipher.DECRYPT_MODE, key, new PBEParameterSpec(Settings.Secure.getString(context.getContentResolver(),Settings.Secure.ANDROID_ID).getBytes(Utils.UTF_8), 20));
			return new String(pbeCipher.doFinal(bytes), Utils.UTF_8);
		}
		catch(final Exception ex) {
			ex.printStackTrace();
		}
		return value;
	}

	/**
	 * Encodes a String.
	 *
	 * @param context The context.
	 * @param value The String.
	 *
	 * @return The encoded String.
	 */

	public static String base64Encode(final Context context, final String value) {
		try {
			final byte[] bytes = value == null ? new byte[0] : value.getBytes(UTF_8);
			final SecretKeyFactory keyFactory = SecretKeyFactory.getInstance("PBEWithMD5AndDES");
			final SecretKey key = keyFactory.generateSecret(new PBEKeySpec(Settings.Secure.ANDROID_ID.toCharArray()));
			final Cipher pbeCipher = Cipher.getInstance("PBEWithMD5AndDES");
			pbeCipher.init(Cipher.ENCRYPT_MODE, key, new PBEParameterSpec(Settings.Secure.getString(context.getContentResolver(), Settings.Secure.ANDROID_ID).getBytes(Utils.UTF_8), 20));
			return new String(Base64.encode(pbeCipher.doFinal(bytes), Base64.NO_WRAP), Utils.UTF_8);
		}
		catch(final Exception ex) {
			ex.printStackTrace();
		}
		return value;
	}

	/**
	 * Creates a Bitmap from a Drawable.
	 *
	 * @param context The context.
	 * @param drawableId ID of the Drawable.
	 *
	 * @return The Bitmap.
	 */

	public static Bitmap drawableToBitmap(final Context context, final int drawableId) {
		final Drawable drawable = AppCompatResources.getDrawable(context, drawableId);
		if(drawable == null) {
			return null;
		}

		final Bitmap bitmap = Bitmap.createBitmap(drawable.getIntrinsicWidth(), drawable.getIntrinsicHeight(), Bitmap.Config.ARGB_8888);
		Canvas canvas = new Canvas(bitmap);
		drawable.setBounds(0, 0, canvas.getWidth(), canvas.getHeight());
		drawable.draw(canvas);
		return bitmap;
	}

	/**
	 * Returns tomorrow midnight (and 1 second) calendar.
	 *
	 * @return Tomorrow midnight calendar.
	 */

	public static DateTime tomorrowMidnight() {
		return DateTime.now().plusDays(1).withTimeAtStartOfDay();
	}

	/**
	 * Sets the specified callback to the specified SnackBar.
	 *
	 * @param snackbar The SnackBar.
	 * @param callback The callback.
	 */

	@SuppressWarnings("deprecation")
	public static void setSnackBarCallback(final Snackbar snackbar, final Snackbar.Callback callback) {
		if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.N_MR1) {
			snackbar.addCallback(callback);
		}
		else {
			snackbar.setCallback(callback);
		}
	}

}

package fr.skyost.timetable.utils;

import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.os.Build;
import android.support.v4.content.ContextCompat;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Random;

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
	 * Safely casts a long to an int.
	 *
	 * @param l The long.
	 *
	 * @return The checked cast.
	 */

	public static final int safeLongToInt(final long l) {
		if(l < Integer.MIN_VALUE || l > Integer.MAX_VALUE) {
			throw new IllegalArgumentException (l + " cannot be cast to int without changing its value.");
		}
		return (int)l;
	}

	/**
	 * Gets the system's locale.
	 *
	 * @param context Context of the application.
	 *
	 * @return The locale.
	 */

	public static final Locale getCurrentLocale(final Context context){
		if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.N){
			return context.getResources().getConfiguration().getLocales().get(0);
		}
		else {
			return context.getResources().getConfiguration().locale;
		}
	}

}

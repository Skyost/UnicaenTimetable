package fr.skyost.timetable.lesson.database;

import android.Manifest;
import android.accounts.Account;
import android.accounts.AccountManager;
import android.arch.lifecycle.LiveData;
import android.arch.persistence.room.Dao;
import android.arch.persistence.room.Insert;
import android.arch.persistence.room.OnConflictStrategy;
import android.arch.persistence.room.Query;
import android.content.Context;

import org.joda.time.DateTime;
import org.joda.time.LocalDate;

import java.net.HttpURLConnection;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.List;

import biweekly.Biweekly;
import biweekly.ICalendar;
import biweekly.component.VEvent;
import fr.skyost.timetable.R;
import fr.skyost.timetable.lesson.Lesson;
import fr.skyost.timetable.sync.authentication.AuthenticationTask;
import fr.skyost.timetable.utils.Utils;
import okhttp3.ResponseBody;

/**
 * The lesson data access object.
 */

@Dao
public abstract class LessonDao {

	/**
	 * The preference file.
	 */

	public static final String PREFERENCE_FILE = "dao";

	/**
	 * The last modification preference key.
	 */

	public static final String PREFERENCE_LAST_MODIFICATION = "last-modification";

	/**
	 * Refreshes the database from the remote calendar.
	 *
	 * @param context The context.
	 *
	 * @return The result (see AuthenticationTask for more information).
	 */

	public int refreshFromNetwork(final Context context) {
		try {
			final Account[] accounts = AccountManager.get(context).getAccountsByType(context.getString(R.string.account_type_authority));
			if(accounts.length == 0) {
				// If there is no account we return the corresponding value.
				return AuthenticationTask.NO_ACCOUNT;
			}

			if(!Utils.hasPermission(context, Manifest.permission.INTERNET)) {
				// Same for the internet permission (should not happen).
				return AuthenticationTask.UNAUTHORIZED;
			}

			// We update the last modification preference.
			context.getSharedPreferences(PREFERENCE_FILE, Context.MODE_PRIVATE).edit().putLong(PREFERENCE_LAST_MODIFICATION, DateTime.now().getMillis()).apply();

			final Account account = accounts[0];
			final okhttp3.Response response = AuthenticationTask.buildClient().newCall(AuthenticationTask.buildRequest(context, account.name, Utils.base64Decode(context, account))).execute();
			final int code = response.code();
			if(code == HttpURLConnection.HTTP_NOT_FOUND) {
				// Same for the not found error (happen very often, unfortunately).
				return AuthenticationTask.NOT_FOUND;
			}
			if(code == HttpURLConnection.HTTP_UNAUTHORIZED) {
				// And same for 403 errors.
				return AuthenticationTask.UNAUTHORIZED;
			}

			final ResponseBody body = response.body();
			if(body == null) {
				throw new NullPointerException();
			}

			// Once everything is okay, we parse the result.
			final ICalendar calendar = Biweekly.parse(body.byteStream()).first();
			final HashSet<Lesson> lessons = new HashSet<>();
			for(final VEvent event : calendar.getEvents()) {
				lessons.add(new Lesson(event));
			}

			// We clear the existing lessons and we insert the new lessons.
			clearLessons();
			insertLessons(lessons);
			return AuthenticationTask.SUCCESS;
		}
		catch(final Exception ex) {
			ex.printStackTrace();
			return AuthenticationTask.ERROR;
		}
	}

	/**
	 * Returns the remaining lessons of the day.
	 *
	 * @return The remaining lessons of the day.
	 */

	public List<Lesson> getRemainingLessons() {
		// We get the today's lessons.
		final DateTime now = DateTime.now();
		final List<Lesson> result = getLessons(DateTime.now().withTimeAtStartOfDay(), DateTime.now().plusDays(1).withTimeAtStartOfDay());
		for(final Lesson lesson : new ArrayList<>(result)) {
			// If we are past the lesson, we remove it from the list.
			if(!now.isAfter(lesson.getEndDate())) {
				continue;
			}
			result.remove(lesson);
		}

		return result;
	}

	/**
	 * Returns the lessons LiveData.
	 *
	 * @return The lessons LiveData.
	 */

	@Query("SELECT * FROM " + Lesson.TABLE_NAME)
	public abstract LiveData<List<Lesson>> getLessonsLiveData();

	/**
	 * Returns the expiration date LiveData.
	 *
	 * @return The expiration date LiveData.
	 */

	@Query("SELECT endDate FROM " + Lesson.TABLE_NAME + " ORDER BY endDate DESC LIMIT 1")
	public abstract LiveData<DateTime> getExpirationDateLiveData();

	/**
	 * Returns an ordered list of all start dates.
	 *
	 * @return An ordered list of all start dates.
	 */

	@Query("SELECT startDate FROM " + Lesson.TABLE_NAME + " ORDER BY startDate")
	public abstract List<LocalDate> getStartDates();

	/**
	 * Returns the lessons contained in the specified bounds.
	 *
	 * @param boundA The first bound.
	 * @param boundB The second bound.
	 *
	 * @return The lessons contained in the specified bounds.
	 */

	@Query("SELECT * FROM " + Lesson.TABLE_NAME + " WHERE startDate >= :boundA AND endDate <= :boundB ORDER BY startDate")
	public abstract List<Lesson> getLessons(final DateTime boundA, final DateTime boundB);

	/**
	 * Inserts all lessons contained in the specified Collection.
	 *
	 * @param lessons The Collection of lessons.
	 */

	@Insert(onConflict = OnConflictStrategy.IGNORE)
	public abstract void insertLessons(final Collection<Lesson> lessons);

	/**
	 * Clears all lessons from the database.
	 */

	@Query("DELETE FROM " + Lesson.TABLE_NAME)
	public abstract void clearLessons();

}
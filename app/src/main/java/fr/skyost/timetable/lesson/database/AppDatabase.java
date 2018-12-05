package fr.skyost.timetable.lesson.database;

import androidx.room.Database;
import androidx.room.RoomDatabase;
import androidx.room.TypeConverters;
import fr.skyost.timetable.lesson.Lesson;

/**
 * The application database.
 */

@Database(entities = {Lesson.class}, version = 1)
@TypeConverters({JodaTypeConverter.class})
public abstract class AppDatabase extends RoomDatabase {

	/**
	 * Returns the lesson database access object.
	 *
	 * @return The lesson database access object.
	 */

	public abstract LessonDao getLessonDao();

}
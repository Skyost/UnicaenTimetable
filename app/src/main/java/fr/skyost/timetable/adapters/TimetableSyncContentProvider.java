package fr.skyost.timetable.adapters;

import android.content.ContentProvider;
import android.content.ContentValues;
import android.database.Cursor;
import android.net.Uri;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;

public class TimetableSyncContentProvider extends ContentProvider {

	@Override
	public final boolean onCreate() {
		return true;
	}

	@Nullable
	@Override
	public final Cursor query(@NonNull final Uri uri, final String[] projection, final String selection, final String[] selectionArgs, final String sortOrder) {
		return null;
	}

	@Nullable
	@Override
	public final String getType(@NonNull final Uri uri) {
		return null;
	}

	@Nullable
	@Override
	public final Uri insert(@NonNull final Uri uri, final ContentValues values) {
		return null;
	}

	@Override
	public final int delete(@NonNull final Uri uri, final String selection, final String[] selectionArgs) {
		return 0;
	}

	@Override
	public final int update(@NonNull final Uri uri, final ContentValues values, final String selection, final String[] selectionArgs) {
		return 0;
	}

}
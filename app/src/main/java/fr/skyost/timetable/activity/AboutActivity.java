package fr.skyost.timetable.activity;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.view.MenuItem;
import android.view.View;
import android.widget.TextView;

import java.util.HashMap;
import java.util.Map;

import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;
import fr.skyost.timetable.R;

/**
 * The about activity.
 */

public class AboutActivity extends AppCompatActivity {

	@Override
	protected void onCreate(final Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		// We set the required layout and toolbar.
		setContentView(R.layout.activity_about);
		setSupportActionBar(findViewById(R.id.about_bar_toolbar));

		// Then we can attach some events.
		findViewById(R.id.about_bar_fab).setOnClickListener(view -> {
			// Allows to share the application using the native picker.
			final Intent sharingIntent = new Intent(Intent.ACTION_SEND);
			sharingIntent.setType("text/plain");
			sharingIntent.putExtra(Intent.EXTRA_SUBJECT, getString(R.string.about_share_title));
			sharingIntent.putExtra(Intent.EXTRA_TEXT, getString(R.string.about_share_description));
			startActivity(Intent.createChooser(sharingIntent, getString(R.string.about_share_share)));
		});

		// Now we add some links to a map.
		final HashMap<String, String> links = new HashMap<>();
		links.put("Skyost", "https://www.skyost.eu");
		links.put("Github", "https://github.com/Skyost/UnicaenTimetable");
		links.put("GNU GPL v3", "http://choosealicense.com/licenses/gpl-3.0");

		// And we add them to the current description.
		final TextView description = findViewById(R.id.about_textview_description);
		description.setText(createLinks(description.getText().toString(), links));
		description.setMovementMethod(LinkMovementMethod.getInstance());

		// We don't forget to display the back button.
		final ActionBar actionBar = getSupportActionBar();
		if(actionBar != null) {
			actionBar.setDisplayHomeAsUpEnabled(true);
		}
	}

	@Override
	public boolean onOptionsItemSelected(final MenuItem item) {
		switch(item.getItemId()) {
		case android.R.id.home:
			// Mimic the back press.
			onBackPressed();
			return true;
		}
		return super.onOptionsItemSelected(item);
	}

	/**
	 * Adds some links to the text.
	 *
	 * @param text The text.
	 * @param links The links (key : text, value : link).
	 *
	 * @return The Spannable, ready to use.
	 */

	private Spannable createLinks(final String text, final Map<String, String> links) {
		final Spannable spannable = new SpannableString(text);

		// For each key, we find it in the specified text, and we attach a link using ClickableSpan.
		for(final Map.Entry<String, String> entry : links.entrySet()) {
			final String linkText = entry.getKey();
			spannable.setSpan(new ClickableSpan() {

				@Override
				public void onClick(final View view) {
					startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse(entry.getValue())));
				}

			}, text.indexOf(linkText), text.indexOf(linkText) + linkText.length(), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
		}
		return spannable;
	}

}
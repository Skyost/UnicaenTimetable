package fr.skyost.timetable.activities;

import android.content.Intent;
import android.content.res.Resources;
import android.net.Uri;
import android.os.Bundle;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
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

import fr.skyost.timetable.R;

public class AboutActivity extends AppCompatActivity {

	@Override
	protected final void onCreate(final Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		this.setContentView(R.layout.activity_about);
		this.setSupportActionBar((Toolbar)findViewById(R.id.about_bar_toolbar));
		this.findViewById(R.id.about_bar_fab).setOnClickListener(new View.OnClickListener() {

			@Override
			public final void onClick(final View view) {
				final Resources resources = AboutActivity.this.getResources();
				final Intent sharingIntent = new Intent(android.content.Intent.ACTION_SEND);
				sharingIntent.setType("text/plain");
				sharingIntent.putExtra(android.content.Intent.EXTRA_SUBJECT, resources.getString(R.string.about_share_title));
				sharingIntent.putExtra(android.content.Intent.EXTRA_TEXT, resources.getString(R.string.about_share_description));
				startActivity(Intent.createChooser(sharingIntent, resources.getString(R.string.about_share_share)));
			}

		});

		final HashMap<String, String> links = new HashMap<>();
		links.put("Skyost", "https://www.skyost.eu");
		links.put("Github", "https://github.com/Skyost/UnicaenTimetable");
		links.put("GNU GPL v3", "http://choosealicense.com/licenses/gpl-3.0");

		final TextView description = this.findViewById(R.id.about_textview_description);
		description.setText(createLinks(description.getText().toString(), links));
		description.setMovementMethod(LinkMovementMethod.getInstance());

		final ActionBar actionBar = this.getSupportActionBar();
		if(actionBar != null) {
			actionBar.setDisplayHomeAsUpEnabled(true);
		}
	}

	@Override
	public final boolean onOptionsItemSelected(final MenuItem item) {
		switch(item.getItemId()) {
		case android.R.id.home:
			this.onBackPressed();
			return true;
		}
		return super.onOptionsItemSelected(item);
	}

	/**
	 * Add some links to the text.
	 *
	 * @param text The text.
	 * @param links The links (text : link).
	 *
	 * @return The Spannable, ready to use.
	 */

	private Spannable createLinks(final String text, final Map<String, String> links) {
		final Spannable spannable = new SpannableString(text);
		for(final Map.Entry<String, String> entry : links.entrySet()) {
			final String linkText = entry.getKey();
			spannable.setSpan(new ClickableSpan() {

				@Override
				public final void onClick(final View view) {
					AboutActivity.this.startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse(entry.getValue())));
				}

			}, text.indexOf(linkText), text.indexOf(linkText) + linkText.length(), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
		}
		return spannable;
	}

}
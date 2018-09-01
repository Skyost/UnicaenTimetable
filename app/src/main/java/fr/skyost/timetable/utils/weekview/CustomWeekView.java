package fr.skyost.timetable.utils.weekview;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.RectF;
import android.text.Layout;
import android.text.SpannableStringBuilder;
import android.text.StaticLayout;
import android.text.TextUtils;
import android.text.style.StyleSpan;
import android.util.AttributeSet;
import android.view.MotionEvent;

import com.alamkanak.weekview.WeekViewEvent;

import java.util.Arrays;

import fr.skyost.timetable.utils.SwipeListener;

/**
 * A custom WeekView class. The idea is to extend / fix some features of WeekView in an easily-upgradable way.
 */

public class CustomWeekView extends BaseWeekView {

	/**
	 * The swipe listener.
	 */

	private final SwipeListener swipeListener;

	/**
	 * Creates a new custom week view instance.
	 *
	 * @param context The context.
	 */

	public CustomWeekView(final Context context) {
		super(context);

		swipeListener = new SwipeListener(context, () -> {}, () -> {});
	}

	/**
	 * Creates a new custom week view instance.
	 *
	 * @param context The context.
	 * @param attrs The attributes.
	 */

	public CustomWeekView(final Context context, final AttributeSet attrs) {
		super(context, attrs);

		swipeListener = new SwipeListener(context, () -> {}, () -> {});
	}

	/**
	 * Creates a new custom week view instance.
	 *
	 * @param context The context.
	 * @param attrs The attributes.
	 * @param defStyleAttr The default style.
	 */

	public CustomWeekView(final Context context, final AttributeSet attrs, final int defStyleAttr) {
		super(context, attrs, defStyleAttr);

		swipeListener = new SwipeListener(context, () -> {}, () -> {});
	}

	@Override
	protected void drawEventTitle(WeekViewEvent event, RectF rect, Canvas canvas, float originalTop, float originalLeft) {
		if (rect.right - rect.left - mEventPadding * 2 < 0) return;
		if (rect.bottom - rect.top - mEventPadding * 2 < 0) return;

		// Prepare the name of the event.
		SpannableStringBuilder bob = new SpannableStringBuilder();
		if (!TextUtils.isEmpty(event.getName())) {
			bob.append(event.getName());
			bob.setSpan(new StyleSpan(android.graphics.Typeface.BOLD), 0, bob.length(), 0);
		}
		// Prepare the location of the event.
		if (!TextUtils.isEmpty(event.getLocation())) {
			if (bob.length() > 0)
				bob.append(' ');
			bob.append(event.getLocation());
		}

		int availableHeight = (int) (rect.bottom - originalTop - mEventPadding * 2);
		int availableWidth = (int) (rect.right - originalLeft - mEventPadding * 2);

		// Get text color if necessary
		if (textColorPicker != null) {
			mEventTextPaint.setColor(textColorPicker.getTextColor(event));
		}
		// Get text dimensions.
		StaticLayout textLayout = new StaticLayout(bob, mEventTextPaint, availableWidth, Layout.Alignment.ALIGN_NORMAL, 1.0f, 0.0f, false);
		if (textLayout.getLineCount() > 0) {
			int lineHeight = textLayout.getHeight() / textLayout.getLineCount();

			if (availableHeight >= lineHeight) {
				// Calculate available number of line counts.
				int availableLineCount = availableHeight / lineHeight;

				// Ellipsize text to fit into event rect.
				String[] lines = textLayout.getText().toString().split("\\r?\\n");
				for(int i = 0; i != lines.length; i++) {
					lines[i] = TextUtils.ellipsize(lines[i], mEventTextPaint, availableWidth, TextUtils.TruncateAt.END).toString();
				}

				// We create a whole new text.
				if(lines.length > availableLineCount && !lines[availableLineCount - 1].endsWith("…")) {
					if(TextUtils.isEmpty(lines[availableLineCount - 1])) {
						lines[availableLineCount - 1] = "…";
					}
					else {
						lines[availableLineCount - 1] = lines[availableLineCount - 1].substring(0, lines[availableLineCount - 1].length() - 2) + "…";
					}
				}
				lines = Arrays.copyOfRange(lines, 0, Math.min(lines.length, availableLineCount));
				textLayout = new StaticLayout(TextUtils.join("\n", lines), mEventTextPaint, availableWidth, Layout.Alignment.ALIGN_NORMAL, 1.0f, 0.0f, false);

				// Draw text.
				canvas.save();
				canvas.translate(originalLeft + mEventPadding, originalTop + mEventPadding);
				textLayout.draw(canvas);
				canvas.restore();
			}
		}
	}

	/**
	 * Returns the swiping left runnable.
	 *
	 * @return The swiping left runnable.
	 */

	public Runnable getSwipeLeftRunnable() {
		return swipeListener.getSwipeLeft();
	}

	/**
	 * Sets the swiping left runnable.
	 *
	 * @param swipeLeft The swiping left runnable.
	 */

	public void setSwipeLeftRunnable(final Runnable swipeLeft) {
		swipeListener.setSwipeLeft(swipeLeft);
	}

	/**
	 * Returns the swiping right runnable.
	 *
	 * @return The swiping right runnable.
	 */

	public Runnable getSwipeRightRunnable() {
		return swipeListener.getSwipeRight();
	}

	/**
	 * Sets the swiping right runnable.
	 *
	 * @param swipeRight The swiping right runnable.
	 */

	public void setSwipeRightRunnable(final Runnable swipeRight) {
		swipeListener.setSwipeRight(swipeRight);
	}

	@Override
	public boolean dispatchTouchEvent(final MotionEvent event) {
		swipeListener.dispatchTouchEvent(event);
		return super.dispatchTouchEvent(event);
	}

}
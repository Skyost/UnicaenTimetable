package fr.skyost.timetable.utils;

import android.content.Context;
import android.view.GestureDetector;
import android.view.MotionEvent;

/**
 * A simple swipe listener.
 */

public class SwipeListener {

	/**
	 * The gesture detector.
	 */

	private final GestureDetector gestureDetector;

	/**
	 * Triggered when swiping to the left.
	 */

	private Runnable swipeLeft;

	/**
	 * Triggered when swiping to the right.
	 */

	private Runnable swipeRight;

	/**
	 * Creates a new swipe listener instance.
	 *
	 * @param context The context.
	 * @param swipeLeft Triggered when swiping to the left.
	 * @param swipeRight Triggered when swiping to the right.
	 */

	public SwipeListener(final Context context, final Runnable swipeLeft, final Runnable swipeRight) {
		this.gestureDetector = new GestureDetector(context, new GestureListener());
		this.swipeLeft = swipeLeft;
		this.swipeRight = swipeRight;
	}

	/**
	 * Dispatches a TouchEvent to the gesture detector.
	 *
	 * @param event The event.
	 */

	public void dispatchTouchEvent(final MotionEvent event) {
		gestureDetector.onTouchEvent(event);
	}

	/**
	 * Returns the swiping left runnable.
	 *
	 * @return The swiping left runnable.
	 */

	public Runnable getSwipeLeft() {
		return swipeLeft;
	}

	/**
	 * Sets the swiping left runnable.
	 *
	 * @param swipeLeft The swiping left runnable.
	 */

	public void setSwipeLeft(final Runnable swipeLeft) {
		this.swipeLeft = swipeLeft;
	}

	/**
	 * Returns the swiping right runnable.
	 *
	 * @return The swiping right runnable.
	 */

	public Runnable getSwipeRight() {
		return swipeRight;
	}

	/**
	 * Sets the swiping right runnable.
	 *
	 * @param swipeRight The swiping right runnable.
	 */

	public void setSwipeRight(final Runnable swipeRight) {
		this.swipeRight = swipeRight;
	}

	/**
	 * The gesture listener.
	 */

	private class GestureListener extends GestureDetector.SimpleOnGestureListener {

		/**
		 * The minimum swipe distance.
		 */

		private static final int SWIPE_DISTANCE_THRESHOLD = 100;

		/**
		 * The minimum swipe velocity.
		 */

		private static final int SWIPE_VELOCITY_THRESHOLD = 100;

		@Override
		public boolean onDown(MotionEvent e) {
			return true;
		}

		@Override
		public boolean onFling(MotionEvent e1, MotionEvent e2, float velocityX, float velocityY) {
			// We calculate the distance and the velocity and run the corresponding Runnable (if eligible).
			float distanceX = e2.getX() - e1.getX();
			float distanceY = e2.getY() - e1.getY();
			if(Math.abs(distanceX) > Math.abs(distanceY) && Math.abs(distanceX) > SWIPE_DISTANCE_THRESHOLD && Math.abs(velocityX) > SWIPE_VELOCITY_THRESHOLD) {
				if(distanceX > 0) {
					swipeRight.run();
				}
				else {
					swipeLeft.run();
				}
				return true;
			}
			return false;
		}
	}

}
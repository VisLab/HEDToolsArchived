package edu.utsa.tagger.guisupport;

import java.awt.Component;
import java.awt.Point;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;

public class ClickDragThreshold {
	
	private Point pressedPoint;
	private int dragThreshold = 10;
	
	public ClickDragThreshold(final Component component) {
		component.addMouseListener(new MouseAdapter() {
			@Override public void mousePressed(MouseEvent e) {
				pressedPoint = e.getLocationOnScreen();
			}

			@Override public void mouseReleased(MouseEvent e) {
				
				Point releasedPoint = e.getLocationOnScreen();
				int xDiff = releasedPoint.x - pressedPoint.x;
				int yDiff = releasedPoint.y - pressedPoint.y;
				
				if (xDiff == 0 && yDiff == 0) {
					return;
				}
				
				if (xDiff > -dragThreshold && xDiff < dragThreshold && yDiff > -dragThreshold && yDiff < dragThreshold) {
					mouseClicked(e);
					MouseEvent clickEvent = new MouseEvent(
							e.getComponent(), MouseEvent.MOUSE_CLICKED, e.getWhen(), e.getModifiers(), e.getX(), e.getY(), 
							e.getXOnScreen(), e.getYOnScreen(), e.getClickCount(), e.isPopupTrigger(), e.getButton());
					component.dispatchEvent(clickEvent);
				}
			}
		});
	}
}

package edu.utsa.tagger.guisupport;

import javax.swing.JComponent;

@SuppressWarnings("serial")
public class XDragPane extends JComponent
{
//	private static final Color TAG_MOUSEOVER_FILL1 = new Color(246, 247, 249, 125);
//	private static final Color TAG_MOUSEOVER_FILL2 = new Color(220, 228, 237, 125);
//	private static final Color TAG_MOUSEOVER_BORDER = new Color(160, 160, 255, 125);
//	private static final Color DRAGGHOST_DROP_FILL1 = Color.white;
//	private static final Color DRAGGHOST_DROP_FILL2 = new Color(228, 229, 240);
//	private static final Color DRAGGHOST_DROP_BORDER = new Color(118, 118, 118);
//	private static final Color DRAGGHOST_DROP_TEXT1 = Color.blue;
//	private static final Color DRAGGHOST_DROP_TEXT2 = new Color(0, 50, 150);
//	
//	private XComponent objectDragged = null;
//	private XComponent objectPendingDrop = null;
//	private String dragText = null;
//	private String dropTypeText = null;
//	private String dropText = null;
//
//	public XDragPane()
//	{
//		setOpaque(false);
//		setLayout(null);
//		setVisible(false);
//	}
//
//	public XComponent getDragged()
//	{
//		return objectDragged;
//	}
//
//	public XComponent getPendingDrop()
//	{
//		return objectPendingDrop;
//	}
//
//	public void setDragged(XComponent xc)
//	{
//		setVisible(true);
//		if (xc != null)
//		{
//			objectDragged = xc;
//			dragText = xc.getDragText();
//		}
//		else
//		{
//			objectDragged = null;
//			dragText = null;
//		}
//	}
//
//	public void setPendingDrop(XComponent xc)
//	{
//		XComponent oldObjectPendingDrop = objectPendingDrop;
//		if (xc == null || xc.isDroppable())
//			objectPendingDrop = xc;
//		else
//			objectPendingDrop = null;
//		if (objectPendingDrop == null)
//			dropText = null;
//		else
//		{
//			dropTypeText = objectPendingDrop.getDropActionText(objectDragged);
//			dropText = objectPendingDrop.getDropText();
//		}
//		if (oldObjectPendingDrop != null)
//			oldObjectPendingDrop.repaint();
//		if (objectPendingDrop != null)
//			objectPendingDrop.repaint();
//	}
//	
//	public void release()
//	{
//		if (objectDragged != null && objectPendingDrop != null)
//		{
//			objectPendingDrop.dropImport(objectDragged.dragExport());
//		}
//		interrupt();
//	}
//	
//	public void interrupt()
//	{
//		objectPendingDrop = null;
//		objectDragged = null;
//		dragText = null;
//		dropTypeText = null;
//		dropText = null;
//		setVisible(false);
//	}
//
//	@Override protected void paintComponent(Graphics graphics)
//	{
//		Point p = getMousePosition();
//
//		if (p != null) {
//
//			Graphics2D g = (Graphics2D) graphics;
//			g2d.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_LCD_HRGB);
//			FontMetrics metrics;
//			Rectangle2D stringBounds;
//			RoundRectangle2D r;
//
//			if (dragText != null) {
//				g.setFont(new Font("Segoe UI Light", Font.PLAIN, 24));
//				metrics = g.getFontMetrics();
//				stringBounds = metrics.getStringBounds(dragText, g);
//				r = new RoundRectangle2D.Double(p.x - stringBounds.getWidth()/2 - 10, p.y - stringBounds.getHeight() + 5, stringBounds.getWidth() + 20, stringBounds.getHeight() + 10, 5, 5);
//				g.setPaint(new GradientPaint(
//						new Point(0, (int) r.getY()),
//						TAG_MOUSEOVER_FILL1,
//						new Point(0, (int) (r.getY() + r.getHeight())),
//						TAG_MOUSEOVER_FILL2));
//				g.fill(r);
//				g.setColor(TAG_MOUSEOVER_BORDER);
//				g.draw(r);
//				g.setColor(Color.black);
//				g.drawString(dragText, (int) (r.getX() + 10), (int) (r.getY() + stringBounds.getHeight()));
//			}
//			if (dropTypeText != null && dropText != null) {
//				g.setFont(new Font("Segoe UI Light", Font.PLAIN, 12));
//				metrics = g.getFontMetrics();
//				stringBounds = metrics.getStringBounds(dropTypeText + dropText, g);
//				r = new RoundRectangle2D.Double(p.x + 20, p.y + 10, stringBounds.getWidth() + 10, stringBounds.getHeight() + 4, 5, 5);
//				g.setPaint(new GradientPaint(
//						new Point(0, (int) (r.getY())),
//						DRAGGHOST_DROP_FILL1,
//						new Point(0, (int) (r.getY() + r.getHeight())),
//						DRAGGHOST_DROP_FILL2));
//				g.fill(r);
//				g.setColor(DRAGGHOST_DROP_BORDER);
//				g.draw(r);
//				g.setColor(DRAGGHOST_DROP_TEXT1);
//				g.drawString(dropTypeText, (int) (r.getX() + 5), (int) (r.getY() + stringBounds.getHeight()));
//				g.setColor(DRAGGHOST_DROP_TEXT2);
//				stringBounds = metrics.getStringBounds(dropTypeText + " ", g);
//				g.drawString(dropText, (int) (r.getX() + stringBounds.getWidth() + 5), (int) (r.getY() + stringBounds.getHeight()));
//			}
//		}
//	}
}

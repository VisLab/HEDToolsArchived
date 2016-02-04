package edu.utsa.tagger.guisupport;

import java.awt.BasicStroke;
import java.awt.Color;
import java.awt.Component;
import java.awt.Graphics;
import java.awt.Graphics2D;

import javax.swing.border.AbstractBorder;

@SuppressWarnings("serial")
public class DashedBorder extends AbstractBorder {
	
	private Color color;
	
	public DashedBorder(Color color) {
		this.color = color;
	}
	
	@Override
    public void paintBorder(Component comp, Graphics g, int x, int y, int w, int h) {
        Graphics2D g2d = (Graphics2D) g;
        g2d.setColor(color);
        g2d.setStroke(new BasicStroke(1, BasicStroke.CAP_BUTT, BasicStroke.JOIN_BEVEL, 0, new float[]{1}, 0));
        g2d.drawRect(x, y, w - 1, h - 1);
    }
}

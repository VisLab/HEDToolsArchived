package edu.utsa.tagger.guisupport;

public class Constraint {
	
	private double top = 0;
	private double left = 0;
	private double bottom = 0;
	private double right = 0;
	private double width = 0;
	private double height = 0;
	private boolean topUsed = false;
	private boolean leftUsed = false;
	private boolean bottomUsed = false;
	private boolean rightUsed = false;
	private boolean heightUsed = false;
	private boolean widthUsed = false;
	
	public Constraint() {
		this("top:0 bottom:0");
	}
	
	public Constraint(String constraintString) {
		
		String tokens[] = constraintString.split(" ");
		for (int i = 0; i < tokens.length; i++) {
			String token[] = tokens[i].split(":");
			if (token.length != 2) {
				throw new RuntimeException("Invalid token: " + tokens[i]);
			}
			double value = Double.parseDouble(token[1]);
			if (token[0].equals("top")) {
				setTop(value);
			}
			else if (token[0].equals("left")) {
				setLeft(value);
			}
			else if (token[0].equals("bottom")) {
				setBottom(value);
			}
			else if (token[0].equals("right")) {
				setRight(value);
			}
			else if (token[0].equals("width")) {
				setWidth(value);
			}
			else if (token[0].equals("height")) {
				setHeight(value);
			}
			else {
				throw new RuntimeException("Invalid token: " + tokens[i]);
			}
		}
		
		boolean validConstraint;
		
		if (tokens.length == 4) {
			validConstraint = ((leftUsed && widthUsed)
							   || (rightUsed && widthUsed)
							   || (leftUsed && rightUsed))
							  && ((topUsed && heightUsed)
							   || (bottomUsed && heightUsed)
					           || (topUsed && bottomUsed));
		} else if (tokens.length == 2) {
			validConstraint = (leftUsed && widthUsed)
							  || (rightUsed && widthUsed)
							  || (leftUsed && rightUsed)
							  || (topUsed && heightUsed)
							  || (bottomUsed && heightUsed)
							  || (topUsed && bottomUsed);
		} else {
			throw new RuntimeException("Invalid number of constraints: " + tokens.length);
		}
		
		if (!validConstraint) {
			throw new RuntimeException("Invalid constraint mix: " + constraintString);
		}
	}
	
	public void clearHorizontal() {
		leftUsed = false;
		rightUsed = false;
		widthUsed = false;
	}
	
	public void clearVertical() {
		topUsed = false;
		bottomUsed = false;
		heightUsed = false;
	}

	public double getBottom() {
		return bottom;
	}

	public double getHeight() {
		return height;
	}

	public double getLeft() {
		return left;
	}

	public double getRight() {
		return right;
	}

	public double getTop() {
		return top;
	}

	public double getWidth() {
		return width;
	}

	public boolean isBottomUsed() {
		return bottomUsed;
	}

	public boolean isHeightUsed() {
		return heightUsed;
	}

	public boolean isLeftUsed() {
		return leftUsed;
	}

	public boolean isRightUsed() {
		return rightUsed;
	}

	public boolean isTopUsed() {
		return topUsed;
	}

	public boolean isWidthUsed() {
		return widthUsed;
	}

	public void setBottom(double bottom) {
		this.bottom = bottom;
		bottomUsed = true;
	}

	public void setHeight(double height) {
		this.height = height;
		heightUsed = true;
	}

	public void setLeft(double left) {
		this.left = left;
		leftUsed = true;
	}

	public void setRight(double right) {
		this.right = right;
		rightUsed = true;
	}
	
	public void setTop(double top) {
		this.top = top;
		topUsed = true;
	}

	public void setWidth(double width) {
		this.width = width;
		widthUsed = true;
	}
}

package edu.utsa.tagger.gui;

import java.awt.Color;
import java.awt.Font;
import java.awt.font.TextAttribute;
import java.io.InputStream;
import java.util.Hashtable;
import java.util.Map;

/**
 * This class contains the fonts and colors used throughout the Tagger GUI.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
public abstract class FontsAndColors {

	public static final float SMALL_FONT_SIZE = 14;
	public static final float MEDIUM_FONT_SIZE = 18;
	public static final float LARGE_FONT_SIZE = 24;

	public static final Color TRANSPARENT = new Color(0, 0, 0, 0);

	public static final Color GREY_VERY_VERY_LIGHT = new Color(250, 250, 250);
	public static final Color GREY_VERY_LIGHT = new Color(230, 230, 230);
	public static final Color GREY_LIGHT = new Color(210, 210, 210);
	public static final Color GREY_VERY_VERY_MEDIUM = new Color(190, 190, 190);
	public static final Color GREY_VERY_MEDIUM = new Color(170, 170, 170);
	public static final Color GREY_MEDIUM = new Color(150, 150, 150);
	public static final Color GREY_DARK = new Color(130, 130, 130);
	public static final Color GREY_VERY_DARK = new Color(110, 110, 110);
	public static final Color GREY_VERY_VERY_DARK = new Color(90, 90, 90);

	public static final Color BLUE_VERY_LIGHT = new Color(230, 230, 255);
	public static final Color BLUE_LIGHT = new Color(225, 225, 255);
	public static final Color BLUE_MEDIUM = new Color(205, 205, 255);
	public static final Color BLUE_DARK = new Color(100, 100, 255);

	public static final Color GREEN_VERY_LIGHT = new Color(235, 255, 235);
	public static final Color GREEN_LIGHT = new Color(225, 255, 225);
	public static final Color GREEN_MEDIUM = new Color(185, 255, 185);
	public static final Color GREEN_DARK = new Color(100, 255, 100);

	public static final Color SOFT_BLUE = new Color(0x4096EE);
	public static final Color POWDER_BLUE = new Color(173, 216, 230);

	public static final Color LIGHT_YELLOW = new Color(245, 245, 203);
	public static final Color WEIRD_YELLOW = new Color(225, 225, 183);

	public static final Color RED_MEDIUM = new Color(206, 85, 85);
	public static final Color RED_LIGHT = new Color(250, 192, 192);

	public static final Color ORANGE_MEDIUM = new Color(243, 141, 91);
	public static final Color ORANGE_LIGHT = new Color(250, 198, 168);

	public static final Color APP_BG = Color.WHITE;
	public static final Color GROUP_SELECTED = GREY_VERY_LIGHT;

	public static final Color MENU_BG = TRANSPARENT;

	public static final Color MENU_NORMAL_BG = TRANSPARENT;
	public static final Color MENU_NORMAL_FG = GREY_MEDIUM;
	public static final Color MENU_HOVER_BG = TRANSPARENT;
	public static final Color MENU_HOVER_FG = GREY_DARK;
	public static final Color MENU_PRESSED_BG = TRANSPARENT;
	public static final Color MENU_PRESSED_FG = GREY_MEDIUM;

	public static final Color COLLAPSER_NORMAL_FG = Color.BLACK;
	public static final Color COLLAPSER_HOVER_FG = GREY_DARK;
	public static final Color COLLAPSER_PRESSED_FG = GREY_MEDIUM;

	public static final Color PROPERTIES_FG = GREY_DARK;

	public static final Color PROPERTIES_CLOSE_BUTTON_NORMAL_FG = Color.WHITE;
	public static final Color PROPERTIES_CLOSE_BUTTON_HOVER_FG = Color.BLACK;
	public static final Color PROPERTIES_CLOSE_BUTTON_PRESSED_FG = Color.BLACK;

	public static final Color EVENTS_FG = Color.WHITE;
	public static final Color EVENTS_BG = new Color(0x4096EE);

	public static final Color TAGS_BG = TRANSPARENT;
	public static final Color TAGS_FG = GREY_DARK;

	public static final Color SEARCH_RESULTS_LIST_BG = Color.WHITE;

	public static final Color UNFOCUSED_TEXTBOX_BORDER = Color.BLACK;
	public static final Color FOCUSED_TEXTBOX_BORDER = Color.WHITE;

	public static final Color BUTTON_NORMAL_FG = Color.WHITE;
	public static final Color BUTTON_HOVER_FG = Color.WHITE;
	public static final Color BUTTON_PRESSED_FG = Color.WHITE;
	public static final Color BUTTON_NORMAL_BG = BLUE_MEDIUM;
	public static final Color BUTTON_HOVER_BG = BLUE_LIGHT;
	public static final Color BUTTON_PRESSED_BG = BLUE_DARK;

	public static final Color TAG_BG_NORMAL = Color.WHITE;
	public static final Color TAG_FG_NORMAL = Color.BLACK;
	public static final Color TAG_FG_HOVER = BLUE_DARK;
	public static final Color TAG_FG_PRESSED = GREY_DARK;
	public static final Color TAG_BG_SEMISELECTED = BLUE_VERY_LIGHT;
	public static final Color TAG_FG_SEMISELECTED = GREY_DARK;
	public static final Color TAG_BG_SELECTED = SOFT_BLUE;
	public static final Color TAG_FG_SELECTED = GREY_VERY_LIGHT;
	public static final Color TAG_FG_TAKES_VALUE = BLUE_DARK;

	public static final Color SEARCHTAG_BG_NORMAL = Color.WHITE;
	public static final Color SEARCHTAG_FG_NORMAL = GREY_DARK;
	public static final Color SEARCHTAG_BG_HOVER = Color.WHITE;
	public static final Color SEARCHTAG_FG_HOVER = Color.BLACK;
	public static final Color SEARCHTAG_BG_PRESSED = Color.WHITE;
	public static final Color SEARCHTAG_FG_PRESSED = GREY_DARK;
	public static final Color SEARCHTAG_BG_SELECTED = Color.WHITE;
	public static final Color SEARCHTAG_FG_SELECTED = SOFT_BLUE;

	public static final Color EDITTAG_BG = LIGHT_YELLOW;
	public static final Color EDITTAG_BORDER = new Color(215, 215, 50);

	public static final Color EVENT_BG_NORMAL = GREY_LIGHT;
	public static final Color EVENT_FG_NORMAL = GREY_DARK;
	public static final Color EVENT_BG_HOVER = GREY_LIGHT;
	public static final Color EVENT_FG_HOVER = BLUE_DARK;
	public static final Color EVENT_BG_PRESSED = GREY_LIGHT;
	public static final Color EVENT_FG_PRESSED = GREY_DARK;
	public static final Color EVENT_BG_SELECTED = SOFT_BLUE;
	public static final Color EVENT_FG_SELECTED = GREY_VERY_LIGHT;
	public static final Color EVENT_INFO_BACKGROUND = Color.white;
	public static final Color EVENT_TAG_REQUIRED = RED_MEDIUM;
	public static final Color EVENT_TAG_RECOMMENDED = ORANGE_MEDIUM;
	public static final Color EVENT_SELECTED = GREY_MEDIUM;

	public static final Color EVENTTAG_BG_NORMAL = TRANSPARENT;
	public static final Color EVENTTAG_FG_NORMAL = GREY_DARK;
	public static final Color EVENTTAG_BG_HOVER = TRANSPARENT;
	public static final Color EVENTTAG_FG_HOVER = BLUE_DARK;
	public static final Color EVENTTAG_BG_PRESSED = GREY_VERY_VERY_LIGHT;
	public static final Color EVENTTAG_FG_PRESSED = GREY_DARK;
	public static final Color EVENTTAG_FG_MISSING_NORMAL = RED_MEDIUM;
	public static final Color EVENTTAG_FG_MISSING_HOVER = RED_MEDIUM.darker();
	public static final Color EVENTTAG_FG_MISSING_PRESSED = RED_MEDIUM;

	public static final Color CONTEXTMENUITEM_BG_NORMAL = GREY_DARK;
	public static final Color CONTEXTMENUITEM_FG_NORMAL = GREY_VERY_LIGHT;
	public static final Color CONTEXTMENUITEM_BG_HOVER = SOFT_BLUE;
	public static final Color CONTEXTMENUITEM_FG_HOVER = GREY_VERY_LIGHT;
	public static final Color CONTEXTMENUITEM_BG_PRESSED = GREY_DARK;
	public static final Color CONTEXTMENUITEM_FG_PRESSED = GREY_VERY_LIGHT;

	public static final Color FILECHOOSER_CD_BG_NORMAL = GREY_DARK;
	public static final Color FILECHOOSER_CD_FG_NORMAL = GREY_VERY_LIGHT;
	public static final Color FILECHOOSER_CD_BG_HOVER = SOFT_BLUE;
	public static final Color FILECHOOSER_CD_FG_HOVER = GREY_VERY_LIGHT;
	public static final Color FILECHOOSER_CD_BG_PRESSED = GREY_DARK;
	public static final Color FILECHOOSER_CD_FG_PRESSED = GREY_VERY_LIGHT;
	public static final Color FILECHOOSER_ITEM_BG_NORMAL = Color.WHITE;
	public static final Color FILECHOOSER_ITEM_FG_NORMAL = GREY_DARK;
	public static final Color FILECHOOSER_ITEM_BG_HOVER = POWDER_BLUE;
	public static final Color FILECHOOSER_ITEM_FG_HOVER = GREY_DARK;
	public static final Color FILECHOOSER_ITEM_BG_PRESSED = Color.WHITE;
	public static final Color FILECHOOSER_ITEM_FG_PRESSED = GREY_DARK;
	public static final Color FILECHOOSER_ITEM_BG_SELECTED = GREY_VERY_LIGHT;
	public static final Color FILECHOOSER_ITEM_FG_SELECTED = GREY_DARK;

	public static final Color CONTEXTMENU_BG = Color.WHITE;
	public static final Color CONTEXTMENU_BORDER = Color.WHITE;

	public static final Color HIGHLIGHT_MATCH = BLUE_VERY_LIGHT;
	public static final Color HIGHLIGHT_CLOSE_MATCH = RED_LIGHT;
	public static final Color HIGHLIGHT_TAKES_VALUE = LIGHT_YELLOW;

	public static final Color DASHEDBORDER = Color.BLACK;

	public static final Font BASE_CONTENT_FONT = new Font(
			"Arial, Helvetica, sans-serif", Font.PLAIN, (int) SMALL_FONT_SIZE);
	public static final Font BASE_HEADER_FONT = new Font(
			"Arial, Helvetica, sans-serif", Font.PLAIN, (int) LARGE_FONT_SIZE);
	public static final Font BASE_MED_FONT = new Font(
			"Arial, Helvetica, sans-serif", Font.PLAIN, (int) MEDIUM_FONT_SIZE);
	public static final Font BASE_SYMBOL_FONT = loadFont("/seguisym.ttf",
			"Segoe UI Symbol").deriveFont(SMALL_FONT_SIZE);

	public static Font contentFont = BASE_CONTENT_FONT;
	public static Font headerFont = BASE_HEADER_FONT;
	public static Font secondHeaderFont = BASE_MED_FONT;
	public static Font symbolFont = BASE_SYMBOL_FONT;

	private static Font loadFont(String path, String name) {

		try {
			InputStream stream = FontsAndColors.class.getResourceAsStream(path);
			Font font = Font.createFont(Font.TRUETYPE_FONT, stream);
			stream.close();

			Map<TextAttribute, Object> map = new Hashtable<TextAttribute, Object>();
			map.put(TextAttribute.KERNING, TextAttribute.KERNING_ON);
			return font.deriveFont(map);
		} catch (Exception e) {
			System.out.println("Couldn't load font.");
			e.printStackTrace();
			return null;
		}
	}

	public static void resizeFonts(double newSize) {
		contentFont = BASE_CONTENT_FONT.deriveFont((float) (BASE_CONTENT_FONT
				.getSize() * newSize));
		symbolFont = BASE_SYMBOL_FONT.deriveFont((float) (BASE_SYMBOL_FONT
				.getSize() * newSize));
		headerFont = BASE_HEADER_FONT.deriveFont((float) (BASE_HEADER_FONT
				.getSize() * newSize));
	}
}

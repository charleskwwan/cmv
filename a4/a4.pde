import java.lang.reflect.*;
import java.util.Collections;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;

import de.bezier.data.sql.*;

PokeTable table;
Controller controller;
Tooltips tooltips;
ScatterPlot scatter;
NestedPies pies;
Histogram histo;

void setup() {
  size(1600, 900);
  
  table = new PokeTable("pokemon.db", "pokemon");
  controller = new Controller(table);
  tooltips = new Tooltips();
  
  scatter = new ScatterPlot(960, 40, 600, 290, controller, table, "wgt", "hgt");
  histo = new Histogram(960, 350, 600, 250, controller, table, "percentMale", "percentFemale");
  pies = new NestedPies(40, 40, 920, 820, controller, table, new String[]{"type1", "type2"});
  controller.addChart(scatter);
  controller.addChart(histo);
  controller.addChart(pies);
}

void draw() {
  background(255);
  controller.removeAllHovered();
  mouseOver();
  scatter.draw();
  histo.draw();
  pies.draw();
  tooltips.draw();
}

void mouseOver() {
  scatter.onOver();
  histo.onOver();
  pies.onOver();
}

void mousePressed() {
  scatter.onPress();
}

void mouseReleased() {
  scatter.onRelease();
}

void mouseClicked() {
  controller.onClick();
  scatter.onClick();
  histo.onClick();
  pies.onClick();
}
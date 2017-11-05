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
RadarChart radar;
NestedPies pies;

void setup() {

  size(1600, 900);
  
  table = new PokeTable("pokemon.db", "pokemon");
  controller = new Controller(table);
  tooltips = new Tooltips();
  
  scatter = new ScatterPlot(960, 40, 600, 400, controller, table, "wgt", "hgt");
  pies = new NestedPies(40, 40, 920, 820, controller, table, new String[]{"type1", "type2"});
  radar = new RadarChart(960, 440, 600, 400, controller, table, new String[]{"hp", "attack", "defense", "spattack", "spdefense", "speed"});

  controller.addChart(radar);
  controller.addChart(pies);
  controller.addChart(scatter);
}

void draw() {
  background(255);
  controller.removeAllHovered();
  mouseOver();
  scatter.draw();
  pies.draw();
  tooltips.draw();
  radar.draw();
  
}

void mouseOver() {
  scatter.onOver();
  pies.onOver();
  radar.onOver();
}

void mousePressed() {
  scatter.onPress();
}

void mouseReleased() {
  scatter.onRelease();
}

void mouseClicked() {
  controller.onClick();
  radar.onClick();
  scatter.onClick();
  pies.onClick();
}
import java.lang.reflect.*;
import java.util.Collections;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;

import de.bezier.data.sql.*;

PokeTable table;
Controller controller;
ScatterPlot scatter;
PieChart pie;

void setup() {
  size(1600, 900);
  table = new PokeTable("pokemon.db", "pokemon");
  controller = new Controller(table);
  scatter = new ScatterPlot(960, 40, 600, 400, controller, table, "wgt", "hgt");
  pie = new PieChart(40, 40, 900, 820, controller, table, "type1");
  controller.addChart(scatter);
  controller.addChart(pie);
}

void draw() {
  background(255);
  controller.removeAllHovered();
  mouseOver();
  scatter.draw();
  pie.draw();
}

void mouseOver() {
  scatter.onOver();
  pie.onOver();
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
  pie.onClick();
}
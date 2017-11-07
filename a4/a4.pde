import java.lang.reflect.*;
import java.util.Collections;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;

import de.bezier.data.sql.*;

final String[] pokeTypes = {"Normal", "Fire", "Water", "Electric", "Grass", "Ice", "Fighting",
                            "Poison", "Ground", "Flying", "Psychic", "Bug", "Rock", "Ghost",
                            "Dragon", "Dark", "Steel", "Fairy", ""};
final HashMap<String, Integer> pokeColors = makePokeColors();
final HashMap<Integer, PImage> pokeImages = new HashMap<Integer, PImage>();
final int fontSize = 12;

PokeTable table;
Controller controller;
DragLayout layout;
Tooltips tooltips;
Pokedex pokedex;

ScatterPlot scatter;
RadarChart radar;
NestedPies pies;
Histogram histo;
RoundButton resetBtn;

public class Reset implements ButtonCallback {
  public void f() { controller.removeAllFilters(); }
}

void setup() {
  size(1280, 800);
  textSize(fontSize);
  
  table = new PokeTable("pokemon.db", "pokemon");
  controller = new Controller(table);
  tooltips = new Tooltips();
  pokedex = new Pokedex(0, 0, 100, controller, table);
  
  scatter = new ScatterPlot(750, 30, 500, 250, controller, table, "wgt", "hgt");
  radar = new RadarChart(750, 290, 500, 230, controller, table, new String[]{"hp", "attack", "defense", "spattack", "spdefense", "speed"});
  histo = new Histogram(750, 530, 500, 250, controller, table, "percentMale", "percentFemale");
  pies = new NestedPies(80, 100, 670, 650, controller, table, new String[]{"type1", "type2"});
  layout = new DragLayout(0, 0, width, height, pies);
  layout.addCharts(new Chart[]{scatter, radar, histo});
  controller.addViews(new View[]{pokedex, scatter, histo, pies});
  
  resetBtn = new RoundButton(50, height - 50, 150, 150, "Reset", color(255, 255, 0), #F7D02C, new Reset());
}

void draw() {
  background(255);
  controller.removeAllHovered();
  mouseOver();
  pokedex.draw();
  layout.draw();
  tooltips.draw();
  resetBtn.draw();
  
}

void mouseOver() {
  layout.onOver();
}

void mousePressed() {
  layout.onPress();
}

void mouseReleased() {
  layout.onRelease();
}

void mouseClicked() {
  layout.onClick();
  resetBtn.onClick();
}

HashMap<String, Integer> makePokeColors() {
  HashMap<String, Integer> colors = new HashMap<String, Integer>();
  colors.put("Normal", #A8A77A);
  colors.put("Fire", #EE8130);
  colors.put("Water", #6390F0);
  colors.put("Electric", #F7D02C);
  colors.put("Grass", #7AC74C);
  colors.put("Ice", #96D9D6);
  colors.put("Fighting", #C22E28);
  colors.put("Poison", #A33EA1);
  colors.put("Ground", #E2BF65);
  colors.put("Flying", #A98FF3);
  colors.put("Psychic", #F95587);
  colors.put("Bug", #A6B91A);
  colors.put("Rock", #B6A136);
  colors.put("Ghost", #735797);
  colors.put("Dragon", #6F35FC);
  colors.put("Dark", #705746);
  colors.put("Steel", #B7B7CE);
  colors.put("Fairy", #D685AD);
  colors.put("", 0); // no type
  return colors;
}

PImage getPokeImage(int id) {
  if (!pokeImages.containsKey(id)) {
    PImage image = loadImage(String.valueOf(id) + ".png");
    pokeImages.put(id, image);
    return image;
  } else {
    return pokeImages.get(id);
  }
}
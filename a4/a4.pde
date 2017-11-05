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

PokeTable table;
Controller controller;
Tooltips tooltips;
Pokedex pokedex;

ScatterPlot scatter;
NestedPies pies;
Histogram histo;

void setup() {
  size(1600, 900);
  
  table = new PokeTable("pokemon.db", "pokemon");
  controller = new Controller(table);
  tooltips = new Tooltips();
  pokedex = new Pokedex(0, 0, controller, table);
  controller.addChart(pokedex);
  
  scatter = new ScatterPlot(960, 40, 600, 290, controller, table, "wgt", "hgt");
  histo = new Histogram(960, 350, 600, 250, controller, table, "percentMale", "percentFemale");
  pies = new NestedPies(40, 100, 920, 780, controller, table, new String[]{"type1", "type2"});
  controller.addChart(scatter);
  controller.addChart(histo);
  controller.addChart(pies);
}

void draw() {
  background(255);
  controller.removeAllHovered();
  mouseOver();
  pokedex.draw();
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
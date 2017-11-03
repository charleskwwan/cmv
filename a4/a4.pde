PokeTable table;
Controller controller;
ScatterPlot scatter;

void setup() {
  size(1600, 900);
  table = new PokeTable("pokemon.db", "pokemon");
  controller = new Controller(table);
  scatter = new ScatterPlot(200, 200, 800, 500, controller, table, "wgt", "hgt");
}

void draw() {
  background(255);
  controller.removeAllHovered();
  mouseOver();
  scatter.draw();
}

void mouseOver() {
  scatter.onOver();
}

void mousePressed() {
  scatter.onPress();
}

void mouseReleased() {
  scatter.onRelease();
}

void mouseClicked() {
  scatter.onClick();
}
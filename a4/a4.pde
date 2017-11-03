PokeTable tbl;
ScatterPlot scatter;

void setup() {
  size(1600, 900);
  tbl = new PokeTable("pokemon.db", "pokemon");
  scatter = new ScatterPlot(200, 200, 800, 500, new Controller(), tbl, "wgt", "hgt");
}

void draw() {
  background(255);
  scatter.draw();
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
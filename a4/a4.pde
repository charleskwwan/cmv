PokeTable tbl;
ScatterPlot scatter;
RadarChart radar;

void setup() {
  size(1000, 800);
  tbl = new PokeTable("pokemon.db", "pokemon");
  scatter = new ScatterPlot(200, 200, 800, 500, new Controller(), tbl, "wgt", "hgt");
  radar = new RadarChart(0, 0, 1000, 800, new Controller(), tbl, new String[]{"hp", "attack", "defense", "spattack", "spdefense", "speed"});
}

void draw() {
  background(255);
  
  radar.draw();
  radar.onHover();
  
}

void mousePressed() {
  radar.onClick();
}
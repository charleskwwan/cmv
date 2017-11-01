PokeTable tbl;

void setup() {
  size(1600, 900);
  tbl = new PokeTable("pokemon.db", "pokemon");
  ArrayList<Pokemon> ps = tbl.query(null, new String[]{"type1=\"Fairy\""});
  for (Pokemon p : ps) {
    println(p.name);
  }
}

void draw() {
}
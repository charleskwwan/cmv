import de.bezier.data.sql.*;

final String TBLNAME = "pokemon";
SQLite db;

void setup() {
  size(1600, 900);
  db = new SQLite(this, "pokemon.db");
  db.connect();
  
  db.query("SELECT * FROM " + TBLNAME + " WHERE type1=\"Fire\"");
  ArrayList<Pokemon> ps = new ArrayList<Pokemon>();
  while(db.next()) {
    Pokemon p = new Pokemon();
    db.setFromRow(p);
    ps.add(p);
  }
  for (Pokemon p : ps) {
    println(p);
  }
}

void draw() {
}
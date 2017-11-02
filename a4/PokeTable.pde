import de.bezier.data.sql.*;
final processing.core.PApplet APPLET = this;

public class WrongRowType extends Exception {}

public class PokeTable {
  private final String tblname;
  private SQLite db;
  
  public PokeTable(String fname, String tblname) {
    this.db = new SQLite(APPLET, fname);
    this.db.connect();
    this.tblname = tblname;
  }
  
  // example usage:
  // query(["name"], ["type=\"Fairy\""]) == SELECT name FROM <tblname> WHERE type="Fairy"
  public ArrayList<Pokemon> query(String[] columns, String[] conditions) {
    String colString = columns == null ? "*" : String.join(",", columns);
    String queryString = "SELECT " + colString + " FROM " + this.tblname;
    if (conditions != null) queryString += " WHERE " + String.join(",", conditions);
    this.db.query(queryString);
    
    ArrayList<Pokemon> rows = new ArrayList<Pokemon>();
    while (this.db.next()) {
      Pokemon r = new Pokemon();
      db.setFromRow(r);
      rows.add(r);
    }
    return rows;
  }
}
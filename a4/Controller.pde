import java.util.HashSet;
import java.util.Iterator;

public class Controller implements Iterable<Pokemon> {
  private PokeTable tbl;
  private ArrayList<Pokemon> ps;
  private HashSet<String> filters;
  
  public Controller(PokeTable tbl) {
    this.tbl = tbl;
    this.filters = new HashSet<String>();
    this.ps = this.tbl.query(null, null);
  }
  
  public int size() {
    return this.ps.size();
  }
  
  public Pokemon get(int i) {
    return this.ps.get(i);
  }
  
  @Override
  public Iterator<Pokemon> iterator() {
    return this.ps.iterator();
  }
  
  private void reload() {
    String[] conds = this.filters.size() > 0 ? this.filters.toArray(new String[this.filters.size()]) : null;
    this.ps = this.tbl.query(null, conds);
  }
  
  public void addFilter(String filter) {
    this.filters.add(filter);
    reload();
  }
  
  public void removeFilter(String filter) {
    this.filters.remove(filter);
    reload();
  }
  
  public void removeColumnFilters(String column) {
    Iterator<String> it = this.filters.iterator();
    while (it.hasNext()) {
      String f = it.next();
      if (f.contains(column)) it.remove();
    }
    reload();
  }
  
  public void removeAllFilters() {
    this.filters.clear();
    reload();
  }
}
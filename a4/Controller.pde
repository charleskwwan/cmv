import java.util.Collections;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;

public class Controller implements Iterable<Pokemon> {
  private PokeTable tbl;
  private ArrayList<Pokemon> ps;
  private ArrayList<Pokemon> hovered;
  private HashSet<String> filters;
  
  public Controller(PokeTable tbl) {
    this.tbl = tbl;
    this.filters = new HashSet<String>();
    this.ps = this.tbl.query(null, null);
    this.hovered = new ArrayList<Pokemon>();
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
  
  public void addHovered(Pokemon p) {
    this.hovered.add(p);
  }
  
  public void removeHovered(Pokemon p) {
    this.hovered.remove(p);
  }
  
  public void removeAllHovered() {
    this.hovered.clear();
  }
  
  public List<Pokemon> getHovered() {
    return Collections.unmodifiableList(this.hovered);
  }
  
  private void reload() {
    String[] conds = this.filters.size() > 0 ? this.filters.toArray(new String[this.filters.size()]) : null;
    this.ps = this.tbl.query(null, conds);
    removeAllHovered();
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
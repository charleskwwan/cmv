public class Controller implements Iterable<Pokemon> {
  private PokeTable tbl;
  private ArrayList<Pokemon> ps;
  private HashSet<Integer> hovered;
  private HashSet<String> filters;
  private ArrayList<View> views;
  
  public Controller(PokeTable tbl) {
    this.tbl = tbl;
    this.filters = new HashSet<String>();
    this.ps = this.tbl.query(null, null);
    this.hovered = new HashSet<Integer>();
    this.views = new ArrayList<View>();
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
  
  public void addView(View vw) {
    this.views.add(vw);
  }
  
  public void addViews(View[] vws) {
    for (View vw : vws) addView(vw);
  }
  
  public void addHovered(int id) {
    this.hovered.add(id);
  }
  
  public void addHovereds(int[] ids) {
    for (int id : ids) addHovered(id);
  }
  
  public void removeHovered(int id) {
    this.hovered.remove(id);
  }
  
  public void removeAllHovered() {
    this.hovered.clear();
  }
  
  public Set<Integer> getHovered() {
    return Collections.unmodifiableSet(this.hovered);
  }
  
  private void reload() {
    String[] conds = this.filters.size() > 0 ? this.filters.toArray(new String[this.filters.size()]) : null;
    this.ps = this.tbl.query(null, conds);
    removeAllHovered();
  }
  
  public void addFilter(String filter) {
    this.filters.add(filter);
    reload();
    for (View vw : this.views) vw.update();
  }
  
  public void addFilters(String[] filter) {
    for (String f : filter) this.filters.add(f);
    reload();
    for (View vw : this.views) vw.update();
  }
  
  public void addFilters(ArrayList<String> filters) {
    for (String f : filters) this.filters.add(f);
    reload();
    for (View vw : this.views) vw.update();
  }
  
  public void removeFilter(String filter) {
    this.filters.remove(filter);
    reload();
    for (View vw : this.views) vw.update();
  }
  
  public void removeColumnFilters(String column) {
    Iterator<String> it = this.filters.iterator();
    while (it.hasNext()) {
      String f = it.next();
      if (f.contains(column)) it.remove();
    }
    reload();
    for (View vw : this.views) vw.update();
  }
  
  public void removeAllFilters() {
    this.filters.clear();
    reload();
    for (View vw : this.views) vw.reset();
  }
  
  public Set<String> getFilters() {
    return Collections.unmodifiableSet(this.filters);
  }
  
  public void onClick() {
    if (OverUtils.overRect(mouseX, mouseY, 0, 0, width, height) && mouseButton == RIGHT)
      removeAllFilters();
  }
}
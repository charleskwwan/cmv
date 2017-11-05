public abstract class Chart extends ViewPort {
  protected Controller controller;
  protected PokeTable table;
  
  public Chart(float x, float y, float w, float h, Controller ctrl, PokeTable tbl) {
    super(x, y, w, h);
    this.controller = ctrl;
    this.table = tbl;
  }
  
  protected ArrayList<Pokemon> getRows(String[] additionalFilters) {
    Set<String> ctrlSet = this.controller.getFilters();
    String[] ctrlFilters = ctrlSet.toArray(new String[ctrlSet.size()]);
    String[] filters = concat(ctrlFilters, additionalFilters);
    return this.table.query(null, filters.length > 0 ? filters : null);
  }
  
  protected ArrayList<Pokemon> getRows() {
    return getRows(null);
  }
  
  protected ArrayList<Double> getColumnDouble(String column) {
    ArrayList<Double> doubles = new ArrayList<Double>();
    for (Pokemon p : this.controller) doubles.add(p.getDouble(column));
    return doubles;
  }
  
  protected ArrayList<Integer> getColumnInt(String column) {
    ArrayList<Integer> integers = new ArrayList<Integer>();
    for (Pokemon p : this.controller) integers.add(p.getInt(column));
    return integers;
  }
  
  public abstract void draw();
  public abstract void update();
  public abstract void reset();
}
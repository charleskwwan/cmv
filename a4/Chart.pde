public abstract class Chart extends ViewPort implements View {
  protected Controller controller;
  protected PokeTable table;
  
  public Chart(float x, float y, float w, float h, Controller ctrl, PokeTable tbl) {
    super(x, y, w, h);
    this.controller = ctrl;
    this.table = tbl;
  }
  
  protected ArrayList<Pokemon> getRows(String[] additionalFilters, String orderBy) {
    Set<String> ctrlSet = this.controller.getFilters();
    String[] ctrlFilters = ctrlSet.toArray(new String[ctrlSet.size()]);
    String[] filters = concat(ctrlFilters, additionalFilters);
    return this.table.query(null, filters.length > 0 ? filters : null, orderBy);
  }
  
  protected ArrayList<Pokemon> getRows(String[] additionalFilters) {
    return getRows(additionalFilters, null);
  }
  
  protected ArrayList<Pokemon> getRows() {
    return getRows(null, null);
  }
  
  protected ArrayList<Double> getColumnDouble(String column) {
    ArrayList<Double> doubles = new ArrayList<Double>();
    for (Pokemon p : this.controller) doubles.add(p.getDouble(column));
    return doubles;
  }
}
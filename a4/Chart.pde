public abstract class Chart extends ViewPort {
  protected Controller controller;
  protected PokeTable table;
  
  public Chart(float x, float y, float w, float h, Controller ctrl, PokeTable tbl) {
    super(x, y, w, h);
    this.controller = ctrl;
    this.table = tbl;
  }
  
  protected ArrayList<Double> getColumnDouble(String column) {
    ArrayList<Double> doubles = new ArrayList<Double>();
    for (Pokemon p : this.controller) doubles.add(p.getDouble(column));
    return doubles;
  }
  
  public abstract void draw();
}
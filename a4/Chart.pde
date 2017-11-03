public abstract class Chart extends ViewPort {
  protected Controller controller;
  protected PokeTable table;
  protected ArrayList<Pokemon> ps;
  
  public Chart(float x, float y, float w, float h, Controller ctrl, PokeTable tbl) {
    super(x, y, w, h);
    this.controller = ctrl;
    this.table = tbl;
    this.ps = getRows();
  }
  
  // todo: get restrictions from controller to narrow down query
  protected ArrayList<Pokemon> getRows() {
    return table.query(null, null);
  }
  
  protected ArrayList<Integer> getIntColumn(String column) {
    ArrayList<Integer> integers = new ArrayList<Integer>();
    for (Pokemon p : ps) integers.add(p.getInt(column));
    return integers;
  }
  
  public abstract void draw();
}
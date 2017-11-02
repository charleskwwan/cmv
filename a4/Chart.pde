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
  
  public abstract void draw();
}
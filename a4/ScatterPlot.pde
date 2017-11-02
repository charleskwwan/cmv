public class ScatterPlot extends Chart {
  private String xcol, ycol;
  
  public ScatterPlot(float x, float y, float w, float h, Controller ctrl, PokeTable tbl, String xcol, String ycol) {
    super(x, y, w, h, ctrl, tbl);
    this.xcol = xcol;
    this.ycol = ycol;
  }
  
  public void draw() {
  }
}
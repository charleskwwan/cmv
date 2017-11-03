public class PieChart extends Chart {
  private String column;
  private ArrayList<Slice> slices;
  
  public PieChart(float x, float y, float w, float h, Controller ctrl, PokeTable tbl, String col) {
    super(x, y, w, h, ctrl, tbl);
    this.column = col;
    this.slices = new ArrayList<Slice>();
  }
  
  private float getRadius() {
    return min(getWidth(), getHeight()) / 2 - 20;
  }
  
  private class Slice {
    public String type;
    public ArrayList<Pokemon> ps;
    public float x, y, r, a1, a2;
    
    public Slice(float x, float y, float r, float a1, float a2, String type, ArrayList<Pokemon> ps) {
      this.x = x;
      this.y = y;
      this.r = r;
      this.a1 = a1;
      this.a2 = a2;
      this.type = type;
      this.ps = ps;
    }
    
    public void draw() {
      color c = pokeColors.get(this.type);
      stroke(c);
      fill(c);
      arc(this.x, this.y, this.r*2, this.r*2, this.a1, this.a2, PIE);
    }
    
    public boolean isOver() {
      return OverUtils.overSlice(mouseX, mouseY, this.x, this.y, this.r, this.a1, this.a2);
    }
  }
  
  //private void makeSlices() {
  //  slices.clear();
  //}
  
  public void draw() {
  }
}
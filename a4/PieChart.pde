public class PieChart extends Chart {
  private String column;
  private ArrayList<Slice> slices;
  
  public PieChart(float x, float y, float w, float h, Controller ctrl, PokeTable tbl, String col) {
    super(x, y, w, h, ctrl, tbl);
    this.column = col;
    this.slices = new ArrayList<Slice>();
    makeSlices(); // temp
  }
  
  private float getRadius() {
    return min(getWidth(), getHeight()) / 2 - 20;
  }
  
  private class Slice {
    private final float expandFact = 1.05;
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
      float rad = isOver() ? this.r * this.expandFact : this.r;
      int opacity = isOver() ? 255 : 200;
      noStroke();
      fill(color(pokeColors.get(this.type), opacity));
      arc(this.x, this.y, rad*2, rad*2, this.a1, this.a2, PIE);
    }
    
    public boolean isOver() {
      return OverUtils.overSlice(mouseX, mouseY, this.x, this.y, this.r, this.a1, this.a2);
    }
  }
  
  private void makeSlices() {
    slices.clear();
    float offset = 0;
    for (int i = 0; i < pokeTypes.length; i++) {
      String type = pokeTypes[i];
      ArrayList<Pokemon> tmons = getRows(new String[]{this.column + "='" + type + "'"});
      if (tmons.size() == 0) continue;
      float a = TWO_PI * (float)tmons.size() / this.controller.size();
      slices.add(new Slice(getCenterX(), getCenterY(), getRadius(), offset, offset + a, type, tmons));
      offset += a;
    }
  }
  
  public void update() {
    makeSlices();
  }
  
  public void draw() {
    for (Slice slc : this.slices) slc.draw();
  }
  
  public void onOver() {
    for (Slice slc : this.slices) {
      if (slc.isOver()) {
        for (Pokemon p : slc.ps) this.controller.addHovered(p.id);
      }
    } 
  }
}
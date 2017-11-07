public class PieChart extends Chart {
  private String column;
  private ArrayList<Slice> slices;
  
  public PieChart(float x, float y, float w, float h, Controller ctrl, PokeTable tbl, String col) {
    super(x, y, w, h, ctrl, tbl);
    this.column = col;
    this.slices = new ArrayList<Slice>();
    makeSlices(); // temp
  }
  
  public String getColumn() {
    return this.column;
  }
  
  private float getRadius() {
    return min(getWidth(), getHeight()) / 2 - 20;
  }
  
  private class Slice implements Tooltip {
    private final float expandFact = 1.05;
    public String type;
    public ArrayList<Pokemon> ps;
    public float x, y, r, a1, a2;
    
    public Slice(float x, float y, float r, float a1, float a2, String type, ArrayList<Pokemon> ps) {
      super();
      this.x = x;
      this.y = y;
      this.r = r;
      this.a1 = a1;
      this.a2 = a2;
      this.type = type;
      this.ps = ps;
    }
    
    public void draw() {
      Set<Integer> hovered = PieChart.this.controller.getHovered();
      float rad = this.r;
      int opacity = 200;
      for (Pokemon p : this.ps) {
        if (hovered.contains(p.id)) {
          rad = this.r * this.expandFact;
          opacity = 255;
          break;
        }
      }
      noStroke();
      fill(color(pokeColors.get(this.type), opacity));
      arc(this.x, this.y, rad*2, rad*2, this.a1, this.a2, PIE);
    }
    
    public void drawTooltip() {
      String typeStr = PieChart.this.column + ": " + (this.type == "" ? "None" : this.type);
      String countStr = "count: " + String.valueOf(this.ps.size());
      float ttW = max(textWidth(typeStr), textWidth(countStr)) + 15;
      float ttH = 2 * (textAscent() + textDescent()) + 10;
      color ttcolor = pokeColors.get(this.type);
      noStroke();
      fill(color(255-red(ttcolor), 255-green(ttcolor), 255-blue(ttcolor)), 200);
      rect(mouseX, mouseY - ttH - 5, ttW, ttH);
      fill((red(ttcolor) + green(ttcolor) + blue(ttcolor)) / 3 > 128 ? 255 : 0);
      text(typeStr, mouseX + 5, mouseY - 2 * (textAscent() + textDescent()));
      text(countStr, mouseX + 5, mouseY - textAscent() - textDescent());
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
    
  public void draw() {
    if (this.controller.size() == 0) {
      noFill();
      stroke(0);
      ellipse(getCenterX(), getCenterY(), getRadius()*2, getRadius()*2);
    }
    for (Slice slc : this.slices) slc.draw();
  }
  
  public void update() {
    makeSlices();
  }
  
  public void reset() {
    makeSlices();
  }
  
  public boolean isOver() {
    return OverUtils.overCircle(mouseX, mouseY, getCenterX(), getCenterY(), getRadius());
  }
  
  public void onOver() {
    for (Slice slc : this.slices) {
      if (slc.isOver()) {
        for (Pokemon p : slc.ps) this.controller.addHovered(p.id);
        tooltips.add(slc);
        break;
      }
    }
  }
  
  public void onClick() {
    for (Slice slc : this.slices) {
      if (slc.isOver() && mouseButton == LEFT) {
        this.controller.addFilter(this.column + "='" + slc.type + "'");
        break;
      }
    }
  }
}
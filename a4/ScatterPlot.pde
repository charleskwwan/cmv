public class ScatterPlot extends Chart {
  private String xhead, yhead;
  private double xlo, xhi, ylo, yhi;
  private Pair<Float, Float> dragStart;
  private ArrayList<Point> pts;
  
  public ScatterPlot(float x, float y, float w, float h, Controller ctrl, PokeTable tbl, String xhead, String yhead) {
    super(x, y, w, h, ctrl, tbl);
    this.xhead = xhead;
    this.yhead = yhead;
    this.pts = new ArrayList<Point>();
    reset();
    this.dragStart = null;
  }
  
  private int getNumGaps(double lo, double hi) {
    return (int)(abs((float)(hi - lo)) / 80);
  }
  
  private float getChartX() {
    return getX() + textAscent() + textDescent() + textWidth(String.format("%.2f", this.yhi)) + 15;
  }
  
  private float getChartY() {
    return getY();
  }
  
  private float getChartWidth() {
    return getX() + getWidth() - getChartX();
  }
  
  private float getChartHeight() {
    return getHeight() - (2 * (textAscent() + textDescent()) + 15);
  }
  
  private class Point implements Tooltip{
    private final float imgSize = 70;
    private final float pointSize = 10;
    public Pokemon p;
    public float x, y;
    
    public Point(Pokemon p, float x, float y) {
      this.p = p;
      this.x = x;
      this.y = y;
    }
    
    public void draw() {
      color pcolor = color(pokeColors.get(p.type1), 175);
      stroke(pcolor);
      fill(pcolor);
      ellipse(this.x, this.y, this.pointSize, this.pointSize);
    }
    
    public void drawImage() {
      image(this.p.getImage(), this.x - this.imgSize/2, this.y - this.imgSize/2, imgSize, imgSize);
    }
    
    public void drawTooltip() {
      String nameStr = "name: " + this.p.name;
      String dataStr = ScatterPlot.this.xhead + ": " + String.valueOf(this.p.getDouble(ScatterPlot.this.xhead)) + 
                ", " + ScatterPlot.this.yhead + ": " + String.valueOf(this.p.getDouble(ScatterPlot.this.yhead));
      float ttW = max(textWidth(nameStr), textWidth(dataStr)) + 10;
      float ttH = 2 * (textAscent() + textDescent()) + 10;
      float ttX = this.x - ttW / 2;
      float ttY = this.y + this.imgSize / 2;
      color ttcolor = pokeColors.get(this.p.type1);
      noStroke();
      fill(ttcolor, 200);
      rect(ttX, ttY, ttW, ttH);
      fill((red(ttcolor) + green(ttcolor) + blue(ttcolor)) / 3 > 128 ? 0 : 255);
      text(nameStr, ttX + (ttW - textWidth(nameStr))/2, ttY + textAscent() + textDescent());
      text(dataStr, ttX + (ttW - textWidth(dataStr))/2, ttY + 2 * (textAscent() + textDescent()));
    }
    
    public boolean isOver() {
      return OverUtils.overCircle(mouseX, mouseY, this.x, this.y, this.pointSize/2);
    }
  }
  
  public void draw() { 
    float chartX = getChartX();
    float chartY = getChartY();
    float chartW = getChartWidth();
    float chartH = getChartHeight();
    
    // headers
    fill(0);
    text(xhead, chartX + chartW / 2, getY() + getHeight() - textAscent() - textDescent() + 10); // x header
    pushMatrix(); // y header
    translate(getX() + textAscent() + textDescent() - 5, chartY + (chartH + textWidth(yhead)) / 2);
    rotate(radians(-90));
    text(yhead, 0, 0);
    popMatrix();
    
    // x grid
    fill(0);
    int xgaps = getNumGaps(chartX, chartX + chartW);
    for (int i = 0; i < xgaps + 1; i++) {
      String tickStr = String.format("%.2f", this.xlo + i * (this.xhi - this.xlo) / xgaps);
      float tickX = chartX + i * chartW / xgaps;
      stroke(200);
      line(tickX, chartY, tickX, chartY + chartH);
      stroke(0);
      line(tickX, chartY + chartH, tickX, chartY + chartH + 5);
      text(tickStr, tickX - textWidth(tickStr) / 2, chartY + chartH + 25);
    }
    
    // y grid
    fill(0);
    int ygaps = getNumGaps(chartY, chartY + chartH);
    for (int i = 0; i < ygaps + 1; i++) {
      String tickStr = String.format("%.2f", this.yhi - i * (this.yhi - this.ylo) / ygaps);
      float tickY = chartY + i * chartH / ygaps;
      stroke(200);
      line(chartX, tickY, chartX + chartW, tickY);
      stroke(0);
      line(chartX, tickY, chartX - 5, tickY);
      text(tickStr, chartX - textWidth(tickStr) - 10, tickY + 5);
    }
    
    // axis lines
    stroke(0);
    line(chartX, chartY + chartH, chartX + chartW, chartY + chartH); // x axis
    line(chartX, chartY, chartX, chartY + chartH); // y axis
    
    // points
    Set<Integer> hovered = this.controller.getHovered();
    for (Point pt : this.pts) if (!hovered.contains(pt.p.id)) pt.draw();
    for (Point pt : this.pts) if (hovered.contains(pt.p.id)) pt.drawImage();
    
    // drag rectangle
    if (this.dragStart != null) {
      stroke(230, 100);
      fill(230, 100);
      float otherx = mouseX < chartX ? chartX : (mouseX > chartX + chartW ? chartX + chartW : mouseX);
      float othery = mouseY < chartY ? chartY : (mouseY > chartY + chartH ? chartY + chartH : mouseY);
      rect(min(dragStart.fst, otherx), min(dragStart.snd, othery), abs(dragStart.fst - otherx), abs(dragStart.snd - othery)); 
    }
  }
  
  public void update() {
    makePoints();
  }
  
  private void makePoints() {
    this.pts.clear();
    for (Pokemon p : this.controller) {
      float px = getChartX() + getChartWidth() * (float)((p.getDouble(this.xhead) - this.xlo) / (this.xhi - this.xlo));
      float py = getChartY() + getChartHeight() - getChartHeight() * (float)((p.getDouble(this.yhead) - this.ylo) / (this.yhi - this.ylo));
      this.pts.add(new Point(p, px, py));
    }
  }
  
  public void reset() {
    resetRanges();
    makePoints();
  }
  
  private void resetRanges() {
    this.xlo = this.ylo = 0;
    this.xhi = ListUtils.maxDouble(getColumnDouble(this.xhead));
    this.yhi = ListUtils.maxDouble(getColumnDouble(this.yhead));
  }
  
  private void setRangesWithDrag() {
    if (dragStart == null) return;
    
    float chartX = getChartX();
    float chartY = getChartY();
    float chartW = getChartWidth();
    float chartH = getChartHeight();
    float otherx = mouseX < chartX ? chartX : (mouseX > chartX + chartW ? chartX + chartW : mouseX);
    float othery = mouseY < chartY ? chartY : (mouseY > chartY + chartH ? chartY + chartH : mouseY);
    
    double xlo = this.xlo + (this.xhi - this.xlo) * (min(dragStart.fst, otherx) - chartX) / chartW;
    double xhi = this.xlo + (this.xhi - this.xlo) * (max(dragStart.fst, otherx) - chartX) / chartW;
    this.xlo = xlo;
    this.xhi = xhi;
    double ylo = this.ylo + (this.yhi - this.ylo) * (chartY + chartH - max(dragStart.snd, othery)) / chartH;
    double yhi = this.ylo + (this.yhi - this.ylo) * (chartY + chartH - min(dragStart.snd, othery)) / chartH;
    this.ylo = ylo;
    this.yhi = yhi;
    
    String[] rangeFilters = {
      this.xhead + ">=" + String.valueOf(this.xlo),
      this.xhead + "<=" + String.valueOf(this.xhi),
      this.yhead + ">=" + String.valueOf(this.ylo),
      this.yhead + "<=" + String.valueOf(this.yhi)
    };
    this.controller.addFilters(rangeFilters);
  }
  
  private Point onWhichPoint() {
      for (Point pt : this.pts) if (pt.isOver()) return pt;
      return null;
  }
  
  public void onOver() {
    Point over = onWhichPoint();
    if (over != null) {
      this.controller.addHovered(over.p.id);
      tooltips.add(over);
    }
  }
  
  public void onPress() {
    if (OverUtils.overRect(mouseX, mouseY, getChartX(), getChartY(), getChartWidth(), getChartHeight()) && mouseButton == LEFT)
      this.dragStart = new Pair<Float, Float>((float)mouseX, (float)mouseY);
  }
  
  public void onRelease() {
    if (dragStart != null && (dragStart.fst != mouseX || dragStart.snd != mouseY)) setRangesWithDrag();
    this.dragStart = null;
  }
  
  public void onClick() {
    if (isOver() && mouseButton == LEFT) {
      Point over = onWhichPoint();
      if (over != null) this.controller.addFilter("id='" + over.p.id + "'");
    }
  }
}
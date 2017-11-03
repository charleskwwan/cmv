final float imgSize = 70;
final float pointSize = 10;
final color pointColor = color(30, 144, 255, 150);

public class ScatterPlot extends Chart {
  private String xhead, yhead;
  private double xlo, xhi, ylo, yhi;
  private ArrayList<Pair<Float, Double>> xticks, yticks;
  private Pair<Float, Float> dragStart;
  
  public ScatterPlot(float x, float y, float w, float h, Controller ctrl, PokeTable tbl, String xhead, String yhead) {
    super(x, y, w, h, ctrl, tbl);
    this.xhead = xhead;
    this.yhead = yhead;
    resetRanges();
    this.dragStart = null;
  }
  
  private int getNumGaps(double lo, double hi) {
    return (int)(abs((float)(hi - lo)) / 80);
  }
  
  private ArrayList<Pair<Float, Double>> makeRange(float poslo, float poshi, double vallo, double valhi) {
    ArrayList<Pair<Float, Double>> range = new ArrayList<Pair<Float, Double>>();
    int ngaps = getNumGaps(poslo, poshi);
    for (int i = 0; i < ngaps + 1; i++) {
      float pos = poslo + i * abs(poshi - poslo) / ngaps;
      double val = vallo + i * abs((float)(valhi - vallo)) / ngaps;
      range.add(new Pair<Float, Double>(pos, val));
    }
    return range;
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
    for (Pair<Float, Double> p : this.xticks) {
      String tickStr = String.format("%.2f", p.snd);
      stroke(200);
      line(p.fst, chartY, p.fst, chartY + chartH);
      stroke(0);
      line(p.fst, chartY + chartH, p.fst, chartY + chartH + 5);
      text(tickStr, p.fst - textWidth(tickStr) / 2, chartY + chartH + 25);
    }
    
    // y grid
    fill(0);
    //Pair<Float, Double> last = this.yticks.get(this.yticks.size()-1);
    for (Pair<Float, Double> p : this.yticks) {
      String tickStr = String.format("%.2f", abs((float)(this.yhi + this.ylo - p.snd)));
      stroke(200);
      line(chartX, p.fst, chartX + chartW, p.fst);
      stroke(0);
      line(chartX, p.fst, chartX - 5, p.fst);
      text(tickStr, chartX - textWidth(tickStr) - 10, p.fst + 5);
    }
    
    // axis lines
    stroke(0);
    line(chartX, chartY + chartH, chartX + chartW, chartY + chartH); // x axis
    line(chartX, chartY, chartX, chartY + chartH); // y axis
    
    // points
    Pokemon over = null;
    for (Pokemon p : ps) {
      double xval = p.getDouble(this.xhead);
      double yval = p.getDouble(this.yhead);
      if (xval < this.xlo || xval > this.xhi || yval < this.ylo || yval > this.yhi) continue; // todo: remove after controller implemented
      float px = (float)(chartX + chartW * ((xval- this.xlo) / (this.xhi - this.xlo)));
      float py = (float)(chartY + chartH - chartH * ((yval - this.ylo) / (this.yhi - this.ylo)));
      if (OverUtils.overCircle(mouseX, mouseY, px, py, pointSize / 2)) {
        over = p;
      } else {
        color pcolor = color(pokeColors.get(p.getString("type1")), 175);
        stroke(pcolor);
        fill(pcolor);
        ellipse(px, py, pointSize, pointSize);
      }
    }
    if (over != null) image(
      over.getImage(),
      (float)(chartX + chartW * ((over.getDouble(this.xhead) - this.xlo) / (this.xhi - this.xlo))) - imgSize / 2,
      (float)(chartY + chartH - chartH * ((over.getDouble(this.yhead) - this.ylo) / (this.yhi - this.ylo))) - imgSize / 2,
      imgSize,
      imgSize
    );
    
    // drag rectangle
    if (this.dragStart != null) {
      stroke(230, 100);
      fill(230, 100);
      float otherx = mouseX < chartX ? chartX : (mouseX > chartX + chartW ? chartX + chartW : mouseX);
      float othery = mouseY < chartY ? chartY : (mouseY > chartY + chartH ? chartY + chartH : mouseY);
      rect(min(dragStart.fst, otherx), min(dragStart.snd, othery), abs(dragStart.fst - otherx), abs(dragStart.snd - othery)); 
    }
  }
  
  private void resetRanges() {
    this.xlo = this.ylo = 0;
    this.xhi = ListUtils.maxDouble(getColumnDouble(xhead));
    this.yhi = ListUtils.maxDouble(getColumnDouble(yhead));
    this.xticks = makeRange(getChartX(), getChartX() + getChartWidth(), this.xlo, this.xhi);
    this.yticks = makeRange(getChartY(), getChartY() + getChartHeight(), this.ylo, this.yhi);
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
    
    this.xticks = makeRange(chartX, chartX + chartW, this.xlo, this.xhi);
    this.yticks = makeRange(chartY, chartY + chartH, this.ylo, this.yhi);
  }
  
  public void onPress() {
    if (isOver() && mouseButton == LEFT)
      this.dragStart = new Pair<Float, Float>((float)mouseX, (float)mouseY);
  }
  
  public void onRelease() {
    if (dragStart != null && (dragStart.fst != mouseX || dragStart.snd != mouseY)) setRangesWithDrag();
    this.dragStart = null;
  }
  
  public void onClick() {
    if (isOver() && mouseButton == RIGHT) resetRanges();
  }
}
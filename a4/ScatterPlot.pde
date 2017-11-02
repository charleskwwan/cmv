final float imgSize = 70;
final float pointSize = 10;
final color pointColor = color(30, 144, 255, 150);

public class ScatterPlot extends Chart {
  private String xhead, yhead;
  private float xlo, xhi, ylo, yhi;
  private ArrayList<Pair<Float, Double>> xticks, yticks;
  
  public ScatterPlot(float x, float y, float w, float h, Controller ctrl, PokeTable tbl, String xhead, String yhead) {
    super(x, y, w, h, ctrl, tbl);
    this.xhead = xhead;
    this.yhead = yhead;
    this.xlo = this.ylo = 0;
    this.xhi = (float)ListUtils.maxDouble(getColumn(xhead));
    this.yhi = (float)ListUtils.maxDouble(getColumn(yhead));
  }
  
  private ArrayList<Double> getColumn(String column) {
    ArrayList<Double> doubles = new ArrayList<Double>();
    for (Pokemon p : ps) doubles.add(p.getDouble(column));
    return doubles;
  }
  
  private int getNumGaps(double lo, double hi) {
    return (int)((hi - lo) / 80);
  }
  
  //private ArrayList<Pair<Float, Double>> makeRange(float posxlo, float posxhi, double valxlo, double valxhi) {
  //  int ngaps = getNumGaps(posxlo, 
  //}
  
  private float getChartX() {
    return getX() + textAscent() + textDescent() + textWidth(String.valueOf(this.yhi)) + 15;
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
    
    // axis lines
    stroke(0);
    line(chartX, chartY + chartH, chartX + chartW, chartY + chartH); // x axis
    line(chartX, chartY, chartX, chartY + chartH); // y axis
    
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
    int xgaps = getNumGaps(0, chartW);
    for (int i = 0; i < xgaps + 1; i++) {
      String tickStr = String.format("%.2f", xlo + i * (xhi - xlo) / xgaps);
      float tickX = chartX + i * chartW / xgaps;
      stroke(200);
      line(tickX, chartY, tickX, chartY + chartH);
      stroke(0);
      line(tickX, chartY + chartH, tickX, chartY + chartH + 5);
      text(tickStr, tickX - textWidth(tickStr) / 2, chartY + chartH + 25);
    }
    
    // y grid
    fill(0);
    int ygaps = getNumGaps(0, chartH);
    for (int i = 0; i < ygaps + 1; i++) {
      String tickStr = String.format("%.2f", yhi - i * (yhi - ylo) / ygaps);
      float tickY = chartY + i * chartH / ygaps;
      stroke(200);
      line(chartX, tickY, chartX + chartW, tickY);
      stroke(0);
      line(chartX, tickY, chartX - 5, tickY);
      text(tickStr, chartX - textWidth(tickStr) - 10, tickY + 5);
    }
    
    // points
    Pokemon over = null;
    for (Pokemon p : ps) {
      float px = (float)(chartX + chartW * (p.getDouble(this.xhead) / xhi - xlo));
      float py = (float)(chartY + chartH - chartH * (p.getDouble(this.yhead) / yhi - ylo));
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
      (float)(chartX + chartW * (over.getDouble(this.xhead) / xhi - xlo)) - imgSize / 2,
      (float)(chartY + chartH - chartH * (over.getDouble(this.yhead) / yhi - ylo)) - imgSize / 2,
      imgSize,
      imgSize
    );
  }
}
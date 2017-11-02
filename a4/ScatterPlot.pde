final float imgSize = 70;
final float pointSize = 10;
final color pointColor = color(30, 144, 255, 150);

public class ScatterPlot extends Chart {
  private String xhead, yhead;
  
  public ScatterPlot(float x, float y, float w, float h, Controller ctrl, PokeTable tbl, String xhead, String yhead) {
    super(x, y, w, h, ctrl, tbl);
    this.xhead = xhead;
    this.yhead = yhead;
  }
  
  private ArrayList<Double> getColumn(String column) {
    ArrayList<Double> doubles = new ArrayList<Double>();
    for (Pokemon p : ps) doubles.add(p.getDouble(column));
    return doubles;
  }
  
  private int getNumGaps(double lo, double hi) {
    return (int)((hi - lo) / 80);
  }
  
  private boolean overPoint(float x, float y, float r) {
    return pow(mouseX - x, 2) + pow(mouseY - y, 2) <= pow(r, 2);
  }
  
  public void draw() {    
    ArrayList<Double> xcol = getColumn(xhead);
    ArrayList<Double> ycol = getColumn(yhead);
    double xmax = ListUtils.maxDouble(xcol);
    double ymax = ListUtils.maxDouble(ycol);
    
    float chartX = getX() + textAscent() + textDescent() + textWidth(String.valueOf(ymax)) + 15;
    float chartY = getY();
    float chartW = getX() + getWidth() - chartX;
    float chartH = getHeight() - (2 * (textAscent() + textDescent()) + 15);
    
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
    
    // x ticks
    stroke(0);
    fill(0);
    int xgaps = getNumGaps(0, chartW);
    for (int i = 0; i < xgaps + 1; i++) {
      String tickStr = String.format("%.2f", i * xmax / xgaps);
      float tickX = chartX + i * chartW / xgaps;
      line(tickX, chartY + chartH, tickX, chartY + chartH + 5);
      text(tickStr, tickX - textWidth(tickStr) / 2, chartY + chartH + 25);
    }
    
    // y ticks
    stroke(0);
    fill(0);
    int ygaps = getNumGaps(0, chartH);
    for (int i = 0; i < ygaps + 1; i++) {
      String tickStr = String.format("%.2f", ymax - i * ymax / ygaps);
      float tickY = chartY + i * chartH / ygaps;
      line(chartX, tickY, chartX - 5, tickY);
      text(tickStr, chartX - textWidth(tickStr) - 10, tickY + 5);
    }
    
    // points
    stroke(pointColor);
    fill(pointColor);
    Pokemon over = null;
    for (Pokemon p : ps) {
      float px = (float)(chartX + chartW * p.getDouble(this.xhead) / xmax);
      float py = (float)(chartY + chartH - chartH * p.getDouble(this.yhead) / ymax);
      if (overPoint(px, py, pointSize / 2)) {
        over = p;
      } else {
        ellipse(px, py, pointSize, pointSize);
      }
    }
    if (over != null) image(
      over.getImage(),
      (float)(chartX + chartW * over.getDouble(this.xhead) / xmax) - imgSize / 2,
      (float)(chartY + chartH - chartH * over.getDouble(this.yhead) / ymax) - imgSize / 2,
      imgSize,
      imgSize
    );
  }
}
public class Histogram extends Chart {
  private final color lColor = color(0, 191, 255);
  private final color rColor = color(220, 20, 60);
  
  private String lhead, rhead;
  private double lhi, rhi;
  private ArrayList<Bar> bars;
  
  public Histogram(float x, float y, float w, float h, Controller ctrl, PokeTable tbl, String lhead, String rhead) {
    super(x, y, w, h, ctrl, tbl);
    this.lhead = lhead;
    this.rhead = rhead;
    this.bars = new ArrayList<Bar>();
    reset();
  }
  
  private int getNumGaps(double lo, double hi) {
    return (int)(abs((float)(hi - lo)) / 70);
  }
  
  private float getChartX() {
    return getX();
  }
  
  private float getChartY() {
    return getY();
  }
  
  private float getChartWidth() {
    return getWidth();
  }
  
  private float getChartHeight() {
    return getHeight() - 15 - 2 * (textAscent() + textDescent());
  }
  
  private class Bar implements Tooltip {
    public Pokemon p;
    public float x, y, w, h;
    private String head;
    private color c;
    
    public Bar(Pokemon p, float x, float y, float w, float h, String hdr, color c) {
      this.p = p;
      this.x = x;
      this.y = y;
      this.w = w;
      this.h = h;
      this.head = hdr;
      this.c = c;
    }
    
    public void draw() {
      noStroke();
      fill(this.c, Histogram.this.controller.getHovered().contains(this.p.id) ? 255 : 150);
      rect(this.x, this.y, this.w, this.h);
    }
    
    public void drawTooltip() {
      String nameStr = "name: " + this.p.name;
      String headStr = head + ": " + this.p.getDouble(this.head);
      float ttW = max(textWidth(nameStr), textWidth(headStr)) + 15;
      float ttH = 2 * (textAscent() + textDescent()) + 10;
      fill(30, 200);
      rect(mouseX, mouseY - ttH - 5, ttW, ttH);
      fill(255);
      text(nameStr, mouseX + 5, mouseY - 2 * (textAscent() + textDescent()));
      text(headStr, mouseX + 5, mouseY - textAscent() - textDescent());
    }
    
    public boolean isOver() {
      return OverUtils.overRect(mouseX, mouseY, this.x, this.y, this.w, this.h);
    }
  }
  
  public void draw() {
    float chartX = getChartX(), chartY = getChartY(), chartW = getChartWidth(), chartH = getChartHeight();
    
    // axis lines
    stroke(0);
    line(chartX, chartY + chartH, chartX + chartW, chartY + chartH);
    line(chartX + chartW/2, chartY, chartX + chartW/2, chartY + chartH);
    
    // headers
    fill(0);
    text(this.lhead, chartX + chartW/4 - textWidth(this.lhead)/2, getY() + getHeight() - textAscent() - textDescent() + 10);
    text(this.rhead, chartX + 3*chartW/4 - textWidth(this.rhead)/2, getY() + getHeight() - textAscent() - textDescent() + 10);
    
    // l ticks
    stroke(0);
    fill(0);
    int lgaps = getNumGaps(0, chartW/2);
    for (int i = 1; i < lgaps + 1; i++) { // start at 1 to avoid 0
      String tickStr = String.format("%.2f", i * this.lhi / lgaps);
      float tickX = chartX + chartW/2 - i * (chartW/2) / lgaps;
      line(tickX, chartY + chartH, tickX, chartY + chartH + 5);
      text(tickStr, tickX - textWidth(tickStr)/2, chartY + chartH + 25);
    }
    
    // r ticks
    stroke(0);
    fill(0);
    int rgaps = getNumGaps(0, chartW/2);
    for (int i = 0; i < rgaps + 1; i++) {
      String tickStr = String.format("%.2f", i * this.rhi / rgaps);
      float tickX = chartX + chartW/2 + i * (chartW/2) / rgaps;
      line(tickX, chartY + chartH, tickX, chartY + chartH + 5);
      text(tickStr, tickX - textWidth(tickStr)/2, chartY + chartH + 25);
    }
    
    // bars
    for (Bar b : this.bars) b.draw();
  }
  
  private void makeBars() {
    this.bars.clear();
    float chartX = getChartX(), chartY = getChartY(), chartW = getChartWidth(), chartH = getChartHeight();
    ArrayList<Pokemon> ps = getRows(new String[]{this.lhead + ">=0", this.rhead + ">=0"}, this.rhead);
    float barH = chartH / ps.size();
    for (int i = 0; i < ps.size(); i++) {
      Pokemon p = ps.get(i);
      float lw = (chartW / 2) * (float)(max((float)p.getDouble(this.lhead), 0) / this.lhi);
      this.bars.add(new Bar(p, chartX + chartW/2 - lw, chartY + i * barH, lw, barH, this.lhead, this.lColor));
      float rw = (chartW / 2) * (float)(max((float)p.getDouble(this.rhead), 0) / this.rhi);
      this.bars.add(new Bar(p, chartX + chartW/2, chartY + i * barH, rw, barH, this.rhead, this.rColor));
    }
  }
  
  private void resetRanges() {
    this.lhi = ListUtils.maxDouble(getColumnDouble(this.lhead));
    this.rhi = ListUtils.maxDouble(getColumnDouble(this.rhead));
  }
  
  public void update() {
    makeBars();
  }
  
  public void reset() {
    resetRanges();
    makeBars();
  }
  
  private Bar onWhichBar() {
      for (Bar b : this.bars) if (b.isOver()) return b;
      return null;
  }
  
  public void onOver() {
    Bar over = onWhichBar();
    if (over != null) {
      this.controller.addHovered(over.p.id);
      tooltips.add(over);
    }
  }
  
  public void onClick() {
    if (mouseButton == LEFT) {
      Bar over = onWhichBar();
      if (over != null) this.controller.addFilter("id='" + over.p.id + "'");
    }
  }
}
public class RadarChartv2 extends Chart{
  private final int numRanges = 5;
  private final int maxRange = 255;
  
  private String[] columns;
  private ArrayList<Segment> segments;
  private PGraphics pg;
  private PShape totalShp;
  
  public RadarChartv2(float x, float y, float w, float h, Controller ctrl, PokeTable tbl, String[] columns) {
    super(x, y, w, h, ctrl, tbl);
    this.columns = columns.clone();
    this.segments = new ArrayList<Segment>();
    this.totalShp = null;
    reset();
  }
  
  private float getRadius() {
    return min(getWidth(), getHeight()) / 2 - 2 * (textAscent() + textDescent() + 5);
  }
  
  private PVector calcPoint(float a, float r) {
    return new PVector(getCenterX() + cos(a) * r, getCenterY() + sin(a) * r);
  }
  
  private class Segment implements Tooltip {
    private float x, y;
    private PShape shape;
    private color c;
    private PGraphics pg;
    public String column;
    public float val;
    
    public Segment(float x, float y, float la, float ma, float ra, float rstart, float rstop, color c, PGraphics pg, String column, float val) {
      this.x = x;
      this.y = y;
      this.shape = makeShape(la, ma, ra, rstart, rstop);
      this.c = c;
      this.pg = pg;
      this.column = column;
      this.val = val;
    }
    
    private PVector calcPoint(float a, float r) {
      return new PVector(this.x + cos(a) * r, this.y + sin(a) * r);
    }
    
    private PShape makeShape(float la, float ma, float ra, float rstart, float rstop) {
      PVector startL = calcPoint(la, rstart), startM = calcPoint(ma, rstart), startR = calcPoint(ra, rstart);
      PVector stopL = calcPoint(la, rstop), stopM = calcPoint(ma, rstop), stopR = calcPoint(ra, rstop);
      PVector v1 = PVector.lerp(startL, startM, 0.5), v3 = PVector.lerp(startM, startR, 0.5);
      PVector v4 = PVector.lerp(stopM, stopR, 0.5), v6 = PVector.lerp(stopL, stopM, 0.5);
      PShape shape = createShape(); 
      shape.beginShape();
      shape.vertex(v1.x, v1.y);
      shape.vertex(startM.x, startM.y);
      shape.vertex(v3.x, v3.y);
      shape.vertex(v4.x, v4.y);
      shape.vertex(stopM.x, stopM.y);
      shape.vertex(v6.x, v6.y);
      shape.endShape(CLOSE);
      return shape;
    }
    
    public void draw() {
      this.shape.setFill(isOver() ? color(139, 0, 0) : 120);
      shape(this.shape);
    }
    
    public void drawBuffer() {
      this.shape.setStroke(this.c);
      this.shape.setFill(this.c);
      this.pg.shape(this.shape);
    }
    
    public void drawTooltip() {
      String colStr = "stat: " + this.column;
      String rangeStr = "range: " + String.valueOf(this.val) + "-" + String.valueOf(this.val + RadarChartv2.this.maxRange / RadarChartv2.this.numRanges);
      float ttW = max(textWidth(colStr), textWidth(rangeStr)) + 15;
      float ttH = 2 * (textAscent() + textDescent()) + 10;
      noStroke();
      fill(25, 200);
      rect(mouseX, mouseY - ttH - 5, ttW, ttH);
      fill(255);
      text(colStr, mouseX + 5, mouseY - 2 * (textAscent() + textDescent()));
      text(rangeStr, mouseX + 5, mouseY - textAscent() - textDescent());
    }
    
    public boolean isOver() {
      return this.pg.get(mouseX, mouseY) == this.c;
    }
  }
  
  public void draw() {
    // segments
    this.pg.beginDraw();
    this.pg.background(255);
    for (Segment seg : this.segments) seg.drawBuffer();
    this.pg.endDraw();
    for (Segment seg : this.segments) seg.draw();
    
    // hexagons, line, labels
    float centerX = getCenterX(), centerY = getCenterY();
    float rad = getRadius() / this.numRanges;
    float offset = -TWO_PI / (2 * this.columns.length);
    
    for (int i = 0; i < this.columns.length; i++) {
      float next = offset + TWO_PI / this.columns.length; 
      
      //lines
      PVector p1 = calcPoint(offset, getRadius()), p2 = calcPoint(next, getRadius());
      stroke(230, 25);
      line(centerX, centerY, PVector.lerp(p1, p2, 0.5).x, PVector.lerp(p1, p2, 0.5).y);
      stroke(255);
      line(centerX, centerY, p1.x, p1.y);
      
      // text
      PVector textp = calcPoint(offset, getRadius() + 10);
      String col = this.columns[i];
      if (textp.x < getCenterX()) {
        textp.x -= textWidth(col);
      } else if (textp.x == getCenterX()) {
        textp.x -= textWidth(col) / 2;
      }
      textp.y += (textAscent() + textDescent()) * 0.2;
      fill(0);
      text(col, textp.x, textp.y);
      
      // hexagon
      stroke(255);
      for (int j = 0; j < this.numRanges; j++) {
        p1 = calcPoint(offset, j * rad);
        p2 = calcPoint(next, j * rad);
        line(p1.x, p1.y, p2.x, p2.y);
      }
      
      offset = next;
    }
    
    // shape
    shape(this.totalShp);
    Set<Integer> hovered = this.controller.getHovered();
    if (!isOver() && hovered.size() > 0) {
      ArrayList<Pokemon> ps = new ArrayList<Pokemon>();
      for (Pokemon p : this.controller)
        if (hovered.contains(p.id)) ps.add(p);
      PShape hoverShp = makeColShape(ps, color(0, 191, 255));
      shape(hoverShp);
    }
  }
  
  private PShape makeColShape(Iterable<Pokemon> ps, color c) {
    // create vals
    HashMap<String, Float> colVals = new HashMap<String, Float>();
    for (String col : this.columns) colVals.put(col, 0.0); // clear
    int size = 0;
    for (Pokemon p : ps) size++;
    for (Pokemon p : ps) {
      for (String col : this.columns) colVals.put(col, colVals.get(col) + (float)p.getInt(col) / size);
    }
    
    // create shape
    PShape shape = createShape();
    float offset = -TWO_PI / (2 * this.columns.length);
    shape.beginShape();
    shape.stroke(c, 200);
    shape.fill(c, 50);
    for (String col : this.columns) {
      PVector p = calcPoint(offset, getRadius() * colVals.get(col) / this.maxRange);
      shape.vertex(p.x, p.y);
      offset += TWO_PI / this.columns.length;
    }
    shape.endShape(CLOSE);
    return shape;
  }
  
  private void makeSegments() {
    this.segments.clear();
    this.pg = createGraphics(width, height);
    float left = -TWO_PI / (2 * this.columns.length);
    for (int i = 0; i < this.columns.length; i++) {
      float mid = left + TWO_PI / this.columns.length;
      float right = left + 2 * TWO_PI / this.columns.length;
      for (int j = 0; j < this.numRanges; j++) {
        color c = color(i * (255 / this.columns.length), j * (255 / this.numRanges), 120);
        this.segments.add(new Segment(
          getCenterX(), getCenterY(), 
          left, mid, right, 
          j * getRadius() / this.numRanges, (j+1) * getRadius() / this.numRanges,
          c, this.pg,
          this.columns[(i+1) % this.columns.length], j * this.maxRange / this.numRanges
        ));
      }
      left += TWO_PI / this.columns.length;
    }
  }
  
  public void update() {
    this.totalShp = makeColShape(this.controller, color(255, 0, 0));
    makeSegments();
  }
  
  public void reset() {
    this.totalShp = makeColShape(this.controller, color(255, 0, 0));
    makeSegments();
  }
  
  private Segment whichOver() {
    this.pg.beginDraw();
    this.pg.background(255);
    for (Segment seg : this.segments) {
      seg.drawBuffer();
      if (seg.isOver()) return seg;
    }
    this.pg.endDraw();
    return null;
  }
  
  public boolean isOver() {
    return OverUtils.overCircle(mouseX, mouseY, getCenterX(), getCenterY(), getRadius());
  }
  
  public void onOver() {
    Segment over = whichOver();
    if (over != null) {
      for (Pokemon p : this.controller) {
        if (p.getInt(over.column) >= over.val && 
            p.getInt(over.column) <= over.val + this.maxRange / this.numRanges)
          this.controller.addHovered(p.id);
      }
      tooltips.add(over);
    }
  }
  
  public void onClick() {
    Segment over = whichOver();
    if (over != null) {
      this.controller.addFilter(over.column + ">=" + String.valueOf((int)over.val));
      this.controller.addFilter(over.column + "<=" + String.valueOf((int)(over.val + this.maxRange / this.numRanges)));
    }
  }
}
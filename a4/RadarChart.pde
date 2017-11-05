static final int NUM_INTERVALS = 5;
static final int NUM_POINTS = 6;

public class RadarChart extends Chart {
  private ArrayList<PVector> vertices;
  private ArrayList<Slice> slices;
  private float radius;
  private ArrayList<PShape> polygons;
  private String[] headers;
  private float[] maxes;
  private float[] averages;
  private PGraphics pickbuffer;
  private PShape data;

  public RadarChart(float x, float y, float w, float h, Controller ctrl, PokeTable tbl, String[] headers) {
    super(x, y, w, h, ctrl, tbl);

    this.headers = headers;
    this.maxes = new float[headers.length];
    this.averages = new float[headers.length];
    this.radius = min(w, h) / 2;
    this.vertices = new ArrayList<PVector>();
    this.polygons = new ArrayList<PShape>();
    this.slices = new ArrayList<Slice>();
    this.pickbuffer = createGraphics(width, height);

    // Get vertices for each column
    for (float a = 0; a < TWO_PI; a += TWO_PI/NUM_POINTS) {
      float sx = getCenterX() + cos(a) * radius;
      float sy = getCenterY() + sin(a) * radius;
      vertices.add(new PVector(sx, sy));
      vertex(sx, sy);
    }
    
    // Create embellishment polygons
    float intervalSize = radius / NUM_INTERVALS;
    float r = radius;
    for (int i = 0; i < NUM_INTERVALS; i++) {
      polygons.add(polygon(getCenterX(), getCenterY(), r, NUM_POINTS));
      r -= intervalSize;
    }

    // Make slices for invisible pie chart
    float degree = 2*PI / NUM_POINTS;
    float start = degree / 2;
    for (int i = 0; i < NUM_POINTS; i++) {
      slices.add(new Slice(getCenterX(), getCenterY(), radius*2, start, start+degree));
      start += degree;
    }
    
    setMaxAndAvg();
    createDataShape();
  }

  PShape polygon(float x, float y, float radius, int npoints) {
    fill(255);
    stroke(0);
    strokeWeight(1);
    
    PShape polygon = createShape();
    float angle = TWO_PI / npoints;
    polygon.beginShape();
    for (float a = 0; a < TWO_PI; a += angle) {
      float sx = x + cos(a) * radius;
      float sy = y + sin(a) * radius;
      polygon.vertex(sx, sy);
    }
    polygon.endShape(CLOSE);
    return polygon;
  }

  void polygon(float x, float y, float radius, int npoints, PGraphics pg) {
    float angle = TWO_PI / npoints;
    pg.beginShape();
    for (float a = 0; a < TWO_PI; a += angle) {
      float sx = x + cos(a) * radius;
      float sy = y + sin(a) * radius;
      pg.vertex(sx, sy);
    }
    pg.endShape(CLOSE);
  }

  void drawEmbellishments() {
    fill(0);  
    ellipseMode(CENTER);
    
    for (PShape shape : polygons) shape(shape);   // draw polygons    
    
    ellipse(getCenterX(), getCenterY(), 2, 2);    // center dot

    for (int i = 0; i < NUM_POINTS; i++) {        // labels
      text(headers[i], vertices.get(i).x + 10, vertices.get(i).y + 10);
      text(maxes[i], vertices.get(i).x, vertices.get(i).y);
    }

    for (int i = 1; i <= NUM_POINTS; i++) {       // draw lines from dot to midpoint of each side
      float midpointX = lerp(vertices.get(i).x, vertices.get(i-1).x, .5);
      float midpointY = lerp(vertices.get(i).y, vertices.get(i-1).y, .5);
      line(getCenterX(), getCenterY(), midpointX, midpointY);
    }
  }

  void drawPickBuffer() {
    pickbuffer.beginDraw();
    pickbuffer.background(255);

    float intervalSize = radius / NUM_INTERVALS;
    float r = radius;
    for (int i = 0; i < NUM_INTERVALS; i++) {
      pickbuffer.fill(i);
      pickbuffer.stroke(i);
      polygon(getCenterX(), getCenterY(), r, NUM_POINTS, pickbuffer);
      r -= intervalSize;
    }
    
    pickbuffer.fill(255);
    pickbuffer.shape(data);
    pickbuffer.endDraw();
  }

  void onClick() {
    int intervalIndex = -1, sliceIndex = -1;
    float rangeMax;

    for (int i = 0; i < NUM_INTERVALS; i++) {
      if (pickbuffer.get(mouseX, mouseY) == color(i)) {
        intervalIndex = i;
      }
    }

    for (int i = 0; i < NUM_POINTS; i++) {
      if (slices.get(i).isOver()) {
        sliceIndex = (i + 1) % NUM_POINTS;
      }
    }

    rangeMax = (NUM_INTERVALS - intervalIndex) / float(NUM_INTERVALS) * maxes[sliceIndex];
    setFilter(new String[]{ headers[sliceIndex] }, new float[]{ rangeMax });
  }

  void setFilter(String[] columns, float[] rangeMaxes) {
    String[] rangeFilters = new String[columns.length];

    for (int i = 0; i < columns.length; i++) {
      rangeFilters[i] = columns[i] + "<=" + String.valueOf(rangeMaxes[i]);
    }
    
    this.controller.addFilters(rangeFilters);
  }

  void onHover() {
    for (int i = 0; i < NUM_INTERVALS; i++) {
      if (pickbuffer.get(mouseX, mouseY) == color(i)) {
        polygons.get(i).setFill(#deeff5);
      } else {
        polygons.get(i).setFill(255);
      }
    }

    for (int i = 0; i < NUM_POINTS; i++) {
      if (slices.get(i).isOver()) {
        slices.get(i).arc.setFill(0);
      } else {
        slices.get(i).arc.setFill(255);
      }
    }
  }

  void drawData() {
    shape(data);
  }

  void draw() {
    stroke(#545454);
    strokeWeight(1);
    fill(255);

    drawEmbellishments();
    drawData();
    drawPickBuffer();
  }

  void reset() {
    setFilter(headers, maxes);
  }

  void update() {
    setMaxAndAvg();
  }
  
  void createDataShape() {
    fill(255, 154, 154, 75);
    strokeWeight(2);
    stroke(#F44336);
    
    data = createShape();
    data.beginShape();
    for (int i = 0; i < maxes.length; i++) {
      float ratio = averages[i] / maxes[i];    
      float pointX = lerp(getCenterX(), vertices.get(i).x, ratio);
      float pointY = lerp(getCenterY(), vertices.get(i).y, ratio);
      data.vertex(pointX, pointY);
    }
    data.endShape(CLOSE);
  }

  void setMaxAndAvg() {
    for (int i = 0; i < headers.length; i++) {
      maxes[i] = (float) ListUtils.maxInt(getColumnInt(headers[i]));
      averages[i] = (float) ListUtils.averageInt(getColumnInt(headers[i]));
    }
    createDataShape();
  }

  private class Slice {
    private float x, y, r, start, stop;
    PShape arc;  // TODO make own draw method

    Slice(float x, float y, float r, float start, float stop) {
      this.x = x;
      this.y = y;
      this.r = r;
      this.start = start;
      this.stop = stop;

      arc = createShape(ARC, getCenterX(), getCenterY(), radius*2, radius*2, start, stop, PIE);
    }

    boolean isOver() {
      boolean inCircle = pow(mouseX - x, 2) + pow(mouseY - y, 2) <= pow(r, 2);
      float mouseRad = atan2(mouseY - y, mouseX - x);
      mouseRad += mouseRad > 0 ? 0 : 2 * PI;

      if (this.stop > 2*PI) {
        float start = 0;
        float stop = this.stop - 2*PI;
        return (inCircle && mouseRad > start && mouseRad < stop) || inCircle && mouseRad > this.start && mouseRad < this.stop;
      }

      return inCircle && mouseRad > start && mouseRad < stop;
    }
  }
}
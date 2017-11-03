static final int NUM_INTERVALS = 5;
static final int NUM_POINTS = 6;

public class RadarChart extends Chart {
  private ArrayList<PVector> vertices;
  private ArrayList<PShape> slices;
  private float radius;
  private int[] layerIds;
  private ArrayList<PShape> polygons;
  private String[] headers;
  private float[] maxes;
  private float[] averages;
  private PGraphics pickbuffer;
  
  public RadarChart(float x, float y, float w, float h, Controller ctrl, PokeTable tbl, String[] headers) {
    super(x, y, w, h, ctrl, tbl);
    
    this.headers = headers;
    this.maxes = new float[headers.length];
    this.averages = new float[headers.length];
    this.layerIds = new int[NUM_INTERVALS];
    radius = min(w, h) / 2;
    vertices = new ArrayList<PVector>();
    polygons = new ArrayList<PShape>();
    slices = new ArrayList<PShape>();
    pickbuffer = createGraphics(width, height);
    
    // Get vertices for each column
    for (float a = 0; a < TWO_PI; a += TWO_PI/NUM_POINTS) {
      float sx = getCenterX() + cos(a) * radius;
      float sy = getCenterY() + sin(a) * radius;
      vertices.add(new PVector(sx, sy));
      vertex(sx, sy);
    }
    
    // Get max and averages for each column
    for (int i = 0; i < headers.length; i++) {
       maxes[i] = (float) ListUtils.maxInt(getColumn(headers[i]));
       averages[i] = (float) ListUtils.averageInt(getColumn(headers[i]));
    }
    
    // Create embellishment polygons
    float intervalSize = radius / NUM_INTERVALS;
    float r = radius;
    for (int i = 0; i < NUM_INTERVALS; i++) {
      polygons.add(polygon(getCenterX(), getCenterY(), r, NUM_POINTS));
      r -= intervalSize;
    }
    
    
  }
  
  private ArrayList<Integer> getColumn(String column) {
    ArrayList<Integer> ints = new ArrayList<Integer>();
    for (Pokemon p : ps) ints.add(p.getInt(column));
    return ints;
  }
  
  PShape polygon(float x, float y, float radius, int npoints) {
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
    float cX = getCenterX();
    float cY = getCenterY();    
    
    // draw polygons    
    //for (PShape shape : polygons) {
    //  shape(shape);
    //}
    
    // center dot
    fill(0);
    ellipseMode(CENTER);
    ellipse(cX, cY, 2, 2);
    
    // TODO: remove this, just for dev purpose
    noFill();
    ellipse(cX, cY, radius*2, radius*2);
    
    // Make slices for invisible pie chart
    float start = 0;
    float degree = 2*PI / NUM_POINTS;
    for (int i = 0; i < NUM_POINTS; i++) {
      PShape hiddenArc = createShape(ARC, cX, cY, radius*2, radius*2, start, start+degree, PIE);
      start += degree;
      slices.add(hiddenArc);
      shape(hiddenArc);  
    }
    
    
    
    
    
    // labels
    for (int i = 0; i < headers.length; i++) {
      text(headers[i], vertices.get(i).x + 10, vertices.get(i).y + 10);
    }
    
    // draw lines from dot to midpoint of each side
    for (int i = 1; i <= NUM_POINTS; i++) {
       float midpointX = lerp(vertices.get(i).x, vertices.get(i-1).x, .5);
       float midpointY = lerp(vertices.get(i).y, vertices.get(i-1).y, .5);
       
       line(cX, cY, midpointX, midpointY);
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
    
    pickbuffer.endDraw();
  }
  
  void onClick() {
    for (int i = 0; i < NUM_INTERVALS; i++) {
      if (pickbuffer.get(mouseX, mouseY) == color(i)) {
        println(i, " was clicked"); 
      }
    }
  }
  
  void onHover() {
    for (int i = 0; i < NUM_INTERVALS; i++) {
      if (pickbuffer.get(mouseX, mouseY) == color(i)) {
        polygons.get(i).setFill(#deeff5);
      } else {
        polygons.get(i).setFill(255);
      }
      
      if (overSlice(getCenterX(), getCenterY(), radius, 0, 1.57)) {
         slices.get(i).setFill(0);
      }
    }
  }
  
  // todo for dev purposes, delete later
  boolean overSlice(float x, float y, float r, float start, float stop) {
    boolean inCircle = pow(mouseX - x, 2) + pow(mouseY - y, 2) <= pow(r, 2);
    float mouseRad = atan2(mouseY - y, mouseX - x);
    mouseRad += mouseRad > 0 ? 0 : 2 * PI;
    return inCircle && mouseRad > start && mouseRad < stop;
  }
 
  void drawData() {
    fill(255, 154, 154, 75);
    strokeWeight(2);
    stroke(#F44336);
    
    // Draw polygons
    PShape polygon = createShape();
    polygon.beginShape();
    for (int i = 0; i < maxes.length; i++) {
      float ratio = averages[i] / maxes[i];    
      float pointX = lerp(getCenterX(), vertices.get(i).x, ratio);
      float pointY = lerp(getCenterY(), vertices.get(i).y, ratio);
      polygon.vertex(pointX, pointY);
      
    }
    polygon.endShape(CLOSE);
    shape(polygon);

  }
  
  void draw() {
    stroke(#545454);
    strokeWeight(1);
    fill(255);
    
    drawPickBuffer();
    drawEmbellishments();
    drawData();
  }
}
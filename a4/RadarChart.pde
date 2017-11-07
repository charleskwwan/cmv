static final int NUM_INTERVALS = 5;
static final int NUM_POINTS = 6;
static final int MAX_VALUE = 255;

public class RadarChart extends Chart {
  private ArrayList<PVector> vertices;
  private ArrayList<Slice> slices;
  private PShape[][] sections;
  private float radius;
  private String[] headers;
  private float[] averages;
  private PGraphics pickbuffer;
  private DataShape data;

  public RadarChart(float x, float y, float w, float h, Controller ctrl, PokeTable tbl, String[] headers) {
    super(x, y, w, h, ctrl, tbl);
    this.headers = headers;
    this.averages = new float[headers.length];
    this.radius = min(w, h) / 2;

    createShapes();
    setAvg();
    data = new DataShape(averages);
  }
 
  void createShapes() {
    this.vertices = new ArrayList<PVector>();
    this.slices = new ArrayList<Slice>();
    this.pickbuffer = createGraphics(width, height);
    this.sections = new PShape[NUM_INTERVALS][NUM_POINTS];
    
    pickbuffer.beginDraw();        // need to load pickbuffer to prevent NPE
    pickbuffer.endDraw();
    
    // Get vertices for each column
    for (float a = 0; a < TWO_PI; a += TWO_PI/NUM_POINTS) {
      float sx = getCenterX() + cos(a) * radius;
      float sy = getCenterY() + sin(a) * radius;
      vertices.add(new PVector(sx, sy));
      vertex(sx, sy);
    }
    
    // Create embellishment sections (of polygons)
    fill(255);
    stroke(0);
    for (int i = 0; i < NUM_INTERVALS; i++) {
      for (int j = 0; j < NUM_POINTS; j++) {
        PShape section = createShape();
        int prevIndex = j == 0 ? NUM_POINTS - 1 : j - 1;
        float nextMidpointX = lerp(vertices.get(j+1).x, vertices.get(j).x, .5);
        float nextMidpointY = lerp(vertices.get(j+1).y, vertices.get(j).y, .5);
        float prevMidpointX = lerp(vertices.get(j).x, vertices.get(prevIndex).x, .5);
        float prevMidpointY = lerp(vertices.get(j).y, vertices.get(prevIndex).y, .5);
        float intervalRatio = (NUM_INTERVALS - i) / float(NUM_INTERVALS);
        
        section.beginShape();
        section.vertex(getCenterX(), getCenterY());
        section.vertex(
          lerp(getCenterX(), nextMidpointX, intervalRatio),
          lerp(getCenterY(), nextMidpointY, intervalRatio)
        );
        section.vertex(
          lerp(getCenterX(), vertices.get(j).x, intervalRatio),
          lerp(getCenterY(), vertices.get(j).y, intervalRatio)
        );
        section.vertex(
          lerp(getCenterX(), prevMidpointX, intervalRatio),
          lerp(getCenterY(), prevMidpointY, intervalRatio)
        );
        section.vertex(getCenterX(), getCenterY());
        section.endShape(CLOSE);
        
        sections[i][j] = section;
      }
    }

    // Make slices for invisible pie chart
    float degree = 2*PI / NUM_POINTS;
    float start = degree / 2;
    for (int i = 0; i < NUM_POINTS; i++) {
      slices.add(new Slice(getCenterX(), getCenterY(), radius*2, start, start+degree));
      start += degree;
    } 
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
    
    for(int i = 0; i < NUM_INTERVALS; i++) {      // draw sections 
     for(int j =0; j < NUM_POINTS; j++) {
       shape(sections[i][j]); 
     }
    }
    
    ellipse(getCenterX(), getCenterY(), 2, 2);    // center dot

    for (int i = 0; i < NUM_POINTS; i++) {
      // column labels
      float xOffset = 7, yOffset = 5;
      String toDisplay = headers[i];
      if (vertices.get(i).x < getCenterX()) xOffset = -(textWidth(toDisplay));
      if (vertices.get(i).y < getCenterY()) yOffset = -yOffset;
      text(toDisplay, vertices.get(i).x + xOffset, vertices.get(i).y + yOffset);
    }
    
    // draw value labels on upper vertical line
    textSize(10);
    float firstMidpointY = lerp(vertices.get(3).y, vertices.get(4).y, 1);
    for (int i = 1; i <= NUM_INTERVALS; i++) {
      float labelY = lerp(getCenterY(), firstMidpointY, i / float(NUM_INTERVALS));
      text(String.valueOf(float(MAX_VALUE) / NUM_INTERVALS * i), getCenterX() + 1, labelY - 1);
    }
    textSize(12);
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
    int intervalIndex = -1, sliceIndex = -1;
    float rangeMax;

    for (int i = 0; i < NUM_INTERVALS; i++) {
      
      if (pickbuffer.get(mouseX, mouseY) == color(i)) intervalIndex = i;
    }

    for (int i = 0; i < NUM_POINTS; i++) {
      if (slices.get(i).isOver()) sliceIndex = (i + 1) % NUM_POINTS;
    }
    if (intervalIndex == -1 || sliceIndex == -1) return;
    rangeMax = (NUM_INTERVALS - intervalIndex) / float(NUM_INTERVALS) * MAX_VALUE;
    setFilter(new String[]{ headers[sliceIndex] }, new float[]{ rangeMax });
  }

  void setFilter(String[] columns, float[] rangeMaxes) {
    String[] rangeFilters = new String[columns.length];

    for (int i = 0; i < columns.length; i++) {
      rangeFilters[i] = columns[i] + "<=" + String.valueOf(rangeMaxes[i]);
    }
    
    this.controller.addFilters(rangeFilters);
  }

  void onOver() {
    int intervalIndex = -1, sliceIndex = -1;
    float rangeMax;
    
    for (int i = 0; i < NUM_INTERVALS; i++) {
      for (int j = 0; j < NUM_POINTS; j++) {
        int currSliceIndex = (j + 1) % NUM_POINTS;
        if (pickbuffer.get(mouseX, mouseY) == color(i) && slices.get(j).isOver()) {
          intervalIndex = i;
          sliceIndex = currSliceIndex;
          sections[i][currSliceIndex].setFill(#deeff5);
        } else {
          sections[i][currSliceIndex].setFill(#f6f6f6);
        }
      }
    }

    if (intervalIndex == -1 || sliceIndex == -1) return;

    rangeMax = (NUM_INTERVALS - intervalIndex) / float(NUM_INTERVALS) * MAX_VALUE;
    for (Pokemon p : this.controller) {
      if (p.getInt(headers[sliceIndex]) < rangeMax) {
        this.controller.addHovered(p.id);
      }
    }
  }

  void drawData() {
    data.draw();
    
    // Draw hovered averages shape
    fill(color(#006565), 75);
    strokeWeight(2);
    stroke(#0BBCC9);
    
    float[] hoveredAverages = new float[NUM_POINTS];
    for (int i = 0; i < NUM_POINTS; i++) {
      hoveredAverages[i] = (float) ListUtils.averageInt(getColumnIntOfHovered(headers[i]));  
    }
    PShape tempShape = createShape();
    tempShape.beginShape();
    for (int i = 0; i < NUM_POINTS; i++) {
      float ratio = hoveredAverages[i] / MAX_VALUE;    
      float pointX = lerp(getCenterX(), vertices.get(i).x, ratio);
      float pointY = lerp(getCenterY(), vertices.get(i).y, ratio);
      tempShape.vertex(pointX, pointY);
    }
    tempShape.endShape(CLOSE);
    shape(tempShape);
  }

  void draw() {
    stroke(#545454);
    strokeWeight(1);
    
    drawEmbellishments();
    drawData();
    drawPickBuffer();
  }

  void reset() {
    setFilter(headers, ListUtils.filled(NUM_POINTS, MAX_VALUE));
    createShapes();
    setAvg();
  }

  void update() {
    createShapes();
    setAvg();
  }

  void setAvg() {
    for (int i = 0; i < headers.length; i++) {
      averages[i] = (float) ListUtils.averageInt(getColumnInt(headers[i]));
    }
    data = new DataShape(averages);
  }

  private class Slice {
    private float x, y, r, start, stop;

    Slice(float x, float y, float r, float start, float stop) {
      this.x = x;
      this.y = y;
      this.r = r;
      this.start = start;
      this.stop = stop;
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
  
  private class DataShape {
     private PShape shape;
     
     DataShape(float[] averages) {
      fill(255, 154, 154, 75);
      strokeWeight(2);
      stroke(#F44336);
      
      shape = createShape();
      shape.beginShape();
      for (int i = 0; i < NUM_POINTS; i++) {
        float ratio = averages[i] / MAX_VALUE;    
        float pointX = lerp(getCenterX(), vertices.get(i).x, ratio);
        float pointY = lerp(getCenterY(), vertices.get(i).y, ratio);
        shape.vertex(pointX, pointY);
      }
      shape.endShape(CLOSE); 
     }
     
     void draw() {
       shape(shape); 
     }
  }
}
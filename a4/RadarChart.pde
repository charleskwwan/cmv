public class RadarChart extends Chart {
  private int numIntervals, numPoints, maxValue;
  private ArrayList<PVector> vertices;
  private ArrayList<Slice> slices;
  private Section[][] sections;
  private float radius;
  private String[] headers;
  private float[] averages;
  private PGraphics pickbuffer;
  private DataShape data;

  public RadarChart(float x, float y, float w, float h, Controller ctrl, PokeTable tbl, String[] headers, int numIntervals, int numPoints, int maxValue) {
    super(x, y, w, h, ctrl, tbl);
    this.headers = headers;
    this.averages = new float[headers.length];
    this.radius = min(w, h) / 2;
    this.numIntervals = numIntervals;
    this.numPoints = numPoints;
    this.maxValue = maxValue;

    createShapes();
    data = new DataShape(averages);
  }
  
  void draw() {
    drawEmbellishments();
    drawData();
    drawPickBuffer();
  }
 
  void createShapes() {
    this.vertices = new ArrayList<PVector>();
    this.slices = new ArrayList<Slice>();
    this.pickbuffer = createGraphics(width, height);
    this.sections = new Section[numIntervals][numPoints];
    
    pickbuffer.beginDraw();        // need to load pickbuffer to prevent NPE
    pickbuffer.endDraw();
    
    // Get vertices for each column
    for (float a = 0; a < TWO_PI; a += TWO_PI/numPoints) {
      float sx = getCenterX() + cos(a) * radius;
      float sy = getCenterY() + sin(a) * radius;
      vertices.add(new PVector(sx, sy));
      vertex(sx, sy);
    }
    
    // Create embellishment sections (of polygons)
    for (int i = 0; i < numIntervals; i++) {
      for (int j = 0; j < numPoints; j++) {
        int prevIndex = j == 0 ? numPoints - 1 : j - 1;
        int nextIndex = j == numPoints - 1 ? 0 : j + 1;
        float nextMidpointX = lerp(vertices.get(nextIndex).x, vertices.get(j).x, .5);
        float nextMidpointY = lerp(vertices.get(nextIndex).y, vertices.get(j).y, .5);
        float prevMidpointX = lerp(vertices.get(j).x, vertices.get(prevIndex).x, .5);
        float prevMidpointY = lerp(vertices.get(j).y, vertices.get(prevIndex).y, .5);
        float intervalRatio = (numIntervals - i) / float(numIntervals);
       
        sections[i][j] = new Section(new PVector[]{ 
          new PVector(getCenterX(), getCenterY()),
          new PVector(lerp(getCenterX(), nextMidpointX, intervalRatio), lerp(getCenterY(), nextMidpointY, intervalRatio)),
          new PVector(lerp(getCenterX(), vertices.get(j).x, intervalRatio), lerp(getCenterY(), vertices.get(j).y, intervalRatio)),
          new PVector(lerp(getCenterX(), prevMidpointX, intervalRatio), lerp(getCenterY(), prevMidpointY, intervalRatio))
        }, intervalRatio * maxValue, headers[j], this.controller.hovered.size());
      }
    }

    // Make slices for invisible pie chart
    float degree = 2*PI / numPoints;
    float start = degree / 2;
    for (int i = 0; i < numPoints; i++) {
      slices.add(new Slice(getCenterX(), getCenterY(), radius*2, start, start+degree));
      start += degree;
      
      averages[i] = (float) ListUtils.averageInt(getColumnInt(headers[i]));  // Set avgs
    } 
    
    data = new DataShape(averages);
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
    
    for(int i = 0; i < numIntervals; i++) {      // draw sections 
     for(int j =0; j < numPoints; j++) {
       sections[i][j].draw(); 
     }
    }

    // column labels
    for (int i = 0; i < numPoints; i++) {
      float xOffset = 7, yOffset = 5;
      String toDisplay = headers[i];
      if (vertices.get(i).x < getCenterX()) xOffset = -(textWidth(toDisplay));
      if (vertices.get(i).y < getCenterY()) yOffset = -yOffset;
      text(toDisplay, vertices.get(i).x + xOffset, vertices.get(i).y + yOffset);
    }
    
    // draw value labels on upper vertical line
    textSize(10);
    float firstMidpointY = lerp(vertices.get(3).y, vertices.get(4).y, 1);
    for (int i = 1; i <= numIntervals; i++) {
      float labelY = lerp(getCenterY(), firstMidpointY, i / float(numIntervals));
      text(String.valueOf(float(maxValue) / numIntervals * i), getCenterX() + 1, labelY - 1);
    }
    textSize(12);
  }

  void drawPickBuffer() {
    pickbuffer.beginDraw();
    pickbuffer.background(255);

    float intervalSize = radius / numIntervals;
    float r = radius;
    for (int i = 0; i < numIntervals; i++) {
      pickbuffer.fill(i);
      pickbuffer.stroke(i);
      polygon(getCenterX(), getCenterY(), r, numPoints, pickbuffer);
      r -= intervalSize;
    }
    
    pickbuffer.endDraw();
  }

  void onClick() {
    int intervalIndex = -1, sliceIndex = -1;

    for (int i = 0; i < numIntervals; i++) 
      if (pickbuffer.get(mouseX, mouseY) == color(i)) intervalIndex = i;

    for (int i = 0; i < numPoints; i++) 
      if (slices.get(i).isOver()) sliceIndex = (i + 1) % numPoints;
    
    if (intervalIndex == -1 || sliceIndex == -1) return;
  
    setFilter(
      new String[]{ headers[sliceIndex] }, 
      new float[]{ (numIntervals - intervalIndex) / float(numIntervals) * maxValue });
  }

  void setFilter(String[] columns, float[] rangeMaxes) {
    String[] rangeFilters = new String[columns.length];

    for (int i = 0; i < columns.length; i++) 
      rangeFilters[i] = columns[i] + "<=" + String.valueOf(rangeMaxes[i]);
    
    this.controller.addFilters(rangeFilters);
  }

  void onOver() {
    int intervalIndex = -1, sliceIndex = -1;
    float rangeMax;
    Section hovered = null;
    
    for (int i = 0; i < numIntervals; i++) {
      for (int j = 0; j < numPoints; j++) {
        int currSliceIndex = (j + 1) % numPoints;
        if (pickbuffer.get(mouseX, mouseY) == color(i) && slices.get(j).isOver()) {
          intervalIndex = i;
          sliceIndex = currSliceIndex;
          hovered = sections[i][currSliceIndex];
          hovered.setFill(#deeff5);
        } else {
          sections[i][currSliceIndex].setFill(#f6f6f6);
        }
      }
    }

    if (intervalIndex == -1 || sliceIndex == -1) return;

    rangeMax = (numIntervals - intervalIndex) / float(numIntervals) * maxValue;
    for (Pokemon p : this.controller) {
      if (p.getInt(headers[sliceIndex]) < rangeMax) {
        this.controller.addHovered(p.id);
        if (hovered != null) {
          hovered.setCount(this.controller.hovered.size());
          tooltips.add(hovered);
        }
      }
    }
    
    
  }

  void drawData() {
    data.draw();
    
    fill(color(#006565), 75);
    strokeWeight(2);
    stroke(#0BBCC9);
    
    // draw hovered averages shape
    float[] hoveredAverages = new float[numPoints];
    for (int i = 0; i < numPoints; i++) {
      hoveredAverages[i] = (float) ListUtils.averageInt(getColumnIntOfHovered(headers[i]));  
    }
    beginShape();
    for (int i = 0; i < numPoints; i++) {
      float ratio = hoveredAverages[i] / maxValue;    
      float pointX = lerp(getCenterX(), vertices.get(i).x, ratio);
      float pointY = lerp(getCenterY(), vertices.get(i).y, ratio);
      vertex(pointX, pointY);
    }
    endShape(CLOSE);
  }

  void reset() {
    setFilter(headers, ListUtils.filled(numPoints, maxValue));
    createShapes();
  }

  void update() { createShapes(); }

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
      for (int i = 0; i < numPoints; i++) {
        float ratio = averages[i] / maxValue;    
        float pointX = lerp(getCenterX(), vertices.get(i).x, ratio);
        float pointY = lerp(getCenterY(), vertices.get(i).y, ratio);
        shape.vertex(pointX, pointY);
      }
      shape.endShape(CLOSE); 
     }
     
     void draw() { shape(shape); }
  }
  
  private class Section implements Tooltip {
    private PShape shape;
    private float max;
    private String header;
    private int count;
    
    Section(PVector[] vertices, float max, String header, int count) {
      fill(255);
      stroke(0);
      strokeWeight(1);
      
      shape = createShape();
      shape.beginShape();
      for (int i = 0; i < vertices.length; i++) {
        shape.vertex(vertices[i].x, vertices[i].y); 
      }
      
      shape.endShape(CLOSE);
        
      this.max = max;
      this.header = header;
      this.count = 0;
    }
    
    void draw() { shape(shape); }
    
    void setFill(color c) { shape.setFill(c); }
    
    void setCount(int count) {
      this.count = count;
    }
    
    void drawTooltip() {
      String headerStr = "";
      String rangeStr = "range: 0-" + (int) this.max;
      String countStr = "count: " + String.valueOf(count);
      float ttW = max(textWidth(headerStr), textWidth(rangeStr), textWidth(countStr)) + 15;
      float ttH = 3 * (textAscent() + textDescent()) + 10;
      fill(30, 200);
      rect(mouseX, mouseY - ttH - 5, ttW, ttH);
      fill(255);
      text(this.header, mouseX + 5, mouseY - (textAscent() + textDescent()));
      text(rangeStr, mouseX + 5, mouseY - 2 * (textAscent() + textDescent()));
      text(countStr, mouseX + 5, mouseY - 3 * (textAscent() + textDescent()));
    }
  }
}
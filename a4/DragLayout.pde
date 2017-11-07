public class DragLayout extends ViewPort {
  private final float splitProp = 0.6;
  
  private ArrayList<Chart> rest;
  private Chart main;
  private Integer selected;
  
  public DragLayout(float x, float y, float w, float h, Chart main) {
    super(x, y, w, h);
    this.rest = new ArrayList<Chart>();
    this.main = main;   
    this.selected = null; // -1 is main, null means no selected
  }
  
  public void addChart(Chart cht) {
    this.rest.add(cht);
  }
  
  public void addCharts(Chart[] chts) {
    for (Chart cht : chts) addChart(cht);
  }
  
  public void draw() {
    float restX = getX() + getWidth() * this.splitProp, restY = getY() + 15;
    float restW = getWidth() * (1 - this.splitProp), restH = (getHeight() - 30) / this.rest.size();
    
    noStroke();
    fill(240);
    rect(restX, getY(), restW, getHeight());
    
    for (int i = 0; i < this.rest.size(); i++) {
      Chart cht = this.rest.get(i);
      cht.setAll(restX + 30, restY + i * restH + 15, restW - 60, restH - 30);
      if (this.selected == null || this.selected != i) cht.draw();
    }
    
    this.main.setAll(getX() + 30, getY() + getHeight() / 4, getWidth() * this.splitProp - 60,  0.60 * getHeight());
    if (this.selected == null || this.selected != -1) this.main.draw();
    
    if (this.selected != null) {
      Chart cht = this.selected == -1 ? this.main : this.rest.get(this.selected);
      noStroke();
      fill(color(119, 136, 153), 150);
      float chtW = 200, chtH = chtW * cht.getHeight() / cht.getWidth();
      rect(mouseX - chtW/2, mouseY - chtH/2, chtW, chtH);
    }
  }
  
  public void onOver() {
    if (this.selected == null) {
      this.main.onOver();
      for (Chart cht : this.rest) cht.onOver();
    }
  }
  
  public void onPress() {  
    if (mouseButton == RIGHT) {
      if (this.main.isOver()) {
        this.selected = -1;
      } else {
        for (int i = 0; i < this.rest.size(); i++) {
          if (this.rest.get(i).isOver()) {
            this.selected = i;
            break;
          }
        }
      }
    } else if (mouseButton == LEFT) {
      if (this.selected == null) {
        this.main.onPress();
        for (Chart cht : this.rest) cht.onPress();
      }
    }
  }

  public void onRelease() {
    if (this.selected != null) {
      if (this.main.isOver() && this.selected >= 0) {
        Chart temp = this.rest.get(this.selected);
        this.rest.set(this.selected, this.main);
        this.main = temp;
      } else {
        for (int i = 0; i < this.rest.size(); i++) {
          Chart temp = this.rest.get(i);
          if (temp.isOver()) {
            if (this.selected == -1) {
              this.rest.set(i, this.main);
              this.main = temp;
            } else {
              this.rest.set(i, this.rest.get(this.selected));
              this.rest.set(this.selected, temp);
            }
            break;
          }
        }
      }
      this.selected = null;
    }
    
    this.main.onRelease();
    for (Chart cht : this.rest) cht.onRelease();
  }
  
  public void onClick() {
    if (this.selected == null) {
      this.main.onClick();
      for (Chart cht : this.rest) cht.onClick();
    }
  }
}
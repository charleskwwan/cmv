public class NestedPies extends Chart {
  private ArrayList<PieChart> pcharts;
  private int upTo; // draw up to this many pie charts from 0
  
  public NestedPies(float x, float y, float w, float h, Controller ctrl, PokeTable tbl, String[] columns) {
    super(x, y, w, h, ctrl, tbl);
    this.pcharts = new ArrayList<PieChart>();
    for (int i = 0; i < columns.length; i++) {
      float xShift = i * (0.1 * w / columns.length);
      float yShift = i * (0.1 * h / columns.length);
      this.pcharts.add(new PieChart(x + xShift, y + yShift, w - 2 * xShift, h - 2 * yShift, ctrl, tbl, columns[i]));
    }
    this.upTo = 0;
  }
  
  private int getLast() {
    return min(this.upTo, this.pcharts.size()-1);
  }
  
  public void draw() {
    for (int i = 0; i <= getLast(); i++) this.pcharts.get(i).draw();
  }
  
  @Override
  public void setAll(float x, float y, float w, float h) {
    set(x, y, w, h);
    for (int i = 0; i <= getLast(); i++) {
      float xShift = i * (0.1 * w / this.pcharts.size());
      float yShift = i * (0.1 * h / this.pcharts.size());
      this.pcharts.get(i).setAll(x + xShift, y + yShift, w - 2*xShift, h - 2*yShift);
    }
  }
  
  public void update() {
    if (this.controller.size() == 1) this.upTo = this.pcharts.size();
    for (int i = 0; i <= getLast(); i++) this.pcharts.get(i).update();
  }
  
  public void reset() {
    this.pcharts.get(0).reset();
    this.upTo = 0;
  }
  
  public void onOver() {
    for (int i = getLast(); i >= 0; i--) {
      if (this.pcharts.get(i).isOver()) {
        this.pcharts.get(i).onOver();
        return;
      }
    }
  }
  
  public void onClick() {
    if (this.upTo < this.pcharts.size() && this.pcharts.get(this.upTo).isOver() && mouseButton == LEFT) {
      this.pcharts.get(this.upTo).onClick();
      this.upTo++;
      if (this.upTo < this.pcharts.size()) this.pcharts.get(this.upTo).reset();
      return;
    }
    for (int i = getLast(); i >= 0; i--) {
      if (this.pcharts.get(i).isOver() && mouseButton == LEFT) {
        for (int j = getLast(); j >= max(0, i); j--) this.controller.removeColumnFilters(this.pcharts.get(j).getColumn());
        this.upTo = i;
        return;
      }
    }
  }
}
public class ViewPort {
  private float x, y, w, h, cx, cy;
  
  public ViewPort(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.cx = x + w / 2;
    this.cy = y + h / 2;
  }
  
  public float getX() {
    return this.x;
  }
  
  public float getY() {
    return this.y;
  }
  
  public float getWidth() {
    return this.w;
  }
  
  public float getHeight() {
    return this.h;
  }
  
  public float getCenterX() {
    return this.cx;
  }
  
  public float getCenterY() {
    return this.cy;
  }
  
  public boolean isOver() {
    return mouseX > this.x && mouseX < this.x + this.w &&
           mouseY > this.y && mouseY < this.y + this.h;
  }
}
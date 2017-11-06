public class RoundButton extends ViewPort {
  private String s;
  private color on, off;
  private ButtonCallback callback;
  
  public RoundButton(float x, float y, float w, float h, String s, color on, color off, ButtonCallback callback) {
    super(x, y, w, h);
    this.s = s;
    this.on = on;
    this.off = off;
    this.callback = callback;
  }
  
  private float getRadius() {
    return min(getWidth(), getHeight()) / 2;
  }
  
  public void draw() {
    noStroke();
    fill(isOver() ? this.on : this.off);
    ellipse(getX(), getY(), getWidth(), getHeight());
    fill(0);
    text(this.s, getX() - textWidth(this.s)/2, getY() + 0.5 * (textAscent() + textDescent()));
  }
  
  public boolean isOver() {
    return OverUtils.overCircle(mouseX, mouseY, getX(), getY(), getRadius());
  }
  
  public void onClick() {
    if (isOver()) this.callback.f();
  }
}

public interface ButtonCallback {
  public void f();
}
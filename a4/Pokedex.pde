public class Pokedex extends Chart {
  private final PImage pokeballImage = loadImage("pokeball.png");
  private Pokemon p;
  
  public Pokedex(float x, float y, Controller ctrl, PokeTable tbl) {
    super(x, y, 0, 0, ctrl, tbl);
    this.p = null;
  }
  
  public void draw() {
    float imgX = getX() + 100, imgY = getY() + 100;
    float imgW = 180, imgH = 180;

    
    // bg
    noStroke();
    fill(color(200, 0, 0));
    ellipse(imgX, imgY, 250, 250);
    rect(getX(), getY(), 400, 100);
    arc(getX() + 400, getY(), 200, 200, 0, radians(90), PIE);
    
    // fg
    fill(255);
    ellipse(imgX, imgY, imgW, imgH);
    
    // image
    Set<Integer> hovered = this.controller.getHovered();
    if (hovered.size() == 1) {
      for (Integer id : hovered) {
        for (Pokemon p : this.controller) {
          if (p.id == id) {
            this.p = p;
            break;
          }
        }
      }
    } else if (this.controller.size() == 1) {
      for (Pokemon p : this.controller) this.p = p;
    } else {
      this.p = null;
    }
    image(this.p == null ? pokeballImage : getPokeImage(this.p.id),imgX - imgW/2 + 5, imgY - imgH/2 + 5, imgW - 10, imgH - 10); 
  }
  
  public void update() {
    println("called");
    Set<Integer> hovered = this.controller.getHovered();
    if (hovered.size() == 1) for (Integer id : hovered) this.p = this.controller.get(id);
  }
  
  public void reset() {
  }
}
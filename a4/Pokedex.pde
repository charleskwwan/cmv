public class Pokedex extends Chart {
  private final PImage pokeballImage = loadImage("pokeball.png");
  private Pokemon p;
  
  public Pokedex(float x, float y, float h, Controller ctrl, PokeTable tbl) {
    super(x, y, h*4, h, ctrl, tbl);
    this.p = null;
  }
  
  public void draw() {
    float circX = getX() + 0.75 * getHeight(), circY = getY() + 0.75 * getHeight();
    float circW = 2 * getHeight(), circH = 2 * getHeight();
    float barX = getX(), barY = getY();
    float barW = getWidth(), barH = 0.8 * getHeight();
    float imgW = 0.6 * circW, imgH = 0.6 * circH;
    
    // bar
    noStroke();
    fill(color(200, 0, 0));
    rect(barX, barY, barW - barH, barH);
    arc(barX + barW - barH, barY, barH*2, barH*2, 0, radians(90), PIE);
    fill(color(0, 191, 255));
    rect(barX, barY + 0.15 * barH, barW - 0.925 * barH, 0.7 * barH);
    fill(0);
    rect(circX, barY + 0.15 * barH, circW / 2, 0.7 * barH);
    arc(barX + barW - 0.925 * barH, barY + 0.15 * barH, 1.4 * barH, 1.4 * barH, 0, radians(90), PIE);
    
    // circle 
    fill(color(200, 0, 0));
    ellipse(circX, circY, 2 * getHeight(), 2 * getHeight());
    // see if single pokemon first
    Set<Integer> hovered = this.controller.getHovered();
    if (hovered.size() == 1) {
      for (Integer id : hovered)
        for (Pokemon p : this.controller)
          if (p.id == id) {
            this.p = p;
            break;
          }
    } else if (this.controller.size() == 1) {
      for (Pokemon p : this.controller) this.p = p;
    } else {
      this.p = null;
    }
    // img background with pokemon color
    noStroke();
    String type1 = null, type2 = null;
    if (this.p == null) {
      for (String f : this.controller.getFilters()) {
        if (f.contains("type1=")) {
          type1 = f.replace("type1=", "").replace("'", "");
        } else if (f.contains("type2=")) {
          type2 = f.replace("type2=", "").replace("'", "");
        }
      }
    } else {
      type1 = this.p.type1;
      type2 = this.p.type2;
    }
    if (type1 == null && type2 == null) {
      fill(255);
      ellipse(circX, circY, 0.7 * circW, 0.7 * circH);
    } else if (type2 == null || type2.length() == 0) {
      fill(pokeColors.get(type1));
      ellipse(circX, circY, 0.7 * circW, 0.7 * circH);
    } else {
      fill(pokeColors.get(type1));
      arc(circX, circY, 0.7 * circW, 0.7 * circH, 3*PI/4, 7*PI/4, PIE);
      fill(pokeColors.get(type2));
      arc(circX, circY, 0.7 * circW, 0.7 * circH, -PI/4, 3*PI/4, PIE);
    }
    // draw pokemon finally
    image(this.p == null ? pokeballImage : getPokeImage(this.p.id), circX - imgW/2, circY - imgH/2, imgW, imgH);
    
    // text
    float textY = barY + 0.15 * barH + textAscent() + textDescent();
    //textSize(15);
    fill(0);
    text("Name:", circX + circW/2 + 5, textY);
    fill(255);
    text(this.p == null ? "N/A" : this.p.name, circX + circW/2 + 5 + textWidth("Name: "), textY);
    
    fill(0);
    text("First type:", circX + circW/2 + 5, textY + textAscent() + textDescent());
    text("Second type:", circX + circW/2 + 5, textY + 2 * (textAscent() + textDescent()));
    fill(255);
    text(
      type1 == null ? "N/A" : type1,
      circX + circW/2 + 5 + textWidth("First type: "),
      textY + textAscent() + textDescent()
     );
    text(
      type2 == null || type2.length() == 0 ? "N/A" : type2,
      circX + circW/2 + 5 + textWidth("Second type: "),
      textY + 2 * (textAscent() + textDescent())
    );
    //textSize(fontSize);
  }
  
  public void update() {
  }
  
  public void reset() {
  }
}
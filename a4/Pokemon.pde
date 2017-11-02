import java.lang.reflect.*;

public class Pokemon {
  public int id;
  public String name;
  public String type1;
  public String type2;
  public String ability1;
  public String ability2;
  public String abilityH;
  public int hp;
  public int attack;
  public int defense;
  public int spattack;
  public int spdefense;
  public int speed;
  public int total;
  public double wgt;
  public double hgt;
  public String classification;
  public double percentMale;
  public double percentFemale;
  public String preEvolution;
  public String eggGroup1;
  public String eggGroup2;
  private PImage image = null;
  
  public PImage getImage() {
    if (this.image == null) {
      String fname = String.valueOf(id) + ".png";
      this.image = loadImage(fname);
    }
    return this.image;
  }
  
  private Object get(String name) {
    try {
      Class<?> cls = this.getClass();
      Field field = cls.getField(name);
      return field.get(this);
    } catch (Exception e) {
      return null;
    }
  }
  
  public int getInt(String name) {
    return (Integer)get(name);
  }
  
  public String getString(String name) {
    return (String)get(name);
  }
  
  public double getDouble(String name) {
    return (Double)get(name);
  }
}
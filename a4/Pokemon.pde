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
  
  public PImage getImage() {
    String fname = String.valueOf(id) + ".png";
    return loadImage(fname);
  }
}
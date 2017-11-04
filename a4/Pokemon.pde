final String[] pokeTypes = {"Normal", "Fire", "Water", "Electric", "Grass", "Ice", "Fighting",
                            "Poison", "Ground", "Flying", "Psychic", "Bug", "Rock", "Ghost",
                            "Dragon", "Dark", "Steel", "Fairy", ""};
final HashMap<String, Integer> pokeColors = makePokeColors();
final HashMap<Integer, PImage> pokeImages = new HashMap<Integer, PImage>();

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

HashMap<String, Integer> makePokeColors() {
  HashMap<String, Integer> colors = new HashMap<String, Integer>();
  colors.put("Normal", #A8A77A);
  colors.put("Fire", #EE8130);
  colors.put("Water", #6390F0);
  colors.put("Electric", #F7D02C);
  colors.put("Grass", #7AC74C);
  colors.put("Ice", #96D9D6);
  colors.put("Fighting", #C22E28);
  colors.put("Poison", #A33EA1);
  colors.put("Ground", #E2BF65);
  colors.put("Flying", #A98FF3);
  colors.put("Psychic", #F95587);
  colors.put("Bug", #A6B91A);
  colors.put("Rock", #B6A136);
  colors.put("Ghost", #735797);
  colors.put("Dragon", #6F35FC);
  colors.put("Dark", #705746);
  colors.put("Steel", #B7B7CE);
  colors.put("Fairy", #D685AD);
  colors.put("", 0); // no type
  return colors;
}

PImage getPokeImage(int id) {
  if (!pokeImages.containsKey(id)) {
    PImage image = loadImage(String.valueOf(id) + ".png");
    pokeImages.put(id, image);
    return image;
  } else {
    return pokeImages.get(id);
  }
}
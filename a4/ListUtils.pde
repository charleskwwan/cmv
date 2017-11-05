public static class ListUtils {  
  public static double sumDouble(ArrayList<Double> list) {
    if (list == null || list.size() < 1) return 0;
    double sum = 0;
    for (Double n : list) sum += n;
    return sum;
  }
  
  public static float sumFloat(ArrayList<Float> list) {
    return (float)sumDouble(toDoubles(list));
  }
  
  public static int sumInt(ArrayList<Integer> list) {
    return (int)sumDouble(toDoubles(list));
  }
  
  public static double maxDouble(ArrayList<Double> list) {
    if (list == null || list.size() < 1) return 0; // following python
    double max = list.get(0);
    for (Double n : list) if (n > max) max = n;
    return max;
  }
  
  public static float maxFloat(ArrayList<Float> list) {
    return (float)maxDouble(toDoubles(list));
  }
  
  public static int maxInt(ArrayList<Integer> list) {
    return (int)maxDouble(toDoubles(list));
  }
  
  public static double minDouble(ArrayList<Double> list) {
    if (list == null || list.size() < 1) return 0; // following python
    double min = list.get(0);
    for (Double n : list) if (n < min) min = n;
    return min;
  }
  
  public static float minFloat(ArrayList<Float> list) {
    return (float)minDouble(toDoubles(list));
  }
  
  public static float minInt(ArrayList<Integer> list) {
    return (int)minDouble(toDoubles(list));
  }
  
  public static double averageDouble(ArrayList<Double> list) {
    return sumDouble(list) / list.size();
  }
  
  public static int averageInt(ArrayList<Integer> list) {
    return (int) averageDouble(toDoubles(list));
  }
  
  private static <T extends Number> ArrayList<Double> toDoubles(ArrayList<T> list) {
    ArrayList<Double> doubles = new ArrayList<Double>();
    for (T n : list) doubles.add(n.doubleValue());
    return doubles;
  }
}
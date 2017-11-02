public static class OverUtils {
  public static boolean overCircle(float mX, float mY, float x, float y, float r) {
    return pow(mX - x, 2) + pow(mY - y, 2) <= pow(r, 2);
  }
  
  public static boolean overRect(float mX, float mY, float x, float y, float w, float h) {
    return mX > x && mX < x + w && mY > y && mY < y + h;
  }
}
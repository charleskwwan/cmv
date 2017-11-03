public static class OverUtils {
  public static boolean overCircle(float mX, float mY, float x, float y, float r) {
    return pow(mX - x, 2) + pow(mY - y, 2) <= pow(r, 2);
  }
  
  public static boolean overRect(float mX, float mY, float x, float y, float w, float h) {
    return mX > x && mX < x + w && mY > y && mY < y + h;
  }
  
  public static boolean overSlice(float mX, float mY, float x, float y, float a1, float a2, float r) {
    float ma = atan2(mY - y, mX - x);
    if (ma < 0) ma += TWO_PI;
    return overCircle(mX, mY, x, y, r) && ma > min(a1, a2) && ma < max(a1, a2);
  }
}
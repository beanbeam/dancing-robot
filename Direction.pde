public enum Direction {
  POSITIVE_X,
  NEGATIVE_X,
  POSITIVE_Y,
  NEGATIVE_Y;
  
  public boolean alongY() {
    return this == POSITIVE_Y || this == NEGATIVE_Y;
  }
  
  public boolean alongX() {
    return this == POSITIVE_X || this == NEGATIVE_X;
  }
}
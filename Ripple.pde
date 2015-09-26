class Ripple {
  // In tile units
  private final int x;
  private final int y;
  private final float amplitude;
  private final float wavelength;
  
  // In milliseconds since the epoch
  private final int creationTime;
  
  // In tiles per second
  private final float speed;
  
  // Current radius of leading edge
  private float radius;
  
  /**
   * Create a new ripple
   *
   * @param x the x coordinate of the ripple's center in tile units
   * @param y the y coordinate of the ripple's center in tile units
   * @param amplitude the peak amplitude of the ripple in tile units
   * @param wavelength the wavelength of the ripple in tile units
   * @param speed the rate at which the ripple's radius increases in tiles per second
   */
  public Ripple(int x, int y, float amplitude, float wavelength, float speed) {
    this.x = x;
    this.y = y;
    this.amplitude = amplitude;
    this.wavelength = wavelength;
    this.speed = speed;
    this.radius = 0;
    
    this.creationTime = millis();
  }
  
  /**
   * Updates the radius of the ripple
   *
   * @return true if this ripple is gone
   */
  public boolean propogate() {
    radius=speed*(millis()-creationTime)/1000.0;
    
    // Remove the ripple if it is roughly large enough to be completely off-screen.
    return radius-wavelength > TILES_PER_SIDE*1.5;
  }
  
  /**
   * Get the effect this ripple has on a given point
   *
   * @param x The x coordinate of the point, in tile units
   * @param y The y coordinate of the point, in tile units
   *
   * @return The height difference this ripple causes at the given point
   */
  public float effectAt(int x, int y) {
    float d = dist(this.x, this.y, -x, -y);
    
    if (d <= radius && d > radius-wavelength) {
      return amplitude * sin((radius-d)*2*PI/wavelength);
    }
    return 0;
  }
}
class Tile {
  private final int x;
  private final int y;
  private float z;
  
  private final int size;
  private float hue;
  
  public Tile(int x, int y, int size, float hue) {
    this.x = x;
    this.y = y;
    this.z = 0;
    this.size = size;
    this.hue = hue;
  }
  
  void setHue(float hue) {
    this.hue = hue;
  }
  
  void draw(boolean highlight) {
    this.z = 0;
    for (Ripple r : ripples) {
      z += r.effectAt(x, y)*tile_size;
    }
    
    float screenX = width/2 + x*RATIO*size - y*RATIO*size;
    float screenY = height/2 + z + (x+y)*0.5*size;
    
    float dx = RATIO*size*0.95;
    float dy = 0.5*size*0.95;
    
    float beatLength = 60*1000.0 / bpm;
    float beatTime = (t%beatLength)/beatLength;
     
    noStroke();
    fill(hue,
         0.8-pow(beatTime,2)*0.9,
         max(1.0-pow(beatTime,2)*0.8,0.2));
    quad(screenX-dx, screenY,
         screenX,    screenY-dy,
         screenX+dx, screenY,
         screenX,    screenY+dy);
         
    if (highlight) {
      dx*=beatTime;
      dy*=beatTime;
      fill(0, 0, 1.0, 127 - pow(beatTime, 2)*128);
      quad(screenX-dx, screenY,
           screenX,    screenY-dy,
           screenX+dx, screenY,
           screenX,    screenY+dy);
    }
  }
}
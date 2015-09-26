import java.util.Arrays;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;
import java.awt.event.KeyEvent;

// CONSTANTS
// =================
final int TILES_PER_SIDE = 25;

final int BPM_LOCK_MIN_BEATS = 10; // Minimum number of tapped beats before BPM will update
final int BPM_LOCK_MIN_STREAK = 4; // Minimum number of consecutive, consistent tapped beats before BPM will update

final int FPS_SMOOTHING = 30;      // Number of frames to average FPS over
final float RATIO = 0.866;         // sqrt(3)/2

int bpm = 120;

int tile_size;
Tile[][] tiles;
ArrayList<Ripple> ripples = new ArrayList<Ripple>();

int lastT = millis();
int t;

boolean debug = false;
boolean help = false;

int targetX = 0;
int targetY = 0;
Robot robot = new Robot(0, 0);

float rawBpm = bpm;

int timeStart = 0;
boolean doBeat = false;

int syncStart = 0;
int syncCount = 0;
int syncStreak = 0;

int smoothedFps = 0;
int fpsFrameCount = 0;
int fpsLastCalculated = millis();

void setup() {
  //size(1600, 900);
  fullScreen();
  colorMode(HSB, 360, 1.0, 1.0);
  
  int offset = TILES_PER_SIDE/2;
  tile_size = int(min((width-50)/(TILES_PER_SIDE*sqrt(3)), (height-50)/TILES_PER_SIDE));
  
  tiles = new Tile[TILES_PER_SIDE][TILES_PER_SIDE];

  for (int x=0; x < TILES_PER_SIDE; x++) {
    for (int y=0; y < TILES_PER_SIDE; y++) {
      tiles[x][y] = new Tile(x-offset, y-offset, tile_size, random(360));
    }
  }
  
  // Force Processing to start loading fonts in the background to reduce lag when we actually use text
  thread("loadFonts");
}

void keyPressed() {
  if (key == 'd' || key == 'D') {
    debug = !debug;
  } else if (key == 'h' || key == 'H') {
    help = !help;
  } else if (key == CODED && keyCode == KeyEvent.VK_PAGE_DOWN) {
    bpm--;
  } else if (key == CODED && keyCode == KeyEvent.VK_PAGE_UP) {
    bpm++;
  } else if (key == ' ') {
    doMusicSync();
  }
}

void mouseMoved() {
  float relativeX = mouseX- width/2;
  float relativeY = mouseY- height/2;
  
  
  int gridX = -int(round(relativeX/(sqrt(3)*tile_size) + relativeY/tile_size));
  int gridY = int(round(relativeX/(sqrt(3)*tile_size) - relativeY/tile_size));
  
  targetX = min(TILES_PER_SIDE/2, max(-TILES_PER_SIDE/2, gridX));
  targetY = min(TILES_PER_SIDE/2, max(-TILES_PER_SIDE/2, gridY));
}

void mousePressed() {
  ripples.add(new Ripple(targetX, targetY, 0.1, 6, TILES_PER_SIDE*1.2));
}

void draw() {
  background(0);
  
  t = millis() - timeStart;
  float beatLength = 60*1000.0 / bpm;
  if (int(lastT/beatLength) < int(t/beatLength)) {
    doBeat = true;
  }
  
  if (t >= 2000) {
    syncCount = 0;
  }
  
  if (doBeat) {
    robot.move();
  }
  
  Iterator<Ripple> iter = ripples.iterator();
  while (iter.hasNext()) {
    if (iter.next().propogate()) {
      iter.remove();
    }
  }
  
  for (int x=0; x<tiles.length; x++) {
    Tile[] r = tiles[x];
    for (int y=0; y<r.length; y++) { 
      Tile tile = r[y];
      if (doBeat) {
        tile.setHue(random(360));
      }
      boolean highlight = (-x + TILES_PER_SIDE/2) == targetX
                       && (-y + TILES_PER_SIDE/2) == targetY;
      
      tile.draw(highlight);
    }
  }
  
  robot.draw();
  
  if (fpsFrameCount < FPS_SMOOTHING) {
    fpsFrameCount++;
  } else {
    fpsFrameCount = 0;
    smoothedFps = 1000*FPS_SMOOTHING/(millis()-fpsLastCalculated);
    fpsLastCalculated = millis();
  }
  
  if (syncCount > 1) {
    drawMusicSync();
  } 
  
  if (debug) {
    drawDebug();
  }
  
  if (help) {
    drawHelp();
  }
  
  lastT = t;
  doBeat = false;
}

/**
 * Draw invisible text to force Processing to load the default fonts
 */
void loadFonts() {
  text("", -10, -10);
}

void doMusicSync() {
  
    if (t < 2000) {
      syncCount++;
    }
    
    timeStart = millis();
    if (syncCount > 1) {
      int oldRoundBpm = round(rawBpm);
      rawBpm = 1000*60*(syncCount-1.0)/(millis()-syncStart);
      if (round(rawBpm) == oldRoundBpm) {
        syncStreak++;
      } else {
        syncStreak = 0;
      }
    } else {
      syncStart = millis();
      syncStreak = 0;
    }
    
    if (syncCount > BPM_LOCK_MIN_BEATS && syncStreak >= BPM_LOCK_MIN_STREAK) {
      bpm = round(rawBpm);
    }
    
    doBeat = true;
}

/**
 * Draws the music synchronization UI in the top right corner of the screen.
 */
void drawMusicSync() {
  // Use a darker gray if BPM is not locked
  if (syncCount > BPM_LOCK_MIN_BEATS && syncStreak >= BPM_LOCK_MIN_STREAK) {
    fill(360);
  } else {
    fill(180);
  }
  
  // BPM number
  textSize(32);
  textAlign(RIGHT, BOTTOM);
  int integerBpm = round(rawBpm);
  text(integerBpm, width-58, 53);
  
  // BPM label
  fill(360);
  textSize(16);
  textAlign(LEFT, BOTTOM);
  text("BPM", width-55, 50);
  
  // Music sync label
  textSize(16);
  textAlign(CENTER, TOP);
  text("MUSIC SYNC", width-70, 60);
  
  // BPM difference bar line
  stroke(360);
  line(width-120, 55, width-20, 55);
  
  // BPM difference bar
  float bpmDifference = rawBpm-integerBpm;
  noStroke();
  if (bpmDifference > 0) {
    rect(width-70, 52, 100*bpmDifference, 6);
  } else {
    float w = -100*bpmDifference;
    rect(width-(70+w), 52, w, 6);
  }
}

/**
 * Draws debug information in the top left corner of the screen.
 */
void drawDebug() {
  fill(360);
  textSize(14);
  textAlign(LEFT, TOP);
  
  text("BPM:", 0, 0);
  text(bpm, 40, 0);
    
  text("FPS:", 0, 15);
  text(smoothedFps, 40, 15);
    
  text("TGT:", 0, 30);
  text(String.format("(%d, %d)", targetX, targetY), 40, 30);
  
  text("ROB:", 0, 45);
  text(String.format("(%d, %d)", robot.getX(), robot.getY()), 40, 45);
  
  text("RIP:", 0, 60);
  text(ripples.size(), 40, 60);
  
  text("SYN:", 0, 75);
  text(syncCount, 40, 75);
  
  text("STR:", 0, 90);
  text(syncStreak, 40, 90);
}

/**
 * Draws help information in the bottom right corner of the screen.
 */
void drawHelp() {
  fill(360);
  textSize(14);
  textAlign(LEFT, BOTTOM);
  
  text("H:", width-300, height-115);
  text("Toggle this help window", width-180, height-115);
  
  text("SPACE:", width-300, height-100);
  text("Music Sync", width-180, height-100);
  
  text("PAGE UP/DOWN:", width-300, height-85);
  text("Tweak BPM", width-180, height-85);
  
  text("D:", width-300, height-70);
  text("Toggle debug info", width-180, height-70);

  text("Press space once to change the beat time,", width-300, height-45);
  text("continue pressing on rhythm to sync BPM.", width-300, height-30);
  text("When tapped BPM becomes stable, it turns", width-300, height-15);
  text("white to show it has been applied.", width-300, height);
}
class Robot {
  // The position of the robot in tile units
  private int x;
  private int y;
  
  // The position of the last tile the robot bounced on in tile units
  private int lastX;
  private int lastY;
  
  // The direction the robot is facing
  private Direction dir;
  
  // A fixed list of heights for the levels displayed on the robots chest.
  // Gets shuffled each beat, but the values stay the same.
  private List<Float> levelHeights = Arrays.asList(0.7, 1.0, 0.4);
  
  public Robot(int x, int y) {
    this.x = x;
    this.y = y;
    this.lastX = x;
    this.lastY = y;
    this.dir = Direction.NEGATIVE_Y;
  }
  
  /**
   * Called on every beat, adds a new ripple, chooses the next tile for the robot to move toward
   * and shuffles the sound level bars.
   */
  public void move() {
    ripples.add(new Ripple(robot.getX(), robot.getY(), 0.1, 6, TILES_PER_SIDE*1.2));
    lastX = x;
    lastY = y;
    
    Collections.shuffle(levelHeights);
    
    if (abs(x-targetX) > abs(y-targetY)) {
      if (x > targetX) {
        x -= 1;
        dir = Direction.NEGATIVE_X;
      } else if (x < targetX) {
        x += 1;
        dir = Direction.POSITIVE_X;
      }
    } else {
      if (y > targetY) {
        y -= 1;
        dir = Direction.NEGATIVE_Y;
      } else if (y < targetY) {
        y += 1;
        dir = Direction.POSITIVE_Y;
      }
    }
  }
  
  /**
   * Draws the relatively complex polygon for one of the robot's arms.
   */
  private void drawArm() {
    beginShape();
    vertex(0,              0.05*tile_size);
    vertex(0.38*tile_size, 0.05*tile_size);
    vertex(0.43*tile_size, 0.1*tile_size);
    vertex(0.5*tile_size,  0.1*tile_size);
    vertex(0.55*tile_size, 0.05*tile_size);
    vertex(0.49*tile_size, 0.05*tile_size);
    vertex(0.46*tile_size, 0);
    vertex(0.49*tile_size, -0.05*tile_size);
    vertex(0.55*tile_size, -0.05*tile_size);
    vertex(0.5*tile_size,  -0.1*tile_size);
    vertex(0.43*tile_size, -0.1*tile_size);
    vertex(0.38*tile_size, -0.05*tile_size);
    vertex(0,              -0.05*tile_size);
    endShape();
  }
  
  public void draw() {
    float beatLength = 60*1000.0 / bpm;
    float beatTime = (t%beatLength)/beatLength;
    float beatHalftime = (t%(beatLength*2))/(beatLength*2);
    
    float drawX = -(lastX + beatTime*(x-lastX));
    float drawY = -(lastY + beatTime*(y-lastY));
    float drawZ = pow(2*beatTime - 1,2)-1;
    
    float screenX = width/2 + drawX*RATIO*tile_size - drawY*RATIO*tile_size;
    float screenY = height/2 + drawZ*tile_size + (drawX+drawY)*0.5*tile_size;
    
    pushMatrix();
    translate(screenX, screenY);
    scale(RATIO,1);
    
    // BACK ARM
    // ===============
    pushMatrix();
    if (dir.alongY()) {
      translate(-0.3*tile_size, -0.75*tile_size);
      shearY(radians(-25));

      fill(0, 0, 0.9);
    } else {
      translate(0.3*tile_size, -0.75*tile_size);
      shearY(radians(25));
      
      fill(0, 0, 0.8);
    }
    
    float armAngle = radians(30*cos(beatHalftime*2*PI));
    if (dir == Direction.NEGATIVE_Y || dir == Direction.POSITIVE_X) {
      armAngle += PI;
    }
    rotate(armAngle);

    noStroke();
    //rect(0, -0.05*tile_size, 0.45*tile_size, 0.1*tile_size);
    drawArm();
    
    popMatrix();
    
    // BODY
    // ===============
    // Left Face
    fill(0, 0, 0.5);
    quad(1,              0.3*tile_size,
         1,              -0.6*tile_size,
         -0.6*tile_size, -0.9*tile_size,
         -0.6*tile_size, 0);
    
    // Right Face
    fill(0, 0, 0.6);
    quad(0,             0.3*tile_size,
         0,             -0.6*tile_size,
         0.6*tile_size, -0.9*tile_size,
         0.6*tile_size, 0);
    
    // Top Face
    fill(0, 0, 0.65);
    quad(0,              -0.6*tile_size+1,
         -0.6*tile_size, -0.9*tile_size+1,
         0,              -1.2*tile_size+1,
         0.6*tile_size,  -0.9*tile_size+1);
    
    // HEAD
    // ===============
    // Left Face
    fill(0, 0, 0.5);
    if (dir.alongY()) {
      quad(0.1*tile_size + 1,  -0.65*tile_size+1,
           0.1*tile_size + 1,  -1.05*tile_size,
           -0.5*tile_size,     -1.35*tile_size,
           -0.5*tile_size,     -0.95*tile_size+1);
    } else {
      quad(-0.1*tile_size + 1, -0.65*tile_size+2,
           -0.1*tile_size + 1, -1.05*tile_size,
           -0.5*tile_size,     -1.25*tile_size,
           -0.5*tile_size,     -0.85*tile_size+2);
    }
    
    // Right Face
    fill(0, 0, 0.6);
    if (dir.alongY()) {
      quad(0.1*tile_size, -0.65*tile_size+2,
           0.1*tile_size, -1.05*tile_size,
           0.5*tile_size, -1.25*tile_size,
           0.5*tile_size, -0.85*tile_size+2);
    } else {
      quad(-0.1*tile_size, -0.65*tile_size+1,
           -0.1*tile_size, -1.05*tile_size,
           0.5*tile_size,  -1.35*tile_size,
           0.5*tile_size,  -0.95*tile_size+1);
    }
    
    // Top Face
    fill(0, 0, 0.65);
    if (dir.alongY()) {
      quad(0.1*tile_size,  -1.05*tile_size + 1,
           -0.5*tile_size, -1.35*tile_size + 1,
           -0.1*tile_size, -1.55*tile_size + 1,
           0.5*tile_size,  -1.25*tile_size + 1);
    } else {
      quad(-0.1*tile_size, -1.05*tile_size + 1,
           -0.5*tile_size, -1.25*tile_size + 1,
           0.1*tile_size,  -1.55*tile_size + 1,
           0.5*tile_size,  -1.35*tile_size + 1);
    }
    
    // EYES
    // ===============
    if(dir == Direction.NEGATIVE_X || dir == Direction.NEGATIVE_Y) {
      pushMatrix();
      if(dir == Direction.NEGATIVE_X) {
        translate(0.2*tile_size, -0.98*tile_size);
        shearY(radians(-26));
      } else {
        translate(-0.2*tile_size, -0.98*tile_size);
        shearY(radians(26));
      }
      
      noStroke();
      
      fill(0, 0, 0.1);
      ellipse(0.1*tile_size, 0, 0.14*tile_size, 0.22*tile_size);
      ellipse(-0.1*tile_size, 0, 0.14*tile_size, 0.22*tile_size);

      float saturation = pow(beatTime*1.5, 2);
      fill(0, saturation, 0.7);
      ellipse(0.1*tile_size, 0, 0.10*tile_size, 0.18*tile_size);
      ellipse(-0.1*tile_size, 0, 0.10*tile_size, 0.18*tile_size);
      popMatrix();
    }
    
    // DISPLAY OR BACK VENT
    // ===============
    if(dir == Direction.NEGATIVE_X || dir == Direction.NEGATIVE_Y) {
      pushMatrix();
      if(dir == Direction.NEGATIVE_X) {
        translate(0.31*tile_size, -0.45*tile_size);
        shearY(radians(-26));
      } else {
        translate(-0.31*tile_size, -0.45*tile_size);
        shearY(radians(26));
      }

      noStroke();
      // Screen frame
      fill(0, 0, 0);
      rect(-0.23*tile_size, -0.18*tile_size, 0.46*tile_size, 0.36*tile_size, 0.05*tile_size);
      
      // Screen
      fill(0, 0, 0.2);
      rect(-0.21*tile_size, -0.16*tile_size, 0.42*tile_size, 0.32*tile_size, 0.03*tile_size);
      
      // Levels
      fill(120, 0.8, 0.8);
      noStroke();
      float levelScale = max(0, 1-pow(1.2*beatTime,2));
      
      for (int i=0; i<levelHeights.size(); i++) {
        float currentHeight = levelHeights.get(i)*levelScale*0.26*tile_size;
        
        rect(-0.18*tile_size + 0.13*tile_size*i, 0.13*tile_size - currentHeight, 0.10*tile_size, currentHeight);
      }
      
      popMatrix();
    } else {
      pushMatrix();
      if(dir == Direction.POSITIVE_X) {
        translate(0.31*tile_size, -0.15*tile_size);
        shearY(radians(-25));
      } else {
        translate(-0.31*tile_size, -0.15*tile_size);
        shearY(radians(25));
      }
      
      fill(0, 0, 0.1);
      noStroke();
      rect(-0.2*tile_size, -0.1*tile_size,  0.4*tile_size, 0.04*tile_size, 0.03*tile_size);
      rect(-0.2*tile_size, -0.02*tile_size, 0.4*tile_size, 0.04*tile_size, 0.03*tile_size);
      rect(-0.2*tile_size,  0.06*tile_size, 0.4*tile_size, 0.04*tile_size, 0.03*tile_size);
      popMatrix();
    }
    
    // ANTENNA
    // ===============
    pushMatrix();
    if (dir == Direction.NEGATIVE_Y) {
      translate(0.35*tile_size, -1.25*tile_size);
    } else if (dir == Direction.NEGATIVE_X) {
      translate(0.1*tile_size, -1.45*tile_size);
    } else if (dir == Direction.POSITIVE_Y) {
      translate(-0.35*tile_size, -1.35*tile_size);
    } else if (dir == Direction.POSITIVE_X) {
      translate(-0.1*tile_size, -1.15*tile_size);
    }
    
    noStroke();
    fill(0);
    // Base
    ellipse(0, 0, 0.05*tile_size, 0.025*tile_size);
    ellipse(0, -0.01*tile_size, 0.04*tile_size, 0.02*tile_size);
    
    // Antenna
    rect(-0.005*tile_size, 0, 0.01*tile_size, -0.5*tile_size);
    // Tip
    ellipse(0, -0.5*tile_size, 0.05*tile_size, 0.05*tile_size);
    popMatrix();
    
    // FRONT ARM
    // ===============
    pushMatrix();
    if (dir.alongY()) {
      translate(0.32*tile_size, -0.43*tile_size);
      shearY(radians(-25));
    } else {
      translate(-0.32*tile_size, -0.43*tile_size);
      shearY(radians(25));
    }
    
    // Shoulder base
    fill(0, 0, 0.1);
    if (dir.alongY()) {
      ellipse(-0.02*tile_size, -0.02*tile_size, 0.16*tile_size, 0.16*tile_size);
    } else {
      ellipse(0.02*tile_size, -0.02*tile_size, 0.16*tile_size, 0.16*tile_size);
    }
    
    // Main Arm
    pushMatrix();
    armAngle = -radians(30*cos(beatHalftime*2*PI));;
    if (dir == Direction.NEGATIVE_Y || dir == Direction.POSITIVE_X) {
      armAngle += PI;
    }
    rotate(armAngle);

    noStroke();
    if (dir == Direction.NEGATIVE_Y || dir == Direction.POSITIVE_Y) {
      fill(0, 0, 0.9);
    } else {
      fill(0, 0, 0.8);
    }
    drawArm();
    popMatrix();
    
    // Shoulder middle
    fill(0, 0, 0.1); 
    ellipse(0, 0, 0.16*tile_size, 0.16*tile_size);
    
    // Shoulder cap
    fill(0, 0, 0.1);
    if (dir.alongY()) {
      ellipse(0.02*tile_size, 0.02*tile_size, 0.16*tile_size, 0.16*tile_size);
    } else {
      ellipse(-0.02*tile_size, 0.02*tile_size, 0.16*tile_size, 0.16*tile_size);
    }
    
    // Shoulder Center
    if (dir.alongY()) {
      fill(0, 0, 0.8);
      ellipse(0.02*tile_size, 0.02*tile_size, 0.14*tile_size, 0.14*tile_size);
    } else {
      fill(0, 0, 0.7);
      ellipse(-0.02*tile_size, 0.02*tile_size, 0.14*tile_size, 0.14*tile_size);
    }  
    
    popMatrix();
    
    
    popMatrix();
  }
  
  public int getX() {
    return x;
  }
  public int getY() {
    return y;
  }
}
  
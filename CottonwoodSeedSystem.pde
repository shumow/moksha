import java.util.LinkedList;

class CottonwoodSeedSystem {
  class CottonwoodSeed {
    
    Point pt;
    
    float inner_radius;
    float outer_radius;
    
    float speed;
    
    CottonwoodSeed(Point ipt, float iir, float ior, float is) {
      pt = ipt;

      inner_radius = iir;
      outer_radius = ior;
      
      speed = is;
    }
    
    void draw() {
      pushStyle();
        ellipseMode(CENTER);
        noStroke();
        pushMatrix();
          translate(pt.x,pt.y);
          fill(color(255,255,255,64));
          ellipse(0, 0, 2*outer_radius, 2*outer_radius);
          fill(255);
          ellipse(0, 0, 2*inner_radius, 2*inner_radius);
        popMatrix();
      popStyle();      
    }
    
    void update(float dt) {
      pt.x += speed*dt;
    }
    
    boolean isOffscreen() {
      if (speed < 0) {
        if (pt.x < -outer_radius)  {
          return true;
        }
      } else {
        if (width + outer_radius < pt.x) {
          return true;
        }
      }
      return false;
    }
  }
  
  CottonwoodSeed createNewSeed() {
    int[] directions = {-1,1};
    int direction = directions[int(random(directions.length))];

    float speed = direction*random(width/20.0,width/7.0);
    
    float inner_radius = 1;
    float outer_radius = random(inner_radius, 6);
    
    float x;
    
    float y = random(height);
    
    if (direction < 0) {
      x = width + 1 + outer_radius;
    } else {
      x = -1 - outer_radius;
    }
    
    Point pt = new Point(x,y);
    
    return new CottonwoodSeed( pt, inner_radius, outer_radius, speed);
  }
  
  LinkedList<CottonwoodSeed> seeds;
 
  float prob_new_seed = 4.0;
  
  CottonwoodSeedSystem() {
    seeds = new LinkedList<CottonwoodSeed>();
  }
  
  void draw() {
    for (CottonwoodSeed seed : seeds) {
      seed.draw();
    }
  }
  
  void update(float dt) {

    if (random(1) < prob_new_seed*dt) {
      seeds.add(createNewSeed());
    }

    for (int i = 0; i < seeds.size(); i++) {
      CottonwoodSeed seed = seeds.get(i);
      seed.update(dt);
      if (seed.isOffscreen()) {
        seeds.remove(i);
      }
    }
  }
}

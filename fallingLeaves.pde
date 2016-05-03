
//***************************************************************
//falling leaves app
//***************************************************************
final boolean DEBUG_MODE = false;
static boolean display_tree = true;
static PImage imgTree = null;
static PImage imgSilhouette = null; 
static GridTiler gridTiles;
float lastEndTick = 0;

static boolean edit_mode = false;
static boolean display_leaf_system = false;
static boolean display_leaves = true;
static boolean crop_line = false;
static boolean draw_crop_line = false;

static float cropX;

static LeafSystem leafs;

RadialTileChanger tileChanger;

//FluidMotionReceiver fmr;
//***************************************************************
// called to set everything up
//***************************************************************
void setup()
{
  if(DEBUG_MODE)
  { size(600,800,P2D); }
  else
  { size(800,600,P2D); }//we are dealing with a 800x600 native res projector
  if (!DEBUG_MODE) {
    noCursor();
  }
  XML xml = loadXML("GridTiler.xml");
  if(DEBUG_MODE)
  { gridTiles = new GridTool(xml);}//new float[]{width/2,height/2},50, PI/3, 2*PI/3.f);
  else
  { gridTiles = new GridTiler(xml); }
 
  gridTiles.loadWithXML(xml);
  
  tileChanger = new RadialTileChanger(gridTiles,new float[]{0,0});
  leafs = new LeafSystem(50, "leafSystem.png", 75);
  leafs.spawn();
  
  imgTree = loadImage("treeoverlay.png");
  imgSilhouette = loadImage("treesilhouette.png");
  
  println("classname: " + super.getClass().getSuperclass());
//  fmr = new FluidMotionReceiver(this,"videoFluidSyphon");
}

void drawTree()
{
  pushMatrix();
  if(DEBUG_MODE)
  { 
    translate(0,width);
  } else { 
    translate(0,height);
  }
  rotate(-PI/2);
  
  pushStyle();
  imageMode(CORNER);
  image(imgTree, 0, 0);
  popStyle();  
  popMatrix();
}

void drawSilhouette()
{
  pushMatrix();
  if(DEBUG_MODE)
  { 
    translate(0,width);
  } else { 
    translate(0,height);
  }
  rotate(-PI/2);
  
  pushStyle();
  imageMode(CORNER);
  image(imgSilhouette, 0, 0);
  popStyle();  
  popMatrix();
}


//***************************************************************
// our looping function called once per tick
// resposible for drawing AND updating... everything
//***************************************************************
void draw()
{
  pushStyle();
  fill(0,0,0,90);
  rect(0,0,width,height);
  popStyle();
  
  if(DEBUG_MODE)
  { 
    pushMatrix();
    translate(width,0);
    rotate(PI/2);
  }

  float secondsSinceLastUpdate = (millis()-lastEndTick)/1000.f;
  gridTiles.update(secondsSinceLastUpdate);
  leafs.update(secondsSinceLastUpdate);
//  if(!tileChanger.isComplete())
    tileChanger.update(secondsSinceLastUpdate);
//  else
//    tileChanger.reset();
  gridTiles.draw();
  lastEndTick = millis();
  
  if (display_tree) {
    drawTree();
  } else {
    drawSilhouette(); 
  }

  if (DEBUG_MODE) {
    popMatrix();
  }
    
  if (edit_mode || display_leaf_system) {
     leafs.displaySpawnData();
  }

  if (display_leaves) {
    leafs.draw();
  }
  
  if (crop_line || draw_crop_line) {
    pushStyle();
    stroke(255,0,0);
    line(cropX,0,cropX,height);
    popStyle();
  }
}

//***************************************************************
// super basic input
//***************************************************************
void mousePressed() {
  int x = mouseX;
  int y = mouseY;
  if (edit_mode) {
    leafs.addSpawnPoint(x, y);
  }
}

void mouseClicked() {
  if (crop_line) {
    draw_crop_line = true;
    crop_line = false;
  }
}

void mouseDragged() {
  int x = mouseX;
  int y = mouseY;
  if (edit_mode) {
    leafs.addSpawnPoint(x, y);
  }
}

void mouseMoved() {
  if (crop_line) {
    cropX = mouseX;
  }
}

void saveScreenToPicture()
{
  save("screenCap/fallingLeaves-"+year()+"-"+month()+"-"+day()+":"+hour()+":"+minute()+":"+second()+":"+millis() +".png");
}


boolean ifKeyPair(char k, char c1, char c2) {
  return ((k == c1)||(k == c2));
}

void keyPressed()
{
  if (ifKeyPair(key,'p','P')) {
    saveScreenToPicture();
  }
  if (ifKeyPair(key,'g','G')) {
    if(DEBUG_MODE)
      ((GridTool)gridTiles).generateCutouts();
  }
  if (ifKeyPair(key,'t','T')) {
    display_tree ^= true;
  }
  if (ifKeyPair(key,'e','E')) {
    if (edit_mode) {
      leafs.finishSpawnMask();
      display_leaf_system = true;
    }
    edit_mode ^= true;
  }
  if (ifKeyPair(key,'l','L')) {
    display_leaf_system ^= true;
  }
  if (ifKeyPair(key,'f','F')) {
    display_leaves ^= true;
  }
  if (ifKeyPair(key,'x','X')) {
    if (draw_crop_line) {
      draw_crop_line = false;
    } else {
      crop_line ^= true;
    }
  }
}

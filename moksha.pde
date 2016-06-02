//***************************************************************
//moksha app
// fork of falling leaves app
//***************************************************************
final boolean DEBUG_MODE = false;
final boolean ROTATE_DISPLAY = false;
final boolean PAINT_MODE = true;
static boolean display_tree = false;
static boolean display_silhouette = true;
static PImage imgTree = null;
static PImage imgSilhouette = null; 
static GridTiler gridTiles;
float lastEndTick = 0;

static PGraphics dg;

static boolean edit_mode = false;
static boolean display_leaf_system = false;
static boolean display_leaves = true;
static boolean crop_line = false;
static boolean draw_crop_line = false;

static float cropX;

/*
static int screenWidth = 960;
static int screenHeight = 540;
*/

/*
static int screenWidth = 1920;
static int screenHeight = 1080;
*/

static int screenWidth = 1280;
static int screenHeight = 720;

static LeafSystem leafs;

static CottonwoodSeedSystem seeds;

RadialTileChanger tileChanger;

void CreateLeafSystem()
{
  leafs = new LeafSystem(50, "leafSystem.png", 750);
  leafs.spawn();
}

//FluidMotionReceiver fmr;
//***************************************************************
// called to set everything up
//***************************************************************
void setup()
{  
  if (!ROTATE_DISPLAY)
  {
    size(screenWidth,screenHeight,P2D); //we are dealing with a WUXGA projector which can support 1080p natively    
  }
  else
  {
    size(screenHeight,screenWidth,P2D);
  }
  
  if (PAINT_MODE)
  {
    display_leaves = false;
  }
  
  dg = g;
  
  XML xml = loadXML("GridTiler.xml");
  if(DEBUG_MODE)
  { gridTiles = new GridTool(xml);}//new float[]{width/2,height/2},50, PI/3, 2*PI/3.f);
  else
  { gridTiles = new GridTiler(xml); }
 
  gridTiles.loadWithXML(xml);
  
  tileChanger = new RadialTileChanger(gridTiles,new float[]{0,0});
  CreateLeafSystem();
  
  seeds = new CottonwoodSeedSystem();
  
  imgTree = loadImage("treeoverlay.png");
  imgSilhouette = loadImage("treesilhouette.png");
  
  println("classname: " + super.getClass().getSuperclass());
//  fmr = new FluidMotionReceiver(this,"videoFluidSyphon");

  noCursor();
}

void drawTree()
{
  dg.pushMatrix();
  if(!ROTATE_DISPLAY)
  { 
    dg.translate(0,width);
  } else { 
    dg.translate(0,height);
  }
  dg.rotate(-PI/2);
  
  dg.pushStyle();
    dg.imageMode(CORNER);
    dg.image(imgTree, 0, 0,width,height);
  dg.popStyle();  
  dg.popMatrix();
}

void drawSilhouette()
{
  dg.pushMatrix();
  if(!ROTATE_DISPLAY)
  { 
    dg.translate(0,width);
  } else { 
    dg.translate(0,height);
  }
  dg.rotate(-PI/2);
  
    dg.pushStyle();
      dg.imageMode(CORNER);
      dg.image(imgSilhouette, 0, 0,width,height);
    dg.popStyle();  
  dg.popMatrix();
}


//***************************************************************
// our looping function called once per tick
// resposible for drawing AND updating... everything
//***************************************************************
void draw()
{
  //dg.beginDraw();
  dg.pushStyle();

  if (PAINT_MODE)
  {
    dg.fill(128,128,128,90);
  }
  else
  {
    dg.fill(0,0,0,90);    
  }

  dg.rect(0,0,width,height);
  dg.popStyle();
  
  if(!ROTATE_DISPLAY)
  { 
    dg.pushMatrix();
    dg.translate(width,0);
    dg.rotate(PI/2);
  }

  float secondsSinceLastUpdate = (millis()-lastEndTick)/1000.f;

  if (PAINT_MODE)
  {
    gridTiles.update(secondsSinceLastUpdate);
  }
  
  leafs.update(secondsSinceLastUpdate);
  seeds.update(secondsSinceLastUpdate);
  tileChanger.update(secondsSinceLastUpdate);
  
  if (!PAINT_MODE)
  {
    gridTiles.draw();
  }
  
  lastEndTick = millis();
  
  if (display_tree) {
    drawTree();
  } else {
    if (display_silhouette)
    {
      drawSilhouette();
    }
  }

  if (!ROTATE_DISPLAY) {
    dg.popMatrix();
  }
    
  if (edit_mode || display_leaf_system) {
     leafs.displaySpawnData();
  }

  if (display_leaves) {
    leafs.draw();
  }
  
  if (crop_line || draw_crop_line) {
    dg.pushStyle();
      dg.stroke(255,0,0);
      dg.line(cropX,0,cropX,height);
    dg.popStyle();
  }
  
  seeds.draw();
  
  //dg.endDraw();
  //clear();
  //image(dg,0,0,width,height);
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
  dg.save("screenCap/fallingLeaves-"+year()+"-"+month()+"-"+day()+":"+hour()+":"+minute()+":"+second()+":"+millis() +".png");
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
  if (ifKeyPair(key,'s','S')) {
    display_silhouette ^= true;
  }
  if (ifKeyPair(key,'e','E')) {
    if (edit_mode) {
      leafs.finishSpawnMask();
      CreateLeafSystem();
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

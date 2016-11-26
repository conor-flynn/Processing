    Camera camera;    
    World world;
// --------------------------------------
        
    void settings() {
        float reduction = 0.45;
        width  = (int)(displayWidth  * reduction);
        height = (int)(displayHeight * reduction);
        size(width, height);
    }
    
    void setup() {
        noStroke();
        smooth();
        // ----
        surface.setResizable(true);
        // ----
        world = new World();
    }
     
    void draw () {
        // ----
        background(0,0,0);
        scale(1,-1);
        translate(0, -height);
        // ----
        world.preDraw();
        world.draw();
        world.postDraw();
    }

    void mousePressed() {
        world.mousePressed();
    }
    
    void mouseDragged(MouseEvent event) {
        world.mouseDragged(event);
    }
    
    void mouseReleased() {
        world.mouseReleased();
    }
    
    void mouseWheel(MouseEvent event) {
        world.mouseWheel(event);
    }
    
    void keyPressed() {
        world.keyPressed();
    }
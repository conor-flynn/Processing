    Camera camera;    
    World world;
// --------------------------------------
        
    void settings() {
        float reduction = 0.85;
        width  = (int)(displayWidth  * reduction);
        height = (int)(displayHeight * reduction);
        size(width, height);
    }
    
    void setup() {
        noStroke();
        smooth();
        frameRate(6000);
        // ----
        world = new World();
        camera = new Camera(world);
    }
     
    void draw () {
        // ----
        background(0,0,0);
        scale(1,-1);
        translate(0, -height);
        camera.draw();
        // ----
        world.draw();
    }

    void mousePressed() {
        camera.mousePressed();
    }
    
    void mouseDragged(MouseEvent event) {
        camera.mouseDragged(event);
    }
    
    void mouseReleased() {
        camera.mouseReleased();     
    }
    
    void mouseWheel(MouseEvent event) {
        camera.mouseWheel(event);
    }
    
    void keyPressed() {
        if (key == 'r') {
            camera.resetPosition();
        }
    }
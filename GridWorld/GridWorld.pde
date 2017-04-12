    Camera camera;    
    World world;
// --------------------------------------
                
    void settings() {
        //randomSeed(0);
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
        // ----
    }
     
    void draw () {
        
        // ----
        if (Settings.DRAW_SIMULATION) {
            if (FORCE_REDRAW || Settings.ALWAYS_REDRAW) {
                background(0,0,0);
            }
            scale(1,-1);
            translate(0, -height);
        }
        // ----
        world.preDraw();
        world.draw();
        world.postDraw();
        FORCE_REDRAW = false;
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
    
    
    int modu(int a, int b) {
        int val = a % b;
        if (val < 0) {
            return (val + b);
        }
        return val;
    }    
    int get_rotated_x(int x, int y, int direction) {
        float degrees = 90 * direction;
        float angle = (degrees / 180.0) * PI;
        return round( ((float)x * cos(angle)) - ((float)y * sin(angle)) );
    }
    float get_rotated_x(float x, float y, int direction) {
        float degrees = 90 * direction;
        float angle = (degrees / 180.0) * PI;
        return (((float)x * cos(angle)) - ((float)y * sin(angle)));
    }
    int get_rotated_y(int x, int y, int direction) {
        float degrees = 90 * direction;
        float angle = (degrees / 180.0) * PI;
        return round( ((float)x * sin(angle)) + ((float)y * cos(angle)) );
    }
    float get_rotated_y(float x, float y, int direction) {
        float degrees = 90 * direction;
        float angle = (degrees / 180.0) * PI;
        return (((float)x * sin(angle)) + ((float)y * cos(angle)));
    }
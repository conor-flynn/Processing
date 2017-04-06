    Camera camera;    
    World world;
// --------------------------------------
        
    int frames_since_report = 0;
        
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
        previous_draw = millis();
        // ----
    }
     
    long previous_draw;
    void draw () {
        frames_since_report++;
        
        long elapsed_time = millis() - previous_draw;
        
        if (elapsed_time > (Settings.TIME_PER_REPORT * 1000)) {
            
            float frames_per_second = ((float)frames_since_report) / (elapsed_time / 1000);
            println("Time elapsed(" + ((float)elapsed_time/1000) + "), Frames since report(" + frames_since_report + "), Frames per second(" + frames_per_second + ")");
            
            frames_since_report = 0;
            previous_draw = millis();
        }
        
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
    int get_rotated_y(int x, int y, int direction) {
        float degrees = 90 * direction;
        float angle = (degrees / 180.0) * PI;
        return round( ((float)x * sin(angle)) + ((float)y * cos(angle)) );
    }
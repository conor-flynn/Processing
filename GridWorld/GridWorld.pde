    Camera camera;    
    World world;
// --------------------------------------
        
    float time_since_report = 0;
    int frames_since_report = 0;
        
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
        frames_since_report++;
        if (time_since_report > Settings.TIME_PER_REPORT) {
            float frames_per_second = ((float)frames_since_report) / ((float)Settings.TIME_PER_REPORT);
            time_since_report -= Settings.TIME_PER_REPORT;
            println("Time elapsed(" + Settings.TIME_PER_REPORT + "), Frames since report(" + frames_since_report + "), Frames per second(" + frames_per_second + ")");
            frames_since_report = 0;
        }
        time_since_report += (1 / frameRate);   
        
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
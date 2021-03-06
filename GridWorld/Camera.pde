    class Camera {
      
        PVector botLeft, botRight, topLeft, topRight;
      
        boolean mouseDown;
        PVector dragStart;
        PVector location;
        PVector worldCenter;
        float zoomLevel;
        
        public Camera() {
            mouseDown = false;
            dragStart = new PVector();
            location = new PVector();
            zoomLevel = -1;
              
            float part = Settings.WORLD_WIDTH / 8.0;
            worldCenter = new PVector(-part, -part);
            
            resetPosition();
        }
        
        void resetPosition() {
            location.x = width/2;
            location.y = height/2;
            
            location.x += worldCenter.x;
            location.y += worldCenter.y;
            
            zoomLevel = .5;
            
            
            
            // ----
            location.x = 228;
            location.y = 14.65;
            zoomLevel = 0.3113;
        }
        
        void draw() {
            translate(location.x, location.y);
            scale(zoomLevel);
        }
        
        void mousePressed() {
        }
        
        void mouseDragged(MouseEvent event) {
            location.x += mouseX - pmouseX;
            location.y -= mouseY - pmouseY;
        }
        
        void mouseReleased() { 
        }
        
        void mouseWheel(MouseEvent event) {
            location.x -= mouseX;
            location.y -= (height - mouseY);
            
            float speed = 1.05;
            float zoomIn = speed;
            float zoomOut = 1.0 / speed;
            
            float delta = event.getCount() > 0 ? zoomOut : event.getCount() < 0 ? zoomIn : 1.0;
            
            zoomLevel *= delta;
            location.x *= delta;
            location.y *= delta;
            
            location.x += mouseX;
            location.y += (height - mouseY);
        }
        
        void keyPressed() {
            if (key == 'r') {
               resetPosition(); 
            } else if (key == 'k') {
               println("Location offset : (" + location.x + "," + location.y + ")");
               println("Zoom : (" + zoomLevel + ")");
            }
        }
    }
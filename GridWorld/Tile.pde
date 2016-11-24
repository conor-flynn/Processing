    class Tile {
        int x;
        int y;
        int w;
        color c;
        
        int worldIndex;
        
        HashMap<Integer, Tile> neighbors;
        
        
        // ----
        Creature creature;
        // ----
        
        
        public Tile(int xx, int yy, int ww, color cc, int index) {
            x = xx;
            y = yy;
            w = ww;
            c = cc;
            worldIndex = index;
            neighbors = new HashMap<Integer, Tile>();
            // ----
            creature = null;
        }
        
        void draw() {
            if (creature != null && creature.tile != this) {
                println("Tile has a creature, but creature doesn't have tile");
                return;
            }
            fill(c);
            rect(x-w/2,y-w/2,w,w);
        } 
        
        String print() {
            return "(" + x + "," + y + ")";
        }
        
        void update() {
          
        }
    }
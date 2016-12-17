    class Tile {
        int x;
        int y;
        int w;
        Biome biome;
        
        int worldIndex;
        
        HashMap<Integer, Tile> neighbors;
        
        
        // ----
        Creature creature;
        // ----
        
        
        public Tile(int xx, int yy, int ww, int index, Biome biome) {
            x = xx;
            y = yy;
            w = ww;
            this.biome = biome;
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
            color c = color(
                      biome.color_red   * biome.tile_intensity, 
                      biome.color_green * biome.tile_intensity, 
                      biome.color_blue  * biome.tile_intensity);
            fill(c);
            rect(x-w/2,y-w/2,w,w);
        } 
        
        String print() {
            return "(" + x + "," + y + ")";
        }
        
        void update() {
          
        }
    }
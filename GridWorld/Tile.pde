    class Tile {
        int x;
        int y;
        int w;
        Biome biome;
        boolean shouldRedraw;
        
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
            shouldRedraw = true;
        }
        
        void draw() {
            if (FORCE_REDRAW || shouldRedraw) {
                color c = color(
                          biome.color_red   * biome.tile_intensity, 
                          biome.color_green * biome.tile_intensity, 
                          biome.color_blue  * biome.tile_intensity);
                fill(c);
                rect(x-w/2,y-w/2,w,w);
                shouldRedraw = false;
            }
        } 
        
        float getEvaluation() {
            if (creature == null) {
                float r = (biome.color_red * biome.tile_intensity)/255.0;
                float g = (biome.color_green * biome.tile_intensity)/255.0;
                float b = (biome.color_blue * biome.tile_intensity)/255.0;                
                return (r + g + b) * 0.25;
            } else {
                float r = creature.red;
                float g = creature.green;
                float b = creature.blue;
                float v = creature.life / 10;
                if (v > 1) v = 1;
                return (((r+g+b)/255)+v)*0.25;
            }
        }
        
        String print() {
            return "(" + x + "," + y + ")";
        }
        
        void update() {
          
        }
    }
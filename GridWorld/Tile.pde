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
        
        float get_tile_evaluation_by_channel(int index) {
            assert(index >= 0 && index <= 2);
            switch(index) {
                case 0:
                    return (biome.color_red * biome.tile_intensity)/255.0;
                case 1:
                    return (biome.color_green * biome.tile_intensity)/255.0;
                case 2:
                    return (biome.color_blue * biome.tile_intensity)/255.0;
            }
            assert(false);
            return 0f;
        }
        float get_tile_evaluation_by_channel_of_creature(int index) {
            if (creature == null) return 0f;
            
            switch(index) {
                case 0:
                    return creature.red;
                case 1:
                    return creature.green;
                case 2:
                    return creature.blue;
            }
            assert(false);
            return 0f;
        }        
        String print() {
            return "(" + x + "," + y + ")";
        }
        
        void update() {
          
        }
    }
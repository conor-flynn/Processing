    class Tile {
        // ----
        int x;
        int y;
        int w;
        // ----
        Biome biome;
        // ----
        boolean shouldRedraw;
        int worldIndex;
        // ----
        ArrayList<Tile> neighbors;
        // ----
        Creature creature;
        // ----
        boolean isFood;
        long respawn_frame;
        Tile younger_tile;
        Tile older_tile;
        boolean isRespawning;
        int active_neighbors;
        // ----
        World world;
        // ----
        
        
        public Tile(int xx, int yy, int ww, int index, Biome biome, World world) {
            // ----
            this.x = xx;
            this.y = yy;
            this.w = ww;
            this.biome = biome;
            this.worldIndex = index;
            // ----
            this.creature = null;
            this.shouldRedraw = true;
            // ----
            this.respawn_frame = -1;
            this.younger_tile = null;
            this.older_tile = null;
            this.isRespawning = false;
            this.isFood = false;
            // ----
            this.neighbors = new ArrayList<Tile>();
            // ----
            this.world = world;
            // ----
        }
        // TODO : Randomize the arrangement of neighbors
        void load_neighbors() {
            int xx = get_x_index();
            int yy = get_y_index();
            for (int x = -1; x <= +1; x++) {
                for (int y = -1; y <= +1; y++) {
                    if (x == 0 && y == 0) continue;
                    Tile temp = world.get_tile_at_point(xx+x, yy+y);
                    if (temp != null) {
                        neighbors.add(temp);
                    }
                }
            }
        }
        int get_x_index() {
            return (worldIndex - (worldIndex / Settings.NUM_TILES)*(Settings.NUM_TILES));   
        }
        int get_y_index() {
            return (worldIndex / Settings.NUM_TILES);
        }
        void draw() {
            //if (FORCE_REDRAW || shouldRedraw) { 
                float[] cc = get_color();
                color c = color(
                          cc[0], 
                          cc[1], 
                          cc[2]);
                fill(c);
                rect(x-w/2,y-w/2,w,w);
                shouldRedraw = false;
            //}
        }
        void debug_draw(color c, int d) {
            if (!Settings.DRAW_SIMULATION) return;
            fill(c);
            rect(x-(w*d), y-(w*d), w*d*2, w*d*2);
        }
        float[] get_color() {
            float[] tile = biome.get_tile_color();
            float[] result = new float[3];
            result[0] = tile[0];
            result[1] = tile[1];
            result[2] = tile[2];
            if (creature == null) {
                if (isFood) {
                    // blend between food and tile
                    float[] food = biome.get_food_color();
                    float v1 = 0.1f;
                    float v2 = 1 - v1;
                    
                    result[0] = (v1)*(result[0]) + (v2)*(food[0]);
                    result[1] = (v1)*(result[1]) + (v2)*(food[1]);
                    result[2] = (v1)*(result[2]) + (v2)*(food[2]);                    
                }
                return result;
            } else {
                float[] cre = creature.get_color(); 
                float v1 = 0.1f;
                float v2 = 1 - v1;
                    result[0] = (v1)*(result[0]) + (v2)*(cre[0]);
                    result[1] = (v1)*(result[1]) + (v2)*(cre[1]);
                    result[2] = (v1)*(result[2]) + (v2)*(cre[2]);
                return result;
            }
        }
        void killFood() {
            this.isFood = false;
            this.isRespawning = false;
            this.shouldRedraw = true;
        }
        float eatFood(float[] stomach_type) {
            
            assert(isFood);
            assert(creature == null);
            
            float[] food_type = biome.get_food_type();
            float result = getFoodFertility();
            float difference = 0;
            for (int i = 0; i < food_type.length; i++) {
                difference += ((2.0 / food_type.length) * abs(food_type[i] - stomach_type[i]));
            }
            // difference: [0.0, 2.0]
            killFood();
            update_neighbors();
            try_respawn(false);
            
            float answer = (result * (1.0 - difference));
            assert(answer >= 0 && answer <= 1);
            
            return answer;
        }
        void creatureLeaving(Creature creature) {
            assert(this.creature != null && this.creature == creature && this.creature.tile == this);
            this.creature.tile = null;
            this.creature = null;
        }
        void creatureEntering(Creature creature) {
            assert(this.creature == null && creature.tile == null);
            
            this.creature = creature;
            this.creature.tile = this;
            debug_draw(color(255,255,0), 2);
            /*
            if (isFood) {
                killFood();
                update_neighbors();
                try_respawn(false);
            }
            */
        }
        void update_neighbors() {
            int change = -1;
            assert(isFood == false);
            if (isRespawning) {
                change = 1;
            }
            for (Tile t : neighbors) {
                t.active_neighbors += change;
                assert(t.active_neighbors >= 0);
            }
        }
        void try_respawn(boolean immediately) {
            if (isFood || isRespawning) return;
            
            for (Tile t : neighbors) {
                t.try_respawn_self(immediately);
            }
            this.try_respawn_self(immediately);
        }
        void try_respawn_self(boolean immediately) {
            if (isFood || isRespawning) return;
            // Try and respawn this tile
            if (active_neighbors <= biome.get_food_neighbors()) {
                if (random(1) > 0.8f) {
                    if (immediately) {
                        respawn_frame = 0;
                    } else {
                        int delta = biome.get_food_respawn_time();
                        float multiplier = random(0.5, 2);
                        delta = (int)(delta * multiplier);
                        respawn_frame = world.generation + delta;
                    }
                    world.add_tile_to_queue(this);
                    update_neighbors();
                }
            }
        }
        
        
        
        
        
        
        
        
        
        
        
        
        
        float getFoodFertility() {
            return biome.get_food_fertility();   
        }
        boolean isFertile() {
            int limit = biome.get_food_neighbors();
            int time = biome.get_food_respawn_time();
            return ((limit >= 0) && (time > 0));
        }
        float get_color_by_channel(int channel) {
            assert(channel >= 0 && channel <= 2);
            float[] c = get_color();
            return c[channel] / 255.0;
        }
        float getMovementResistance(float[] creature_type) {
            
            float[] tile_type = biome.get_tile_type();
            float difference = 0;
            for (int i = 0; i < tile_type.length; i++) {
                difference += ((1.0 / tile_type.length) * abs(tile_type[i] - creature_type[i]));
            }
            assert(difference >= 0);
            return difference;   
        }
    }
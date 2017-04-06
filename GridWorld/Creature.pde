class Creature {
    Species species;
    
    Brain brain;
    
    Tile tile;
    float red,green,blue;
    
    float life;
    int age;
    int generation;
    boolean markedForDeath;   
    
    int asexual_reproductive_count = 0;
    int sexual_reproductive_count = 0;
    
    int direction;
    
    
    public Creature(Species species) {
        this.species = species;
      
        markedForDeath = false;
        red = green = blue = -1;
          
        brain = null;
        life = -1;
        age = 0;
        generation = 0;
    }
    void killCreature() {
        if (markedForDeath) return;
        markedForDeath = true;
        species.preGrave.add(this);
        this.life = 0;
    }
    float get_loss() {
        float multiplier = (1f) + (brain.brain_size() / 150.0f);
        float amount = (1 / Settings.CREATURE_STARVATION_TIMER) * multiplier;
        float resist = tile.getMovementResistance(brain.tile_type);
        assert(resist >= 0);
        amount += resist;
        assert(amount > 0);
        return amount;
    }
    boolean lose_standard_life() {
        float amount = get_loss();
        this.life -= amount;
        if (this.life <= 0) {
            killCreature();
            return true;
        }
        return false;
    }
    void add_life(float amount) {
        if (amount > 0) {
            tile.debug_draw(color(0,0,0),7);
        }
        this.life += amount;
        if (this.life > Settings.CREATURE_MAX_FOOD) {
            float over = (this.life - Settings.CREATURE_MAX_FOOD);
            over *= Settings.OVER_EAT_PUNISHMENT;
            assert(over >= 0);
            this.life = Settings.CREATURE_MAX_FOOD;
            this.life -= over;
        }
        if (this.life <= 0) {
            killCreature();
        }
    }
    
    
    
    
    
    
    
    
    
    void update() {
        assert(tile != null);
        assert(brain != null);
        assert(this.life <= Settings.CREATURE_MAX_FOOD);
        if (markedForDeath) return;

        
        if (lose_standard_life()) return;
        
        assert(this.life > 0);
        age++;
        if (asexual_reproductive_count >= Settings.CREATURE_ASEXUAL_REPRODUCTIVE_LIMIT) {
            killCreature();
            return;
        }
        if (sexual_reproductive_count >= Settings.CREATURE_SEXUAL_REPRODUCTIVE_LIMIT) {
            killCreature();
            return;
        }
        if (age > Settings.CREATURE_DEATH_AGE) {
            killCreature();
            return;
        }
        
        brain.process();
        ArrayList<Float> results = brain.process_results;
        assert(results.size() == (4));
        
        float mov_x = results.get(0);
        float mov_y = results.get(1);
        
        float a_sex = results.get(2);
        
        float direction = results.get(3);
        
        assert(abs(mov_x) <= 1);
        assert(abs(mov_y) <= 1);
        assert(abs(a_sex) <= 1);
        assert(abs(direction) <= 1);
        
        if (abs(direction) > Settings.CREATURE_MINIMUM_ACTION_THRESHOLD) {
            alter_direction(direction);   
        }
        
        if (a_sex > 0) {
            asexually_reproduce();
        } else {
            tryMove(mov_x, mov_y);   
        }
    }
    void alter_direction(float amount) {
        if (amount < 0) {
            int val = ceil(amount / Settings.CREATURE_MINIMUM_ACTION_THRESHOLD);
            direction += val;
            direction = modu(direction, 4);
            assert(direction >= 0 && direction <= 3);
        } else {
            int val = floor(amount / Settings.CREATURE_MINIMUM_ACTION_THRESHOLD);
            direction += val;
            direction = modu(direction, 4);
            assert(direction >= 0 && direction <= 3);
        }
    }
    void asexually_reproduce() {
        if (markedForDeath) return;
        
        if (this.life <= Settings.CREATURE_ASEXUAL_REPRODUCTION_COST) {
            killCreature();
            return;
        }
        
        int hope_x = -1;
        int hope_y = 0;
        int x_tile = get_rotated_x(hope_x, hope_y, direction);
        int y_tile = get_rotated_y(hope_x, hope_y, direction);
        x_tile += tile.get_x_index();
        y_tile += tile.get_y_index();
        
        Tile target = species.world.get_tile_at_point(x_tile, y_tile);
        if (target == null || target.creature != null) {
            killCreature();
            return;
        }
        
        Creature newCreature = new Creature(species);
            newCreature.brain = new Brain(brain, newCreature);
            newCreature.copy_color(this);            
            newCreature.brain.mutate_count(1);
            newCreature.tile = null;
            
        target.creatureEntering(newCreature);
                 
            newCreature.generation = generation+1;
            newCreature.life = Settings.CREATURE_BIRTH_FOOD;
        species.creatures.add(newCreature);
        add_life(-Settings.CREATURE_ASEXUAL_REPRODUCTION_COST);
        asexual_reproductive_count++;
        species.world.asexual_reproduction++;
        tile.debug_draw(color(255,0,255),5);
    }
    void cross_with(Creature other) {
        assert(this.life > Settings.CREATURE_SEXUAL_REPRODUCTION_COST);
        assert(other.life > Settings.CREATURE_SEXUAL_REPRODUCTION_COST);
        
        int hope_x = 0;
        int hope_y = -1;
        int tile_x = get_rotated_x(hope_x, hope_y, direction);
        int tile_y = get_rotated_y(hope_x, hope_y, direction);
        tile_x += tile.get_x_index();
        tile_y += tile.get_y_index();
        
        Tile target = species.world.get_tile_at_point(tile_x, tile_y);
        if (target == null || target.creature != null) {
            killCreature();
            other.killCreature();
            return;
        }
        
        Creature newCreature = new Creature(species);
            newCreature.brain = new Brain(this.brain, other.brain, newCreature);
            newCreature.copy_color(this);            
            newCreature.brain.mutate_count(1);
            newCreature.tile = target;
            newCreature.tile.creature = newCreature;     
            newCreature.generation = generation+1;
            newCreature.life = Settings.CREATURE_BIRTH_FOOD;
        species.creatures.add(newCreature);
        
        this.add_life(-Settings.CREATURE_SEXUAL_REPRODUCTION_COST);
        assert(this.life > 0);
        other.add_life(-Settings.CREATURE_SEXUAL_REPRODUCTION_COST);
        assert(other.life > 0);
        sexual_reproductive_count++;
        species.world.sexual_reproduction++;
        tile.debug_draw(color(255,255,255),5);
    }
    boolean tryMove(float xx, float yy) {
        if (markedForDeath) return false;
                
        int x_delta = 0;
        int x_movement = 0;
        if (abs(xx) < Settings.CREATURE_MINIMUM_ACTION_THRESHOLD) {
            x_delta = 0;
        } else {
            x_delta = approx_to_exact(xx);
        }
        int y_delta = 0;
        int y_movement = 0;
        if (abs(yy) < Settings.CREATURE_MINIMUM_ACTION_THRESHOLD) {
            y_delta = 0;
        } else {
            y_delta = approx_to_exact(yy);
        }
        if (x_delta == 0 && y_delta == 0) return false;
        
        if (x_delta > 0) x_movement = x_delta+1;
        if (x_delta < 0) x_movement = x_delta-1;
        if (y_delta > 0) y_movement = y_delta+1;
        if (y_delta < 0) y_movement = y_delta-1;
        
        int x_tile = get_rotated_x(x_delta, y_delta, direction);
        int y_tile = get_rotated_y(x_delta, y_delta, direction);
        int next_x_tile = get_rotated_x(x_movement, y_movement, direction);
        int next_y_tile = get_rotated_y(x_movement, y_movement, direction);
        
        
        x_tile         += tile.get_x_index();
        y_tile         += tile.get_y_index();
        next_x_tile    += tile.get_x_index();
        next_y_tile    += tile.get_y_index();
        
        
        assert(abs(x_tile - next_x_tile) <= 1);
        assert(abs(y_tile - next_y_tile) <= 1);
        
        
        Tile target = species.world.get_tile_at_point(x_tile, y_tile);
        if (target == null) {
            // Trying to move to a tile that doesn't exist.
            killCreature();
            return false;
        }
        
        if (target.creature == null) {
            // Trying to move to an empty tile
            
            move_to_empty_tile(target);
            
            Tile next_target = species.world.get_tile_at_point(next_x_tile, next_y_tile);
            if (next_target == null) {
                // The next tile doesn't exist.
            } else {
                if (next_target.creature == null) {
                    // The next tile doesn't have a creature
                    if (next_target.isFood) {
                        eat_food_at_empty_tile(next_target);
                    }
                } else {
                    // The next tile has a creature
                    eat_creature(next_target.creature);
                }
            }
        } else {
            // Moving to a tile with a creature
            species.world.tryToSexuallyReproduce(this, target.creature);
        }
        return true;
    }
    void move_to_empty_tile(Tile destination) {
        
        int current_x = tile.get_x_index();
        int current_y = tile.get_y_index();
        int target_x = destination.get_x_index();
        int target_y = destination.get_y_index();
        
        assert( abs(current_x - target_x) <= 1 );
        assert( abs(current_y - target_y) <= 1 );
        
        float val = tile.getMovementResistance(brain.tile_type);
        assert(val >= 0);
        add_life(-val);
        tile.creatureLeaving(this);
        destination.creatureEntering(this);
    }
    void eat_food_at_empty_tile(Tile destination) {
        float val = destination.eatFood(brain.food_type);
        species.world.plantMatterConsumed += val;
        add_life(val);
        tile.debug_draw(color(0,255,0),5);
    }
    void eat_creature(Creature target) {
        if (target.markedForDeath) return;
        if (target.life <= 0) {
            target.killCreature();
            return;
        }
        species.world.creatureMatterConsumed += target.life;
        add_life(target.life * Settings.CREATURE_EAT_CREATURE_MULTIPLIER);
        target.killCreature();
        tile.debug_draw(color(255,0,0),5);
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
        
    float sig(float input) {
        float denom = 1 + exp(-input);
        return 1.0 / denom;
    }    
    float negsig(float input) {
       float val = sig(input); 
       val *= 2;
       return val-1;
    }    
    void buildColor() {
       red = random(255);
       green = random(255);
       blue = random(255);
    }    
    float clamp(float val, float lower, float upper) {
       if (val < lower) return lower;
       if (val > upper) return upper;
       return val;
    }
    void copy_color(Creature target) {
        red = target.red;
        green = target.green;
        blue = target.blue;
    }
    void mutate_color(float delta) {
        /*
        float delta = 2;
        float d1 = random(delta) - (delta/2);
        float d2 = random(delta) - (delta/2);
        float d3 = random(delta) - (delta/2);
        */
        float val = delta;
        float d1 = random(-val, +val);
        float d2 = random(-val, +val);
        float d3 = random(-val, +val);
        
        red   += d1;
        green += d2;
        blue  += d3;
        
        red = clamp(red, 0, 255);
        green = clamp(green, 0, 255);
        blue = clamp(blue, 0, 255);
    }
    int approx_to_exact(float val) {
        return (int)roundAway(val);   
    }
    float roundAway(float val) {
        if (val < 0) {
            return floor(val); 
        } else {
            return ceil(val);
        }
    }
    float[] get_color() {
        float[] cc = new float[3];
        cc[0] = red;
        cc[1] = green;
        cc[2] = blue;
        return cc;
    }
    
    
    
    
    
    
    
    
    
    
    void draw() {
      
        if (tile == null) {
            println("Invalid tile for this creature");
            return;
        }
        
        int x = tile.x;
        int y = tile.y;
        int w = tile.w;
        
        //y = (Settings.NUM_TILES * Settings.TILE_WIDTH) - y;
        
        x += 5;
        y += 5;
        
        x -= w/2;
        y -= w/2;     
        
        w -= 10;
        fill(color(red, green, blue));        
        rect(x,y,w,w);
        draw_facing_direction();
        draw_brain();
    }
    void draw_brain() {
        int xx = tile.get_x_index();
        int yy = tile.get_y_index();
        for (Input input : brain.world_inputs) {
            WorldConnection spot = input.connection;
            int newx = get_rotated_x(spot.x, spot.y, direction) + xx;
            int newy = get_rotated_y(spot.x, spot.y, direction) + yy;
            int channel = input.channel;
            draw_world_connection(newx, newy, xx, yy, channel);
        }
    }
    void draw_world_connection(int dx, int dy, int ox, int oy, int channel) {
        // destination x, destination y, origin x, origin y, creature/tile, R G or B
        //Tile origin = world.get_tile_at_point(ox, oy);
        //assert(origin != null);
        
        float destx = world.get_tile_posx_by_index(dx);
        float desty = world.get_tile_posy_by_index(dy);
        
        float originx = world.get_tile_posx_by_index(ox);
        float originy = world.get_tile_posy_by_index(oy);
        
        if (channel == 0) {
            stroke(255,0,0);
        } else if (channel == 1) {
            stroke(0,255,0);
        } else if (channel == 2) {
            stroke(0,0,255);
        }
        strokeWeight(3);
        line(originx, originy, destx, desty);
    }
    void draw_facing_direction() {
        int dirx = 0;
        int diry = 0;
        if (direction == 0) {
            dirx = 0;
            diry = 1;
        } else if (direction == 1) {
            dirx = 1;
            diry = 0;
        } else if (direction == 2) {
            dirx = 0;
            diry = -1;
        } else if (direction == 3) {
            dirx = -1;
            diry = 0;
        }
        stroke(255,255,255);
        strokeWeight(0);
        int centerx = (int)(tile.x);
        int centery = (int)(tile.y);
        int line_length = 20;
        dirx *= line_length;
        diry *= line_length;
        line(centerx, centery, centerx+dirx, centery+diry);
    }
    /*
    HashMap<Integer, Tile> getValidNeighbors() {
        HashMap<Integer, Tile> result = new HashMap<Integer, Tile>();
        
        for (Map.Entry me : tile.neighbors.entrySet()) {
              int dir = (int)me.getKey();
              Tile t = (Tile)me.getValue();
              
              if (t.creature != null) continue;
              if (t instanceof Food) continue;
              
              result.put(dir, t);
        }
        return result;
    }
    */
    /*
    HashMap<Integer, Food> getNearbyFoods() {
        HashMap<Integer, Food> result = new HashMap<Integer, Food>();
     
        for (Map.Entry me : tile.neighbors.entrySet()) {
            int dir = (int)me.getKey();
            Tile t = (Tile)me.getValue();
            if (t instanceof Food) {
                Food f = (Food)t;
                if (f.current_life > 0.3)
                result.put(dir, (Food)t);
            }
        }
        return result;
    }
    */
    /*
    Tile findReproductionTile() {
        Tile result;
        Set<Integer> points = new HashSet<Integer>();
        ArrayList<Integer> keys = new ArrayList<Integer>(tile.neighbors.keySet());
        do {
          if (points.size() == keys.size()) return null;
          
          int choice = (int)random(keys.size());
          if (points.contains(choice)) continue;
          points.add(choice);
          
          int _key = keys.get(choice);
          Tile target = tile.neighbors.get(_key);
          if (!(target instanceof Food) && target.creature == null) {
              return target;
          }
        } while (true);
    }
    */
    /*
    void print() {      
        println(tile.print());
    }
    */
}
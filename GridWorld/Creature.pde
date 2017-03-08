class Creature {
    Species species;
  
    Brain brain;
  
    Tile tile;
    float red,green,blue;
    
    float life;
    int age;
    int generation;
    boolean markedForDeath;    
    int reproductive_count;
    
    
    
    public Creature(Species species) {
        this.species = species;
      
        markedForDeath = false;
        red = green = blue = -1;
          
        brain = null;
        life = Settings.FOOD_BIRTH_FOOD;
        age = 0;
        generation = 0;
        
        
        reproductive_count = 0;
    }
    
    void killCreature() {
        //assert(!markedForDeath);
        if (markedForDeath) return;
        markedForDeath = true;
        species.preGrave.add(this);
        this.life = 0;
    }
    float get_loss() {
        float multiplier = (1f);// + (species.creatures.size() / 650f);
        float amount = (1 / Settings.CREATURE_STARVATION_TIMER) * multiplier * (brain.brain_size_multiplier());
        return amount;
    }
    boolean lose_standard_life() {
        float amount = get_loss();
        species.world.lossToLifeByAging += amount;
        this.life -= amount;
        if (this.life <= 0) {
            killCreature();
            return true;
        }
        return false;
    }
    
    
    
    
    
    
    
    
    
    void update() {
        assert(tile != null);
        assert(brain != null);
        if (markedForDeath) return;
        
        if (lose_standard_life()) return;
        
        age++;
        if (reproductive_count >= Settings.CREATURE_REPRODUCTIVE_LIMIT) {
            killCreature();
            return;
        }
        if (age > Settings.CREATURE_DEATH_AGE) {
            killCreature();
            return;
        }
        
        brain.process();
        ArrayList<Float> results = brain.process_results;
        assert(results.size() == (6+2));
        
        float mov_x = results.get(0);
        float mov_y = results.get(1);
        
        float rep_x = results.get(2);
        float rep_y = results.get(3);
        
        float kil_x = results.get(4);
        float kil_y = results.get(5);
        
        boolean action = false;
        boolean res = false;
        
        res = tryKill(kil_x, kil_y);
        action = action || res;
        if (markedForDeath) return;
        res = tryReproduce(rep_x, rep_y);
        action = action || res;
        if (markedForDeath) return;
        res = tryMove(mov_x, mov_y);
        action = action || res;
        if (markedForDeath) return;
        //println(this.life + ": (" + mov_x + "," + mov_y + "), (" + rep_x + "," + rep_y + "), (" + kil_x + "," + kil_y + ")");
        
        if (!action && !markedForDeath) {
            float amount = get_loss() * 0.85f;
            species.world.lossToLifeByAging -= amount;
            this.life += amount;
            return;   
        }
    }
    void add_life(float amount) {
        this.life += amount;
        if (this.life > Settings.CREATURE_MAX_FOOD) {
            float over = (this.life - Settings.CREATURE_MAX_FOOD);
            over *= Settings.OVER_EAT_PUNISHMENT;
            this.life = Settings.CREATURE_MAX_FOOD;
            this.life -= over;
        }
        if (this.life > Settings.CREATURE_MAX_FOOD) {
            println(this.life);
            println(amount);
        }
        assert(this.life <= Settings.CREATURE_MAX_FOOD);
        if (this.life < 0) {
            killCreature();
        }
    }
    boolean tryKill(float xx, float yy) {
        if (markedForDeath) return false;
        
        
        int x_tile = 0;
        if (abs(xx) < Settings.CREATURE_MINIMUM_ACTION_THRESHOLD) {
            x_tile = 0;
        } else {
            x_tile = approx_to_exact(xx);
        }
        int y_tile = 0;
        if (abs(yy) < Settings.CREATURE_MINIMUM_ACTION_THRESHOLD) {
            y_tile = 0;
        } else {
            y_tile = approx_to_exact(yy);
        }
        if (x_tile == 0 && y_tile == 0) return false;
        x_tile += tile.get_x_index();
        y_tile += tile.get_y_index();
        
        
        
        Tile target = species.world.get_tile_at_point(x_tile, y_tile);
        if (this.tile == target) return true;
        if (target == null || target.creature == null || target.creature.markedForDeath) {
            return true;
        }
        
        float steal = target.creature.life;
        target.creature.killCreature();
        add_life(steal * Settings.CREATURE_EAT_CREATURE_MULTIPLIER);
        return true;
    }
    boolean tryReproduce(float xx, float yy) {
        if (markedForDeath) return false;
        
        
        int x_tile = 0;
        if (abs(xx) < Settings.CREATURE_MINIMUM_ACTION_THRESHOLD) {
            x_tile = 0;
        } else {
            x_tile = approx_to_exact(xx);
        }
        int y_tile = 0;
        if (abs(yy) < Settings.CREATURE_MINIMUM_ACTION_THRESHOLD) {
            y_tile = 0;
        } else {
            y_tile = approx_to_exact(yy);
        }
        if (x_tile == 0 && y_tile == 0) return false;
        x_tile += tile.get_x_index();
        y_tile += tile.get_y_index();
        
        
        if (this.life < Settings.CREATURE_REPRODUCTIVE_INEFFICIENCY_MULTIPLIER) {
            killCreature();
            return false;
        }
        
        
        
        Tile target = species.world.get_tile_at_point(x_tile, y_tile);
        if (target == null || this.tile == target || target.creature != null) {
            killCreature();
            return true;
        }
        if (target instanceof Food) {
            Food food = (Food)target;
            if (food.edible) {
                food.edible = false;
                food.trampled = Settings.FOOD_TRAMPLE_RECOVERY_AMOUNT;
                food.shouldRedraw = true;
            }
        }
        
        Creature newCreature = new Creature(species);
            newCreature.brain = new Brain(brain, newCreature);
            newCreature.copy_color(this);
            newCreature.brain.mutate_count(1);
            newCreature.tile = target;
            newCreature.tile.creature = newCreature;     
            newCreature.generation = generation+1;
            newCreature.life = Settings.CREATURE_BIRTH_FOOD;
        species.creatures.add(newCreature);
        
        add_life(-Settings.CREATURE_REPRODUCTIVE_INEFFICIENCY_MULTIPLIER);
        reproductive_count++;
        return true;
    }
    boolean tryMove(float xx, float yy) {
        if (markedForDeath) return false;
        
        int x_tile = 0;
        if (abs(xx) < Settings.CREATURE_MINIMUM_ACTION_THRESHOLD) {
            x_tile = 0;
        } else {
            x_tile = approx_to_exact(xx);
        }
        int y_tile = 0;
        if (abs(yy) < Settings.CREATURE_MINIMUM_ACTION_THRESHOLD) {
            y_tile = 0;
        } else {
            y_tile = approx_to_exact(yy);
        }
        if (x_tile == 0 && y_tile == 0) return false;
        x_tile += tile.get_x_index();
        y_tile += tile.get_y_index();
        
        
        Tile target = species.world.get_tile_at_point(x_tile, y_tile);
        if (target == null) {
            killCreature();
            return false;
        }
        
        if (target instanceof Food) {
            Food food = (Food)target;
            if (food.edible && (food.creature == null)) {
                eat_food_at_empty_tile(target);
                move_to_empty_tile(target);
            } else if (food.creature != null) {
                // What should we do???
                // Consume extra energy, but get nothing in return?
                food.creature.killCreature();
                killCreature();
                return true;
            } else {
                move_to_empty_tile(target);
            }
        } else {
            if (target.creature == null) {
                move_to_empty_tile(target);   
            } else {
                // What should we do???
                // Consume extra energy, but get nothing in return?
                target.creature.killCreature();
                killCreature();
                return true;
            }
        }
        return true;
    }
    void move_to_empty_tile(Tile destination) {
        
        tile.creature = null;
        tile.shouldRedraw = true;
        this.life -= (tile.biome.movement_resistance);
        
        species.world.lossToMovementResistance += (tile.biome.movement_resistance);
        
        tile = destination;
        tile.creature = this;  
        tile.shouldRedraw = true;
    }
    void eat_food_at_empty_tile(Tile destination) {
        Food food = (Food) destination;
        
        float amount = food.current_life;
        assert(amount <= 1);
        
        amount *= Settings.CREATURE_EAT_PLANT_MULTIPLIER;
        add_life(amount);
        food.current_life = 0;
        
        food.trampled = Settings.FOOD_TRAMPLE_RECOVERY_AMOUNT;
        food.edible = false;
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
    boolean similar_color(Creature target) {
        float d_red = abs(target.red - red);
        float d_green = abs(target.green - green);
        float d_blue = abs(target.blue - blue);
        
        return (d_red + d_green + d_blue) > Settings.CREATURE_COLOR_SIMILARITY_THRESHOLD;
    }
    
    
    
    
    
    
    
    
    
    
    void draw() {
      
        if (tile == null) {
            println("Invalid tile for this creature");
            return;
        }
        
        int x = tile.x;
        int y = tile.y;
        int w = tile.w;
        
        x += 5;
        y += 5;
        
        x -= w/2;
        y -= w/2;     
        
        w -= 10;
        fill(color(red, green, blue));        
        rect(x,y,w,w);
    }
    
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
    
    void print() {      
        println(tile.print());        
    }
}
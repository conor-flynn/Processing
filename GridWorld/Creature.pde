class Creature {
    Species species;
  
    Brain brain;
  
    Tile tile;
    float red,green,blue;
    
    float life;
    int age;
    int generation;
    boolean markedForDeath;
    
    float starting_life;
    
    int reproductive_count;
    
    
    public Creature(Species species) {
        this.species = species;
      
        markedForDeath = false;
        red = green = blue = -1;
        
        starting_life = 1;
          
        brain = null;
        life = starting_life;
        age = 0;
        generation = 0;
        
        
        reproductive_count = 0;
    }
    
    void killCreature() {
        if (markedForDeath) return;
        markedForDeath = true;
        species.preGrave.add(this);
    }
    
    void update() {
        assert(tile != null);
        assert(brain != null);
        if (markedForDeath) return;
        
        float multiplier = (1f) + (species.creatures.size() / 1000f);
        this.life -= (1 / Settings.CREATURE_STARVATION_TIMER) * multiplier * (brain.brain_size_multiplier());
        if (this.life <= 0) {
            killCreature();
            return;
        }
        age++;
        if (reproductive_count > Settings.CREATURE_REPRODUCTIVE_LIMIT) {
            killCreature();
            return;
        }
        if (age > Settings.CREATURE_DEATH_AGE) {
            killCreature();
            return;
        }
        
        brain.process();
        ArrayList<Float> results = brain.process_results;
        if (results.size() != (3 + 2)) {
        	return;   
        }
        float x = results.get(0);
        float y = results.get(1);
        float z = results.get(2);
        if (z < -Settings.CREATURE_MINIMUM_REPRODUCTIVE_THRESHOLD) {
            this.life += (1 / Settings.CREATURE_STARVATION_TIMER) * (0.25f);   
        }
        // TODO : If z is 0, then the creature shouldn't reproduce. It shou
        
        if (abs(x) >= Settings.CREATURE_MINIMUM_MOVEMENT_THRESHOLD || abs(y) >= Settings.CREATURE_MINIMUM_MOVEMENT_THRESHOLD) {
            tryMove(x,y);   
        } else if (abs(z) >= Settings.CREATURE_MINIMUM_REPRODUCTIVE_THRESHOLD) {
            tryReproduce();   
        }
    }
    
    float roundAway(float val) {
        if (val < 0) {
            return floor(val); 
        } else {
            return ceil(val);
        }
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
    void mutate_color() {
        /*
        float delta = 2;
        float d1 = random(delta) - (delta/2);
        float d2 = random(delta) - (delta/2);
        float d3 = random(delta) - (delta/2);
        */
        float val = 0.35f;
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
    
    void tryReproduce() {
        if (this.life < (Settings.CREATURE_BIRTH_FOOD*1.5f)) return;
      
        Tile openSpot = findReproductionTile();
        if (openSpot == null) return;
                
        Creature newCreature = new Creature(species);
            newCreature.brain = new Brain(brain, newCreature);
            newCreature.copy_color(this);
            newCreature.brain.mutate();
            newCreature.tile = openSpot;
            newCreature.tile.creature = newCreature;     
            newCreature.generation = generation+1;
        species.creatures.add(newCreature);
        
        newCreature.life = Settings.CREATURE_BIRTH_FOOD;
        life -= newCreature.life;
        if (life < 0) {
            killCreature();
            return;
        }
        reproductive_count++;
    }
    void move_to_empty_tile(Tile destination) {
        
        tile.creature = null;
        tile.shouldRedraw = true;
        this.life -= (tile.biome.movement_resistance);
        
        tile = destination;
        tile.creature = this;  
        tile.shouldRedraw = true;
    }
    void eat_creature_at_tile(Tile destination) {
        if (destination.creature.markedForDeath) return;
        if (destination.creature.life <= 0) return;
           
        float steal = destination.creature.life;
        destination.creature.killCreature();
        
        steal *= Settings.CREATURE_EAT_CREATURE_MULTIPLIER;
        life += steal;
        
        species.world.creatureMatterConsumed += steal;
        if (life > Settings.CREATURE_MAX_FOOD) {
            float over_eat = life - Settings.CREATURE_MAX_FOOD;
            life = Settings.CREATURE_MAX_FOOD;
            life -= (over_eat * Settings.OVER_EAT_PUNISHMENT);
        }
    }
    void eat_food_at_empty_tile(Tile destination) {
        Food food = (Food) destination;
        
        float amount = food.current_life;
        
        amount *= Settings.CREATURE_EAT_PLANT_MULTIPLIER;
        life += amount;
        
        species.world.plantMatterConsumed += amount;
        food.current_life = 0;
        if (life > Settings.CREATURE_MAX_FOOD) {
            float over_eat = life - Settings.CREATURE_MAX_FOOD;
            life = Settings.CREATURE_MAX_FOOD;
            life -= (over_eat * Settings.OVER_EAT_PUNISHMENT);
        }
        
        tile.creature = null;
        tile.shouldRedraw = true;
        
        tile = destination;
        tile.creature = this;
        tile.shouldRedraw = true;
        
        food.edible = false;
    }
    void eat_food_at_occupied_tile(Tile destination) {
        Food food = (Food) destination;
        if (food.creature.markedForDeath) return;
        if (food.creature.life <= 0) return;
        
        float steal = food.creature.life;
        food.creature.killCreature();
        
        steal *= Settings.CREATURE_EAT_CREATURE_MULTIPLIER;
        life += steal;
        
        species.world.creatureMatterConsumed += steal;
        if (life > Settings.CREATURE_MAX_FOOD) {
            float over_eat = life - Settings.CREATURE_MAX_FOOD;
            life = Settings.CREATURE_MAX_FOOD;
            life -= (over_eat * Settings.OVER_EAT_PUNISHMENT);
        }
    }
    void tryMove(float x, float y) {
      
        int xi = (int)roundAway(x);
        int yi = (int)roundAway(y);
        int direction = -1;
        if (xi < 0) {
           if (yi < 0) {
               direction = Direction.SOUTHWEST.val();
           } else if (yi == 0) {
               direction = Direction.WEST.val();
           } else if (yi > 0) {
               direction = Direction.NORTHWEST.val();
           }
        } else if (xi == 0) {
           if (yi < 0) {
               direction = Direction.SOUTH.val();
           } else if (yi == 0) {
               return;
           } else if (yi > 0) {
               direction = Direction.NORTH.val();
           }
        } else if (xi > 0) {
           if (yi < 0) {
               direction = Direction.SOUTHEAST.val();
           } else if (yi == 0) {
               direction = Direction.EAST.val();
           } else if (yi > 0) {
               direction = Direction.NORTHEAST.val();
           }
        }
        if (direction < 0) return;
        
        if (tile.neighbors.containsKey(direction)) {
            Tile target = tile.neighbors.get(direction);
            if (!(target instanceof Food)) {
               if (target.creature == null) {
                   move_to_empty_tile(target);
               } else {
                   eat_creature_at_tile(target);
               }               
            } else {
                Food food = (Food)target;
                if (food.edible && (food.creature == null)) {
                    eat_food_at_empty_tile(target);                    
                } else if (food.creature != null) {
                    eat_food_at_occupied_tile(target);
                } else {
                    move_to_empty_tile(target);
                }
            }
        } else { 
            killCreature();
        }
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
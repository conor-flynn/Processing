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
    
    int hasNotMoved;
    
    
    public Creature(Species species) {
        this.species = species;
      
        markedForDeath = false;
        red = green = blue = -1;
        
        starting_life = 1;
          
        brain = null;
        life = starting_life;
        age = 0;
        generation = 0;
        
        hasNotMoved = 0;        
    }
    
    void killCreature() {
        if (markedForDeath) return;
        markedForDeath = true;
        species.preGrave.add(this);
    }
    
    void update() {
        if (tile == null) {
            println("Creature with no tile");
            return;
        }
        if (brain == null) {
            println("Creature with no brain.");
            return;
        }
        if (markedForDeath) return;
        
        age++;
        if (age > Settings.CREATURE_DEATH_AGE) {
            killCreature();
            return;
        }
        
        float multiplier = (species.creatures.size() / 300);
        if (multiplier < 1.0f) multiplier = 1f;
        this.life -= (this.life * 0.01) * (multiplier) * (brain.brain_size_multiplier());
        this.life -= (Settings.CREATURE_MINIMUM_DECAY_AMOUNT + this.tile.biome.movement_resistance);        
        if (life <= 0) {
            killCreature();
            return;
        }
        
        
        brain.process();
        ArrayList<Float> results = brain.process_results;
        if (results.size() != 3) {
        	return;   
        }
        float x = results.get(0);
        float y = results.get(1);
        float z = results.get(2);
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
        float delta = 5;
        float d1 = random(delta) - (delta/2);
        float d2 = random(delta) - (delta/2);
        float d3 = random(delta) - (delta/2);
        
        red   += d1;
        green += d2;
        blue  += d3;
        
        red = clamp(red, 0, 255);
        green = clamp(green, 0, 255);
        blue = clamp(blue, 0, 255);
    }
    
    void tryReproduce() {
        float cost = life * Settings.CREATURE_CHILD_SACRIFICE_AMOUNT;
      
        Tile openSpot = findReproductionTile();
        if (openSpot == null) return;
                
        Creature newCreature = new Creature(species);
          newCreature.brain = new Brain(brain, newCreature);
          newCreature.copy_color(this);
          //newCreature.brain.mutate_count(((int)random(2,7)));
          newCreature.brain.mutate();
          newCreature.tile = openSpot;
          newCreature.tile.creature = newCreature;     
          newCreature.generation = generation+1;
        species.creatures.add(newCreature);
        
        newCreature.life = cost*0.9;
        life -= cost;
        if (life < 0) {
            killCreature();
            return;
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
                   tile.creature = null;
                   tile.shouldRedraw = true;
                   this.life -= (tile.biome.movement_resistance);                   
                   tile = target;
                   tile.creature = this;  
                   tile.shouldRedraw = true;
               } else {
                   if (target.creature.markedForDeath) return;
                   if (target.creature.life <= 0) return;
                   
                   float steal = life * Settings.CREATURE_CREATURE_EAT_AMOUNT;
                   if (target.creature.life < steal) {
                       target.creature.killCreature();
                       return;
                   } else {
                       target.creature.life -= steal;
                       species.world.creatureMatterConsumed += steal;
                       life += steal;
                       return;
                   }
               }               
            } else {
                Food food = (Food)target;
                if (food.current_life < Settings.CREATURE_PLANT_EAT_AMOUNT) {
                    food.current_life = 0; 
                } else {
                    life += Settings.CREATURE_PLANT_EAT_AMOUNT;
                    species.world.plantMatterConsumed += Settings.CREATURE_PLANT_EAT_AMOUNT;
                    food.current_life -= Settings.CREATURE_PLANT_EAT_AMOUNT;
                    target.shouldRedraw = true;
                }
            }
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
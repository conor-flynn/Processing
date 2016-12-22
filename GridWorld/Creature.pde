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
    float minimal_life;
    
    
    public Creature(Species species) {
        this.species = species;
      
        markedForDeath = false;
        red = green = blue = -1;
        
        starting_life = 1;
        minimal_life = starting_life * 0.8;
          
        brain = new Brain(null);
        life = starting_life;
        age = 0;
        generation = 0;
        
    }
    
    void debugMove() {
        Object[] data = tile.neighbors.values().toArray();
        while (true) {
             
        }
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
        if (brain.neurons.size() == 0) {
            println("Creature with empty neurons.");
            return;
        }
        if (brain.axons.size() == 0) {
            println("Creature with empty axons.");
            return;
        }
        if (markedForDeath) return;
        
        age++;
        if (age > 1000) {
            killCreature();
            return;
        }
        
        float speciesLimiter = species.creatures.size() / 3000.0;
        float decayRate = 0.0025 + speciesLimiter;
        
        float decayAmount = life * decayRate;
        if (decayAmount < decayRate) decayAmount = decayRate;
        life -= decayAmount;        
        
        if (life <= 0) {
            killCreature();
            return;
        }
        
        ArrayList<Float> inputs = new ArrayList<Float>();
        for (int i = 0; i < 8; i++) {
            if (tile.neighbors.containsKey(i)) {
                Tile target = tile.neighbors.get(i);
                inputs.add(tile.neighbors.get(i).getEvaluation());
            } else {
                inputs.add(0.0);
            }
        }
        inputs.add(tile.getEvaluation());
        inputs.add(brain.inherited_value);
        inputs.add(random(1));
        inputs.add(1.0);
        int _outLayer = brain.neurons.size()-1;
        int _memoryNeuron = brain.neurons.get(_outLayer).size()-1;
        inputs.add((brain.neurons.get(_outLayer).get(_memoryNeuron)));
        
        brain.process(inputs);
        ArrayList<Float> results = brain.neurons.get(brain.neurons.size()-1);
        float x = results.get(0);
        float y = results.get(1);
        
        float limit = 0.0005;
        if (abs(x) > limit || abs(y) > limit) {
            tryMove(x,y);
            return;
        } else {
            tryReproduce();
            return;
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
    
    void mutateColor(Creature target) {
        float delta = 5;
        float d1 = random(delta) - (delta/2);
        float d2 = random(delta) - (delta/2);
        float d3 = random(delta) - (delta/2);
        
        red = target.red + d1;
        green = target.green + d2;
        blue = target.blue + d3;
        
        red = clamp(red, 0, 255);
        green = clamp(green, 0, 255);
        blue = clamp(blue, 0, 255);
    }
    
    void tryReproduce() {
      
        if (life < starting_life) {
            return;
        }
        float cost = life * Settings.CREATURE_CHILD_SACRIFICE_AMOUNT;
        float pass = cost * Settings.REPRODUCTION_EFFICIENCY;
        if (pass < (starting_life * 0.5)) {
            return;
        }
      
        Tile openSpot = findReproductionTile();
        if (openSpot == null) return;
                
        Creature newCreature = new Creature(species);
          newCreature.brain.copyBrain(brain);
          newCreature.brain.mutate();
          newCreature.tile = openSpot;
          newCreature.tile.creature = newCreature;
          newCreature.mutateColor(this);     
          newCreature.generation = generation+1;
        species.creatures.add(newCreature);
        
        newCreature.life = pass;
        life -= cost;
        if (life < 0) {
            killCreature();
            return;
        }
    }
    
    //void tryEat() {
    //   HashMap<Integer, Food> foods = getNearbyFoods();
        
    //    if (foods.size() != 0) {
    //        float gather = 0.4;
    //        float per = gather / foods.size();
    //        for (Map.Entry me : foods.entrySet()) {
    //            Food food = (Food)me.getValue();
    //            food.amount -= per;
    //        }
    //        life += gather;
    //    } 
    //}
    
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
                   tile = target;
                   tile.creature = this;  
               } else {
                   if (target.creature.markedForDeath) return;
                   if (target.creature.life <= 0) return;
                   
                   float steal = life * Settings.CREATURE_VS_CREATURE_EAT_PROPORTION;
                   if (steal > target.creature.life) steal = target.creature.life;
                   
                   target.creature.life -= steal;
                   steal *= Settings.CREATURE_VS_CREATURE_EAT_EFFICIENCY;
                   species.world.creatureMatterConsumed += steal;
                   life += steal;
               }               
            } else {
                Food food = (Food)target;
                life += food.current_life;
                species.world.plantMatterConsumed += food.current_life;
                food.current_life -= food.current_life;
                target.shouldRedraw = true;
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
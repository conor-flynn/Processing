class Creature {
  
    World world;
    Species species;
  
    Brain brain;
  
    Tile tile;
    float red,green,blue;
    
    float life;
    int age;
    boolean markedForDeath;
    
    float starting_life;
    float minimal_life;
    
    
    public Creature(World world, Species species) {
        this.world = world;
        this.species = species;
      
        starting_life = 1;
        minimal_life = starting_life * 0.8;
        brain = new Brain();
        life = starting_life;
        age = 0;
        markedForDeath = false;
        red = green = blue = -1;
    }
    
    void killCreature() {
        if (markedForDeath) return;
        markedForDeath = true;
        species.preGrave.add(this);
    }
    
    void update() {
        if (markedForDeath) return;
        age++;
        float decay = life * 0.01;
        if (decay < 0.01) decay = 0.01;
        life -= decay;
        if (tile == null) {
            println("Creature with no tile");
            return;
        }
        
        if (life <= 0) {
            killCreature();
            return;
        } else if (age > 2000) {
            killCreature();
            return;
        }
        
        ArrayList<Float> inputs = new ArrayList<Float>();
        for (int i = 0; i < 8; i++) {
            if (tile.neighbors.containsKey(i)) {
                Tile target = tile.neighbors.get(i);
                
                if (target.creature != null) {
                    inputs.add(1.0);
                } else {
                    inputs.add(0.0);
                }
            } else {
                inputs.add(-1.0);
            }
        }
        for (int i = 0; i < 8; i++) {
            if (tile.neighbors.containsKey(i)) {
                Tile target = tile.neighbors.get(i);
                if (target instanceof Food) {
                    Food food = (Food)target;
                    inputs.add(food.amount);
                } else {
                    inputs.add(0.0);
                }
            } else {
                inputs.add(-1.0);
            }
        }
        inputs.add(sig(life));
        inputs.add((random(1) > 0.95) ? 1.0 : 0.0);
        inputs.add((random(1) > 0.05) ? 0.0 : 1.0);
        inputs.add(random(1));
        inputs.add(1.0);        
        
        brain.process(inputs);
        float[] result = brain.outputVals;
        float x = result[0];
        float y = result[1];
        float eat = result[2];
        float repro = result[3];
                
        float max = 0;
        int index = -1;
        for (int i = 0; i < result.length; i++) {
            if (abs(result[i]) > max) {
                max = abs(result[i]);
                index = i;
            }
        }
        
        switch (index) {
           case 0:
           case 1:
               tryMove(x,y);
               break;
          case 2:
              tryEat();
              break;
          case 3:
              tryReproduce();
              break;
          default:
              break;
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
        float cost = life * 0.45;
        float pass = cost * 0.95;
        if (pass < (starting_life * 0.5)) {
            return;
        }
      
        Tile openSpot = findReproductionTile();
        if (openSpot == null) return;
                
        Creature newCreature = new Creature(world, species);
          newCreature.brain.copyBrain(brain);
          newCreature.brain.mutate();
          newCreature.tile = openSpot;
          newCreature.tile.creature = newCreature;
          newCreature.mutateColor(this);          
        species.creatures.add(newCreature);
        
        newCreature.life = pass;
        life -= cost;
        if (life < 0) {
            killCreature();
            return;
        }
    }
    
    void tryEat() {
       HashMap<Integer, Food> foods = getNearbyFoods();
        
        if (foods.size() != 0) {
            float gather = 0.2;
            float per = gather / foods.size();
            for (Map.Entry me : foods.entrySet()) {
                Food food = (Food)me.getValue();
                food.amount -= per;
            }
            life += gather;
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
                   tile = target;
                   tile.creature = this;  
               } else {
                   if (target.creature.markedForDeath) return;
                   if (target.creature.life <= 0) return;
                   
                   float steal = life * 0.40;
                   if (steal > target.creature.life) steal = target.creature.life;
                   
                   target.creature.life -= steal;
                   steal *= 0.8;
                   life += steal;
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
        
        x += 3;
        y += 3;
        
        x -= w/2;
        y -= w/2;     
        
        w -= 6;
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
                if (f.amount > 0.3)
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
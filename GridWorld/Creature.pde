class Creature {
  
    World world;
  
    Brain brain;
  
    Tile tile;
    color col;
    
    float life;
    int age;
    boolean markedForDeath;
    
    float starting_life;
    float minimal_life;
    
    
    public Creature(World _world) {
      
        starting_life = 1;
        minimal_life = starting_life * 0.8;
      
        tile = null;
        col = -1;
        brain = new Brain();
        life = starting_life;
        age = 0;
        markedForDeath = false;
        world = _world;
    }
    
    void update() {
        if (markedForDeath) return;
        age++;
        life -= 0.01;
        if (tile == null) {
            println("Creature with no tile");
            return;
        }
        
        if (life <= 0) {
            world.killCreature(this);
            return;
        } else if (age > 1200) {
            world.killCreature(this);
            return;
        }
        
        ArrayList<Boolean> inputs = new ArrayList<Boolean>();
        for (int i = 0; i < 8; i++) {
            if (tile.neighbors.containsKey(i)) {
                Tile target = tile.neighbors.get(i);
                
                if (target.creature != null) {
                    inputs.add(true);
                } else {
                    inputs.add(false);
                }
            } else {
                inputs.add(true);
            }
        }
        for (int i = 0; i < 8; i++) {
            if (tile.neighbors.containsKey(i)) {
                Tile target = tile.neighbors.get(i);
                if (target instanceof Food) {
                    Food food = (Food)target;
                    if (food.amount > 0.6) {
                        inputs.add(true);
                    } else {
                        inputs.add(false);
                    }
                }
            } else {
                inputs.add(false);
            }
        }
        boolean littleLife = false;
        if (life > 0.4) littleLife = true;
        boolean greaterLife = false;
        if (life > starting_life) greaterLife = true;
        inputs.add(littleLife);
        inputs.add(greaterLife);
        inputs.add((random(1) > 0.5));
        inputs.add((random(1) > 0.5));
        inputs.add((random(1) > 0.5));
        inputs.add((random(1) > 0.5));
        
        int choice = brain.process(inputs);
        
        switch (choice) {
            case -1:
                break;
            case 0:
                tryMove(Direction.NORTH.val());
                break;
            case 1:
                tryMove(Direction.SOUTH.val());
                break;
            case 2:
                tryMove(Direction.EAST.val());
                break;
            case 3:
                tryMove(Direction.WEST.val());
                break;
            case 4:
                tryEat();
                break;
            case 5:
                tryReproduce();
                break;
            default:
                break;
        }
    }
    
    void tryReproduce() {
      
        if (life < minimal_life) {
            return;
        }
        float cost = minimal_life + (life * 0.35);
        float pass = cost * 0.95;
        if (life < cost) {
            return;
        }
      
        Tile openSpot = findReproductionTile();
        if (openSpot == null) return;
                
        Creature newCreature = new Creature(world);
        newCreature.brain.copyBrain(brain);
        newCreature.brain.mutate();
        newCreature.tile = openSpot;
        newCreature.tile.creature = newCreature;
        newCreature.col = col;
        world.buildCreature(newCreature);
        
        newCreature.life = pass;
        life -= cost;
        if (life < 0) {
            world.killCreature(this);
        }
    }
    
    void tryEat() {
       HashMap<Integer, Food> foods = getNearbyFoods();
        
        if (foods.size() != 0) {
            float gather = 1;
            float per = gather / foods.size();
            for (Map.Entry me : foods.entrySet()) {
                Food food = (Food)me.getValue();
                food.amount -= per;
            }
            life += gather;
        } 
    }
    
    void tryMove(int index) {
        if (index < 0) return;
        if (tile.neighbors.containsKey(index)) {
            Tile newTile = tile.neighbors.get(index);
            if (newTile.creature != null || newTile instanceof Food) {
                return;
            }
            tile.creature = null;
            tile = newTile;
            tile.creature = this;
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
        
        fill(col);        
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
class Species {
    World world;
    
    int numCreatures;
    ArrayList<Creature> creatures = new ArrayList<Creature>();
    ArrayList<Creature> preGrave = new ArrayList<Creature>();
    ArrayList<Integer> creatureSpawns = new ArrayList<Integer>();
    
    
    public Species(World world, int numCreatures, ArrayList<Integer> creatureSpawns) {  
        this.world = world;
        this.numCreatures = numCreatures;
        this.creatureSpawns = null;//new ArrayList<Integer>(creatureSpawns);
                
        if (this.numCreatures <= 0) println("No creatures");
        //if (this.creatureSpawns.size() <= 0) println("No spawns");
        
        for (int i = 0; i < numCreatures; i++) {
            spawnCreature();
        }
    }
    
    void spawnCreature() {
        Tile tile = findCreatureSpawn();
        if (tile == null) return;
        
        Creature creature = new Creature(this);
        
        tile.creatureEntering(creature);
        
        creature.brain = new Brain(creature);
        
        creature.red = random(255);
        creature.green = random(255);
        creature.blue = random(255);
        
        creature.life = Settings.CREATURE_BIRTH_FOOD;
        
        creatures.add(creature); 
    }
    
    Tile findCreatureSpawn() {
        for (int i = 0; i < 30; i++) {
            int x_index = floor(random(0, Settings.NUM_TILES));
            int y_index = floor(random(0, Settings.NUM_TILES));
            Tile target = world.get_tile_at_point(x_index, y_index);
            
            assert(target != null);
            
            if (target.creature == null) return target;
        }
        return null;
        /*
        Set<Integer> points = new HashSet<Integer>();
        do {
          
            if (points.size() == creatureSpawns.size()) {
                println("No creature spawn location open.");
                return null;
            }
          
            int choice = (int) random(creatureSpawns.size());
            int index = creatureSpawns.get(choice);
            if (points.contains(index)) continue;
            
            points.add(index);
            
            Tile tile = world.tiles.get(index);
            
            if (tile.creature == null) {
                return tile;
            }
        } while (true);
        */
    }
    
    
    
    
    
    
    
    void update() {
        for (int i = 0; i < creatures.size(); i++) {
            creatures.get(i).update();
        }
        while (preGrave.size() > 0) {
           Creature target = preGrave.get(0);
           target.tile.shouldRedraw = true;
           target.tile.creature = null;
           boolean deleted = false;
           for (int i = 0; i < creatures.size(); i++) {
              if (creatures.get(i) == target) {
                 creatures.remove(i);
                 deleted = true;
                 break;
              }
           }
           assert(deleted == true);
           preGrave.remove(0);
        }
        for (int i = 0; i < (numCreatures-creatures.size()); i++) {
            spawnCreature();
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    void draw(){
        for (int i = 0; i < creatures.size(); i++) {
           creatures.get(i).draw(); 
        }
    }
}
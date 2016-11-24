class Species {
    World world;
    
    int numCreatures;
    ArrayList<Creature> creatures = new ArrayList<Creature>();
    ArrayList<Creature> preGrave = new ArrayList<Creature>();
    ArrayList<Integer> creatureSpawns = new ArrayList<Integer>();
    
    public Species(World world, int numCreatures, ArrayList<Integer> creatureSpawns) {  
        this.world = world;
        this.numCreatures = numCreatures;
        this.creatureSpawns = new ArrayList<Integer>(creatureSpawns);        
        
        if (this.numCreatures <= 0) println("No creatures");
        if (this.creatureSpawns.size() <= 0) println("No spawns");
        
        for (int i = 0; i < numCreatures; i++) {
            spawnCreature();
        }
    }
    
    void spawnCreature() {
        Tile tile = findCreatureSpawn();
        if (tile == null) return;
        
        Creature creature = new Creature(world, this);
        if (creature == null) return;
        
        tile.creature = creature;
        creature.tile = tile;
        creature.red = random(255);
        creature.green = random(255);
        creature.blue = random(255);
        creatures.add(creature); 
    }
    
    Tile findCreatureSpawn() {
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
            boolean noCreature = (tile.creature == null);
            boolean notFood = !(tile instanceof Food);
            
            if (noCreature && notFood) {
                return tile;
            }
        } while (true);
    }
    
    
    
    
    
    
    
    void update() {
        for (int i = 0; i < creatures.size(); i++) {
           creatures.get(i).update(); 
        }
        while (preGrave.size() > 0) {
           Creature target = preGrave.get(0);
           world.tiles.get(target.tile.worldIndex).creature = null;
           boolean deleted = false;
           for (int i = 0; i < creatures.size(); i++) {
              if (creatures.get(i) == target) {
                 creatures.remove(i);
                 deleted = true;
                 break;
              }
           }
           if (!deleted) {
               println("Couldn't kill.");
           }
           preGrave.remove(0);
        }
        while (creatures.size() < numCreatures) {
           spawnCreature(); 
        }
    }
    
    void draw(){
        for (int i = 0; i < creatures.size(); i++) {
           creatures.get(i).draw(); 
        }
    }
    
    
    
    
    
    
    
}
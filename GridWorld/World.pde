      
    import java.util.Map;   
    import java.util.*;
    class World {  
        GUI gui;
      
        ArrayList<Tile> tiles = new ArrayList<Tile>();
        
        
        int generation = 0;
        
        ArrayList<Species> species = new ArrayList<Species>();
        ArrayList<Food> foods = new ArrayList<Food>();
        
        ArrayList<Integer> creatureSpawns = new ArrayList<Integer>();
        ArrayList<Integer> foodSpawns = new ArrayList<Integer>();
        
        
        
        public World() {
            gui = new GUI(this);
            frameRate(Settings.TARGET_FRAME_RATE);
            
            PVector offset = new PVector(Settings.TILE_WIDTH/2, Settings.TILE_WIDTH/2);
            
            for (int y = 0; y < Settings.NUM_TILES; y++) {
                for (int x = 0; x < Settings.NUM_TILES; x++) {
                  
                    int xx = x * Settings.TILE_WIDTH;
                    int yy = y * Settings.TILE_WIDTH;
                    xx += offset.x;
                    yy += offset.y;
                    color cc = color(255);
                    int index = x + (y*Settings.NUM_TILES);
                    tiles.add(new Tile(xx, yy, Settings.TILE_WIDTH-2, cc, index));
                    
                    int size = 2;
                    int lower = size;
                    int upper = Settings.NUM_TILES - size;
                    if (x < lower || x > upper) {
                        creatureSpawns.add(index);                        
                    }
                    if (y < lower || y > upper) {
                        creatureSpawns.add(index);
                    }
                    
                    lower += 0;
                    upper -= 0;
                    if (x > lower && x < upper) {
                        if (y > lower && y < upper) {
                            foodSpawns.add(index);
                        }
                    }
                }
            }
            
            for(int i = 0; i < Settings.NUM_FOOD; i++) {
                Tile tile = findFoodSpawn();
                if (tile == null) continue;
                Food food = new Food(tile.x, tile.y, tile.w, tile.c, tile.worldIndex);
                tiles.set(food.worldIndex, food);
            }
                
            for (int i = 0; i < tiles.size(); i++) {
                addNeighbors(tiles.get(i), i);
            }
        
            ArrayList<Integer> defaultBrain = new ArrayList<Integer>();
            defaultBrain.add(22); // Inputs
            defaultBrain.add(16); // Hidden
            defaultBrain.add(3);  // Outputs
            for (int i = 0; i < Settings.NUM_SPECIES; i++) {
               Species species = new Species(this, Settings.NUM_CREATURES_PER_SPECIES, creatureSpawns, defaultBrain);
               this.species.add(species);
            }
        }
        
        HashMap<Integer, Integer> getValidNeighbors(int index) {
            HashMap<Integer, Integer> dirs = new HashMap<Integer, Integer>();
            
            int n  = +Settings.NUM_TILES  + index;
            int ne = n+1;
            int nw = n-1;
            int s  = -Settings.NUM_TILES + index;
            int se = s+1;
            int sw = s-1;
            int e  = +1 + index;
            int w  = -1 + index;
            
            if (index < Settings.NUM_TILES) {
                s = se = sw = -1;
            }
            if (index >= ((Settings.NUM_TILES*Settings.NUM_TILES)-Settings.NUM_TILES)) {
                n = ne = nw = -1;
            }
            if (index % Settings.NUM_TILES == 0) {
                nw = sw = w = -1;
            }
            if ((index+1) % Settings.NUM_TILES == 0) {
                ne = se = e = -1;
            }
            // This ordering has to match the Direction enum
            int[] indices = {n, ne, nw, s, se, sw, e, w};
            for (int i = 0; i < indices.length; i++) {
                int val = indices[i];
                if (validIndex(val)) {
                    dirs.put(i, val);
                }
            }
            return dirs;
        }
        
        void addNeighbors(Tile tile, int index) {
            HashMap<Integer, Integer> valid = getValidNeighbors(index);
            for (Map.Entry me : valid.entrySet()) {
                int k = (int)me.getKey();
                int v = (int)me.getValue();
                tile.neighbors.put(k, tiles.get(v));
            }
        }
        
        boolean validIndex(int i) {
            if (i < 0) return false;
            if (i >= tiles.size()) return false;
            return true;
        }
        
        void preDraw() {
            gui.preDraw(); 
        }
        void draw() {
            for (int i = 0; i < tiles.size(); i++) {
                tiles.get(i).update();
                tiles.get(i).draw();
            }
            for (int i = 0; i < species.size(); i++) {
               species.get(i).update(); 
            }
            for (int i = 0; i < species.size(); i++) {
               species.get(i).draw(); 
            }
        }
        void postDraw() {
            gui.postDraw(); 
        }
        
        Tile findFoodSpawn() {
            Set<Integer> points = new HashSet<Integer>();
            do {
              
                if (points.size() == foodSpawns.size()) {
                    println("No food spawn location open.");
                    return null;
                }
              
                int choice = (int) random(foodSpawns.size());
                int index = foodSpawns.get(choice);
                if (points.contains(index)) continue;
                
                points.add(index);
                
                Tile tile = tiles.get(index);
                boolean noCreature = (tile.creature == null);
                boolean notFood = !(tile instanceof Food);
                
                if (noCreature && notFood) {
                    return tile;
                }
            } while (true);
        }
        
        
        
        
        
        
        
        
        
        
        void mouseWheel(MouseEvent event) {
            gui.mouseWheel(event); 
        }
        void mouseReleased() {
            gui.mouseReleased(); 
        }
        void mouseDragged(MouseEvent event) {
            gui.mouseDragged(event); 
        }
        void keyPressed() {
            gui.keyPressed();
        }
        void mousePressed() {
            gui.mousePressed();
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
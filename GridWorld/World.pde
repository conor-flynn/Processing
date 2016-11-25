      
    import java.util.Map;   
    import java.util.*;
    class World {  
      
        ArrayList<Tile> tiles = new ArrayList<Tile>();
        int numTiles;
        int tileWidth;
        
        int numSpecies = 10;
        int numCreaturesPerSpecies = 10;
        int numFood = 200;
        
        
        PFont font;
        int targetFrameRate = 200;
        int generation = 0;
        
        ArrayList<Species> species = new ArrayList<Species>();
        ArrayList<Food> foods = new ArrayList<Food>();
        
        ArrayList<Integer> creatureSpawns = new ArrayList<Integer>();
        ArrayList<Integer> foodSpawns = new ArrayList<Integer>();
        
        public World() {
            font = createFont("Arial", 160, true);
            tileWidth = 30;
            numTiles = 50;
            frameRate(targetFrameRate);
            for (int y = 0; y < numTiles; y++) {
                for (int x = 0; x < numTiles; x++) {
                    int xx = x * tileWidth;
                    int yy = y * tileWidth;
                    color cc = color(255);
                    int index = x + (y*numTiles);
                    tiles.add(new Tile(xx, yy, tileWidth-2, cc, index));
                    
                    int size = 2;
                    int lower = size;
                    int upper = numTiles - size;
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
            
            for(int i = 0; i < numFood; i++) {
                Tile tile = findFoodSpawn();
                if (tile == null) continue;
                Food food = new Food(tile.x, tile.y, tile.w, tile.c, tile.worldIndex);
                tiles.set(food.worldIndex, food);
            }
                
            for (int i = 0; i < tiles.size(); i++) {
                addNeighbors(tiles.get(i), i);
            }
        
            for (int i = 0; i < numSpecies; i++) {
               Species species = new Species(this, numCreaturesPerSpecies, creatureSpawns);
               this.species.add(species);
            }
        }
        
        HashMap<Integer, Integer> getValidNeighbors(int index) {
            HashMap<Integer, Integer> dirs = new HashMap<Integer, Integer>();
            
            int n  = +numTiles  + index;
            int ne = n+1;
            int nw = n-1;
            int s  = -numTiles + index;
            int se = s+1;
            int sw = s-1;
            int e  = +1 + index;
            int w  = -1 + index;
            
            if (index < numTiles) {
                s = se = sw = -1;
            }
            if (index >= ((numTiles*numTiles)-numTiles)) {
                n = ne = nw = -1;
            }
            if (index % numTiles == 0) {
                nw = sw = w = -1;
            }
            if ((index+1) % numTiles == 0) {
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
            if (i >= numTiles*numTiles) return false;
            return true;
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
            fill(255);
            textFont(font, 32);
            scale(1,-1);
            
            int xx = 1500;
            int yy = -1500;
            for (int i = 0; i < species.size(); i++) {
                Species target = species.get(i);
                int max_gen = -1;
                int total_gen = 0;
                for (int j = 0; j < target.creatures.size(); j++) {
                    if (target.creatures.get(j).generation > max_gen) {
                       max_gen = target.creatures.get(j).generation; 
                    }
                    total_gen += target.creatures.get(j).generation;
                }
                total_gen /= target.creatures.size();
                String popSize = "(" + species.get(i).creatures.size() + ")";
                String genCount = "(" + max_gen + ")";
                String avrCount = "(" + total_gen + ")";
                text("Population : " + popSize, xx, yy);
                yy += 50;
                text("Max generation number : " + genCount, xx+50, yy);
                yy += 50;
                text("Average generation number : " + avrCount, xx+50, yy);
                yy += 50;
            }
            text("Frame rate : " + frameRate, xx, yy);
            yy += 50;
            text("Targe rate : " + targetFrameRate, xx, yy);
            yy += 50;
            text("Generation : " + generation++, xx, yy);
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
        
        void keyPressed() {
            if (key == 'q') {
               targetFrameRate *= 1.1;
               if (targetFrameRate < 10) targetFrameRate++;
               frameRate(targetFrameRate);
            } else if (key == 'w') {
               targetFrameRate *= 0.9;
               if (targetFrameRate < 1) targetFrameRate = 1;
               frameRate(targetFrameRate);
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
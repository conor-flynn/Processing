      
    import java.util.Map;   
    import java.util.*;
    class World {  
        GUI gui;
        float plantMatterConsumed = 0;
        float creatureMatterConsumed = 0;
      
        ArrayList<Tile> tiles = new ArrayList<Tile>();
        HashMap<Character, Biome> biomes = new HashMap<Character, Biome>();
        
        int generation = 0;
        
        ArrayList<Species> species = new ArrayList<Species>();
        ArrayList<Food> foods = new ArrayList<Food>();
        
        ArrayList<Integer> creatureSpawns = new ArrayList<Integer>();
        ArrayList<Integer> foodSpawns = new ArrayList<Integer>();
        
        
        
        public World() {
            gui = new GUI(this);
            frameRate(Settings.TARGET_FRAME_RATE);
            loadFromFile(Settings.WORLD_FILE_NAME);
            
            //ArrayList<Integer> defaultBrain = new ArrayList<Integer>();
            //defaultBrain.add(22); // Inputs
            //defaultBrain.add(16); // Hidden
            //defaultBrain.add(3);  // Outputs
            //for (int i = 0; i < Settings.NUM_SPECIES; i++) {
            //   Species species = new Species(this, Settings.NUM_CREATURES_PER_SPECIES, creatureSpawns, defaultBrain);
            //   this.species.add(species);
            //}
        }
        
        public void loadFromFile(String filename) {
            JSONObject worldData = loadJSONObject(filename);
            JSONArray biomesData  = worldData.getJSONArray("biomes");
            JSONArray tileData   = worldData.getJSONArray("tiles");
            
            for (int biomeIndex = 0; biomeIndex < biomesData.size(); biomeIndex++) {
                JSONObject biomeData = biomesData.getJSONObject(biomeIndex);
                
                String _label = biomeData.getString("label");
                if (_label.length() > 1) {
                    println("World data : Labels should only be a single character");
                    return;
                }
                char label          = _label.charAt(0);                
                Biome biome = new Biome(
                                label, 
                                
                                biomeData.getFloat("color_red"), 
                                biomeData.getFloat("color_green"), 
                                biomeData.getFloat("color_blue"),
                                
                                biomeData.getFloat("food_spawn_percentage"),
                                biomeData.getFloat("food_energy_amount"),
                                biomeData.getFloat("food_energy_growth_amount"),
                                
                                biomeData.getFloat("movement_resistance"),
                                
                                biomeData.getFloat("food_intensity"),
                                biomeData.getFloat("tile_intensity"));
                biomes.put(label, biome);
            }
            int num_rows = tileData.size();
            int num_columns = tileData.getString(0).length();
            Settings.NUM_TILES = num_rows;
            for (int rowIndex = 0; rowIndex < tileData.size(); rowIndex++) {
                if (tileData.getString(rowIndex).length() != num_columns) {
                    println("The world needs to be perfect square."); 
                } 
                
            }
            
            ArrayList<String> reversedData = new ArrayList<String>();
            for (int rowIndex = tileData.size()-1; rowIndex >= 0; rowIndex--) {
                reversedData.add(tileData.getString(rowIndex)); 
            }
            
            
            PVector tileOffset = new PVector(Settings.TILE_WIDTH/2, Settings.TILE_WIDTH/2);
            for (int rowIndex = 0; rowIndex < reversedData.size(); rowIndex++) {
                String _rowData = reversedData.get(rowIndex);
                char[] rowData = _rowData.toCharArray();
                for (int colData = 0; colData < rowData.length; colData++) {
                    char label = rowData[colData];
                    Biome target = biomes.get(label);
                    if (target == null) {
                        println("Cannot find biome");
                        return;
                    }
                    int x = (colData * Settings.TILE_WIDTH);
                        x+= tileOffset.x;
                    int y = (rowIndex * Settings.TILE_WIDTH);
                        y+= tileOffset.y;
                    int w = Settings.TILE_WIDTH - 2;
                    int index = colData + (rowIndex * rowData.length);
                    
                    tiles.add(buildTileFromFile(target, x, y, w, index));
                }
            }
            
            for (int i = 0; i < tiles.size(); i++) {
                addNeighbors(tiles.get(i), i); 
            }
            
            for (int i = 0; i < tiles.size(); i++) {
                if (random(1) < Settings.BIOME_BLUR_RATE) {
                     Tile self = tiles.get(i);
                     Biome newBiome = null;
                     for (Map.Entry me : self.neighbors.entrySet()) {
                         Biome target = ((Tile)me.getValue()).biome;
                         if (self.biome != target) {
                             newBiome = target; 
                         }
                     }
                     if (newBiome != null) {
                         tiles.get(i).biome = newBiome; 
                     }
                }
            }
        }
        
        Tile buildTileFromFile(Biome target, int x, int y, int w, int index) {
             
             if (random(1) < target.food_spawn_rate) {
                 Food f = new Food(x, y, w, index, target);
                 return f;
             } else {
                 Tile t = new Tile(x, y, w, index, target);
                 return t;
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
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
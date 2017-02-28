      
    import java.util.Map;   
    import java.util.*;
    class World {        
        GUI gui;
        float plantMatterConsumed = 0;
        float creatureMatterConsumed = 0;
      
        ArrayList<Tile> tiles = new ArrayList<Tile>();
        HashMap<String, Biome> biomes = new HashMap<String, Biome>();
        
        int generation = 0;
        
        ArrayList<Species> species = new ArrayList<Species>();
        ArrayList<Food> foods = new ArrayList<Food>();
        
        ArrayList<Integer> creatureSpawns = new ArrayList<Integer>();
        ArrayList<Integer> foodSpawns = new ArrayList<Integer>();
        
        
        
        public World() {
            gui = new GUI(this);
            frameRate(Settings.TARGET_FRAME_RATE);
            loadFromFile(Settings.WORLD_FILE_NAME);
            
            int x0, y0, w, h;
            ArrayList<Integer> spawn0 = new ArrayList<Integer>();
            x0 = 0;
            y0 = 0;
            w = 100;
            h = 100;
            for (int x = x0; x < x0+w; x++) {
                for (int y = y0; y < y0+h; y++) {
                    int index = x + (y * Settings.NUM_TILES);
                    spawn0.add(index);
                }
            }
            for (int i = 0; i < Settings.NUM_SPECIES; i++) {
                this.species.add(new Species(this, Settings.NUM_CREATURES_PER_SPECIES, spawn0));
            }            
        }
        
        public void loadFromFile(String filename) {
            JSONObject worldData = loadJSONObject(filename);
            JSONArray biomesData  = worldData.getJSONArray("biomes");
            JSONArray tileData   = worldData.getJSONArray("tiles");
            
            for (int biomeIndex = 0; biomeIndex < biomesData.size(); biomeIndex++) {
                JSONObject biomeData = biomesData.getJSONObject(biomeIndex);
                
                String label = biomeData.getString("label");
                if (label.length() > 2) {
                    println("World data : Labels must be 2 characters.");
                    return;
                }        
                Biome biome = new Biome(
                                label, 
                                
                                biomeData.getFloat("color_red"), 
                                biomeData.getFloat("color_green"), 
                                biomeData.getFloat("color_blue"),
                                
                                biomeData.getFloat("tiles_per_creature"),
                                //biomeData.getFloat("food_spawn_percentage"),
                                //biomeData.getFloat("food_energy_amount"),
                                //biomeData.getFloat("food_energy_growth_amount"),
                                
                                biomeData.getFloat("movement_resistance"),
                                
                                biomeData.getFloat("food_intensity"),
                                biomeData.getFloat("tile_intensity"));
                biomes.put(label, biome);
            }
            int num_rows = tileData.size();
            int num_columns = tileData.getString(0).length()/2;
            Settings.NUM_TILES = num_rows;
            Settings.WORLD_WIDTH = Settings.NUM_TILES * Settings.TILE_WIDTH;
            for (int rowIndex = 0; rowIndex < tileData.size(); rowIndex++) {
                if (tileData.getString(rowIndex).length()/2 != num_rows) {
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
                for (int colIter = 0; colIter < rowData.length; colIter+=2) {
                    String label = Character.toString(rowData[colIter]) + Character.toString(rowData[colIter+1]);
                    Biome target = biomes.get(label);
                    assert(target != null);
                    
                    int colIndex = colIter/2;
                    int x = (colIndex * Settings.TILE_WIDTH);
                        x+= tileOffset.x;
                    int y = (rowIndex * Settings.TILE_WIDTH);
                        y+= tileOffset.y;
                    int w = Settings.TILE_WIDTH - 2;
                    int index = colIndex + (rowIndex * Settings.NUM_TILES);
                    tiles.add(buildTileFromFile(target, x, y, w, index));
                }
            }
            
            for (int i = 0; i < tiles.size(); i++) {
                addNeighbors(tiles.get(i), i); 
            }
            
            ArrayList<Integer> tempList = new ArrayList<Integer>(tiles.size());
            for (int i = 0; i < tiles.size(); i++) { 
                tempList.add(i);
            }
            ArrayList<Integer> blurList = new ArrayList<Integer>(tiles.size());
            for (int i = 0; i < tiles.size(); i++) {
                int index = (int)random(0, tempList.size());
                Integer target = tempList.get(index);
                tempList.remove(index);
                blurList.add(target);
            }
            for (Integer i : blurList) {
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
             float chance = (1f / target.tiles_per_creature);
             if (random(1) < chance) {
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
            if (Settings.DRAW_TILES) {
                for (int i = 0; i < tiles.size(); i++) {
                    tiles.get(i).update();
                    tiles.get(i).draw();
                }
            } else {
                for (int i = 0; i < tiles.size(); i++) {
                    tiles.get(i).update();
                }   
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
            FORCE_REDRAW = true;
            gui.mouseWheel(event); 
        }
        void mouseReleased() {
            gui.mouseReleased(); 
        }
        void mouseDragged(MouseEvent event) {
            FORCE_REDRAW = true;
            gui.mouseDragged(event); 
        }
        void keyPressed() {
            gui.keyPressed();
        }
        void mousePressed() {
            gui.mousePressed();
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
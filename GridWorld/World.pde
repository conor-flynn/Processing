      
    import java.util.Map;   
    import java.util.*;
    class World {        
        GUI gui;
        double plantMatterConsumed = 0;
        double creatureMatterConsumed = 0;
        long asexual_reproduction = 0;
        long sexual_reproduction = 0;
        long creature_no_action = 0;
        long creature_sexual_action = 0;
        long creature_move_action = 0;
        long creature_never_action = 0;
        long creature_fresh_spawn_never_action = 0;
        long creature_fresh_spawn_counter = 0;
      
        ArrayList<Tile> tiles = new ArrayList<Tile>();
        Tile respawn_youngest_tile = null;
        Tile respawn_oldest_tile = null;
        int num_tiles_in_queue = 0;
        
        HashMap<String, Biome> biomes = new HashMap<String, Biome>();
        HashMap<Color, BiomeGroup> biome_spawner = new HashMap<Color, BiomeGroup>();
        
        int generation = 0;
        
        ArrayList<Species> species = new ArrayList<Species>();
        
        ArrayList<Integer> creatureSpawns = new ArrayList<Integer>();
        
        int neuron_counter = 14;
        int gene_counter = 0;
        //HashMap<Integer, HashMap<Integer, Integer>> gene_library = new HashMap<Integer, HashMap<Integer, Integer>>();
        
        
        public World() {
            
            gui = new GUI(this);
            frameRate(Settings.TARGET_FRAME_RATE);
            loadFromFile(Settings.WORLD_BIOME_DESCRIPTIONS, Settings.WORLD_TILE_DESCRIPTIONS);
            
            /*
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
            */
            for (int i = 0; i < Settings.NUM_SPECIES; i++) {
                this.species.add(new Species(this, Settings.NUM_CREATURES_PER_SPECIES, null));
            }            
        }
        float get_tile_posx_by_index(int x) {
            float tile_size = Settings.TILE_WIDTH;
            if (x > 0) {
                return (tile_size / 2f) + (tile_size * x);
            } else {
                return (-tile_size / 2f) - (tile_size * x);   
            }
        }
        float get_tile_posy_by_index(int y) {
            float tile_size = Settings.TILE_WIDTH;
            if (y > 0) {
                return (Settings.NUM_TILES*Settings.TILE_WIDTH) - ((tile_size / 2f) + (tile_size * y));
            } else {
                return (Settings.NUM_TILES*Settings.TILE_WIDTH) - ((-tile_size / 2f) - (tile_size * y));   
            }
        }
        Tile get_tile_at_point(int x, int y) {
            if ((x < 0 || x > (Settings.NUM_TILES-1)) || (y < 0 || y > (Settings.NUM_TILES-1))) {
                return null;        
            }
            int index = (x) + (Settings.NUM_TILES * y);
            assert(index >= 0 && index < (Settings.NUM_TILES * Settings.NUM_TILES)); 
            
            return tiles.get(index);
        }
        void load_biome_descriptions(String file_name) {
            JSONObject file = loadJSONObject(file_name);
            JSONArray biomes_aray = file.getJSONArray("biomes");
            JSONArray biome_groups_array = file.getJSONArray("groups");
            {
                // Iterate through each biome
                for (int biomeIndex = 0; biomeIndex < biomes_aray.size(); biomeIndex++) {
                    JSONObject particular_biome = biomes_aray.getJSONObject(biomeIndex);
                    
                    String name = particular_biome.getString("name");
                        assert(name.length() > 0);
                    JSONArray cycle_data = particular_biome.getJSONArray("data");
                   
                    Biome biome = new Biome(name, cycle_data.size());
                    for (int cycle = 0; cycle < cycle_data.size(); cycle++) {
                        
                        JSONObject particular_cycle = cycle_data.getJSONObject(cycle);
                        
                        biome.set_life_time(
                                    particular_cycle.getInt("life_time"), cycle);
                        biome.set_tile_color(
                                    particular_cycle.getJSONArray("tile_color").getStringArray(), cycle);
                        biome.set_tile_type(
                                    particular_cycle.getJSONArray("tile_type").getStringArray(), cycle);
                        biome.set_food_color(
                                    particular_cycle.getJSONArray("food_color").getStringArray(), cycle);
                        biome.set_food_type(
                                    particular_cycle.getJSONArray("food_type").getStringArray(), cycle);
                        biome.set_food_fertility(
                                    particular_cycle.getFloat("food_fertility"), cycle);
                        biome.set_food_neighbors(
                                    particular_cycle.getInt("food_neighbors"), cycle);
                        biome.set_food_respawn_time(
                                    particular_cycle.getInt("food_respawn_time"), cycle);
                    }
                    biomes.put(name, biome);
                }
                update_biomes();
            }
            // All biome data is loaded
            // Now process data from biome_groups_array
            {
                for (int index = 0; index < biome_groups_array.size(); index++) {
                    JSONObject particular_group = biome_groups_array.getJSONObject(index);
                    
                    int color_data[] = converti(particular_group.getJSONArray("key").getStringArray());
                    color kkey = color(color_data[0], color_data[1], color_data[2]);
                    
                    JSONArray biome_links = particular_group.getJSONArray("biomes");
                    BiomeGroup new_group = new BiomeGroup();
                    for (int i = 0; i < biome_links.size(); i++) {
                        JSONObject description = biome_links.getJSONObject(i);
                        new_group.links.put(biomes.get(description.getString("name")), description.getFloat("chance"));
                    }
                    assert(new_group != null);
                    assert(new_group.links.size() > 0);
                    biome_spawner.put(new Color(kkey), new_group);
                }
            }
        }
        void load_tiles_from_image(String file_name) {
            PImage source = loadImage(file_name);
            assert(source.width == source.height);
            Settings.NUM_TILES = source.width;
            Settings.WORLD_WIDTH = Settings.NUM_TILES * Settings.TILE_WIDTH;
            PVector tileOffset = new PVector(Settings.TILE_WIDTH/2, Settings.TILE_WIDTH/2);
            
            for (int y = 0; y < source.height; y++) {
                for (int x = 0; x < source.width; x++) {
                    color col = source.get(x,y);
                    Color kkey = new Color(col);
                    if (biome_spawner.get(kkey) == null) {
                        println("Can't find color : " + kkey.get_print());
                        
                        println("Column : " + x);
                        println("Row : " + y);
                    }
                    Biome biome = biome_spawner.get(kkey).get_random_biome();
                    
                    int xx = (int)((x*Settings.TILE_WIDTH) + tileOffset.x);
                    int yy = (int)(((Settings.NUM_TILES-y)*Settings.TILE_WIDTH) + tileOffset.y);
                    //int yy = (int)((y*Settings.TILE_WIDTH) + tileOffset.y);
                    int ww = Settings.TILE_WIDTH;// - 2;
                    int index = x + (y * Settings.NUM_TILES);
                    
                    tiles.add(buildTileFromFile(biome, xx,yy,ww,index));
                }
            }
            /*
            for (int i = 0; i < tiles.size(); i++) {
                Tile target = tiles.get(i);
                assert(target.worldIndex == i);
            }
            */
            for (Tile tile : tiles) {
                tile.load_neighbors();
            }
            for (Tile tile : tiles) {
                tile.try_respawn(true);
            }
        }
        public void loadFromFile(String biome_descriptions, String tile_descriptions) {
            load_biome_descriptions(biome_descriptions);
            // All biomes are loaded from file and updated (updated: tiles can properly reference this biome)
            // All <V3, BiomeGroup> have been loaded
            load_tiles_from_image(tile_descriptions);
        }
        Tile buildTileFromFile(Biome target, int x, int y, int w, int index) {
             Tile t = new Tile(x, y, w, index, target, this);
             return t;
        }
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        HashMap<Creature, Creature> attempt_parents = new HashMap<Creature, Creature>();
        HashMap<Creature, Creature> parents = new HashMap<Creature, Creature>();
        void tryToSexuallyReproduce(Creature source, Creature target) {
            if (source.markedForDeath || target.markedForDeath) return;
            
            if (attempt_parents.get(source) == target) {
                parents.put(source, target);
            } else {
                attempt_parents.put(target, source);   
            }
        }
        void manage_reproduction() {
            for (Map.Entry me : parents.entrySet()) {
                Creature source = (Creature)me.getKey();
                Creature target = (Creature)me.getValue();
                
                if (
                    source.life <= Settings.CREATURE_SEXUAL_REPRODUCTION_COST || 
                    target.life <= Settings.CREATURE_SEXUAL_REPRODUCTION_COST) 
                {
                    continue;
                }
                
                source.cross_with(target);
            }
            attempt_parents.clear();
            parents.clear();
        }
        
        
        
        
        
        void preDraw() {
            try_report();
            if (Settings.DRAW_SIMULATION) gui.preDraw(); 
        }
        void draw() {
            noStroke();
            update_biomes();
            manage_tile_respawn();
            for (int i = 0; i < species.size(); i++) {
                species.get(i).update();
            }
            manage_reproduction();
            if (Settings.DRAW_SIMULATION) {
                for (int i = 0; i < tiles.size(); i++) {
                    tiles.get(i).draw();
                }
                for (int i = 0; i < species.size(); i++) {
                    species.get(i).draw();
                }
            }
            if (Settings.DRAW_SPECIES) {
                Species target = species.get(Settings.DRAW_SPECIES_INDEX);
                for (Creature creature : target.creatures) {
                    creature.tile.debug_draw(color(255,255,255), 5);
                }
            }
        }
        void postDraw() {
            generation++;
            if (Settings.DRAW_SIMULATION) gui.postDraw(); 
        }



















        void mouseWheel(MouseEvent event) {
            FORCE_REDRAW = true;
            gui.mouseWheel(event); 
        }
        void mouseReleased() {
            gui.mouseReleased(); 
        }
        void mouseDragged(MouseEvent event) {
            if (mouseButton == RIGHT) return;
            FORCE_REDRAW = true;
            gui.mouseDragged(event); 
        }
        void keyPressed() {
            gui.keyPressed();
        }
        void mousePressed() {
            gui.mousePressed();
        }
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        int getNextNeuronID() {
            return neuron_counter++;
        }
        int getNextGeneID() {
            return gene_counter++;
        }
        void update_biomes() {
            for (Map.Entry me : biomes.entrySet()) {
                Biome biome = (Biome)me.getValue();
                biome.update();
            }
        }
        void add_tile_to_queue(Tile guy) {
            num_tiles_in_queue++;
            guy.isRespawning = true;
            if (respawn_youngest_tile == null) {
            
                // Case: there is no chain that exists
                
                respawn_youngest_tile = guy;
                respawn_youngest_tile.respawn_younger_tile = null;
                respawn_youngest_tile.respawn_older_tile = null;
                
                return;
            } else if (respawn_oldest_tile == null) {
                
                // Case: there is a chain of 1 item
                
                if (respawn_youngest_tile.respawn_frame <= guy.respawn_frame) {
                
                    // Case:
                        // There was only a 'respawn_youngest_tile'. 
                        // The new link should go after the 'respawn_youngest_tile'
                
                    respawn_oldest_tile = guy;
                    
                    respawn_youngest_tile.respawn_older_tile = respawn_oldest_tile;
                    respawn_youngest_tile.respawn_older_tile.respawn_younger_tile = respawn_youngest_tile;
                    respawn_youngest_tile.respawn_older_tile.respawn_older_tile = null;
                    
                    return;
                } else {
                
                    // Case:
                        // There was only a 'respawn_youngest_tile'. 
                        // The new link should go before the 'respawn_youngest_tile'
                
                    respawn_oldest_tile = respawn_youngest_tile;
                    respawn_youngest_tile = guy;
                    
                    respawn_youngest_tile.respawn_younger_tile = null;
                    respawn_youngest_tile.respawn_older_tile = respawn_oldest_tile;
                    respawn_youngest_tile.respawn_older_tile.respawn_younger_tile = respawn_youngest_tile;
                    respawn_youngest_tile.respawn_older_tile.respawn_older_tile = null;
                    
                    return;
                }
            }
            if (respawn_oldest_tile.respawn_frame <= guy.respawn_frame) {
            
                // Case:
                    // The new link should be added to the end of the chain
            
                guy.respawn_younger_tile = respawn_oldest_tile;
                guy.respawn_younger_tile.respawn_older_tile = guy;
                
                respawn_oldest_tile = guy;
                
                return;
                
            } else {
            
                // Case:
                    // The respawn time is less than the oldest tile, 
                    // so it has to be inserted somewhere into the chain
                    
                Tile worker = respawn_oldest_tile;
                
                while (true) {
                
                    worker = worker.respawn_younger_tile;
                    if (worker == null) {
                        
                        // Case: worker is null, 'guy' should be inserted in front of the youngest tile
                        
                        guy.respawn_younger_tile = null;
                        guy.respawn_older_tile = respawn_youngest_tile;
                        guy.respawn_older_tile.respawn_younger_tile = guy;
                        
                        respawn_youngest_tile = guy;
                        
                        return;
                    }
                    
                    if (worker.respawn_frame <= guy.respawn_frame) {
                        
                        // Case: Adding somewhere in the middle of the chain
                        
                        assert(worker != respawn_oldest_tile);
                        
                        guy.respawn_younger_tile = worker;
                        guy.respawn_older_tile = worker.respawn_older_tile;
                        
                        guy.respawn_younger_tile.respawn_older_tile = guy;
                        guy.respawn_older_tile.respawn_younger_tile = guy;
                        
                        return;
                    
                    }
                }
            }
        }
        void respawn_tile(Tile target) {
            target.isFood = true;
            target.isRespawning = false;
            target.shouldRedraw = true;
            num_tiles_in_queue--;
        }
        void manage_tile_respawn() {
            if (respawn_youngest_tile == null) return;
            
            /*
            if (respawn_youngest_tile != null) {
                println((respawn_youngest_tile.respawn_frame - this.generation));
            }
            */
            
            while(respawn_youngest_tile != null && (respawn_youngest_tile.respawn_frame <= this.generation)) {
                respawn_tile(respawn_youngest_tile);
                
                if (respawn_youngest_tile.respawn_older_tile == null) {
                
                    // Case: respawned the respawn_youngest_tile, and there is ONLY a respawn_youngest_tile.
                    
                    respawn_youngest_tile = null;
                    
                    return;
                    
                } else if (respawn_youngest_tile.respawn_older_tile == respawn_oldest_tile) {
                
                    // Case: There are only two tiles. Clear the first one, and replace it with the second one.
                    
                    respawn_youngest_tile = respawn_oldest_tile;
                    respawn_youngest_tile.respawn_younger_tile = null;
                    respawn_youngest_tile.respawn_older_tile = null;
                    respawn_oldest_tile = null;
                    
                } else {
                
                    // Case: Remove the respawn_youngest_tile and increment the chain
                
                    respawn_youngest_tile = respawn_youngest_tile.respawn_older_tile;
                    respawn_youngest_tile.respawn_younger_tile = null;
                    
                }
            }
        }
        int frames_since_report = 0;
        long previous_report_time = millis();
        void try_report() {
            frames_since_report++;            
            long elapsed_time = millis() - previous_report_time;            
            if (elapsed_time > (Settings.TIME_PER_REPORT * 1000)) {
                this.report();
            }
        }
        void report() {
            long elapsed_time = millis() - previous_report_time;
            float frames_per_second = ((float)frames_since_report) / (elapsed_time / 1000);
            float seconds_since_simulation_start = (millis() / 1000.0);
            println("Time elapsed(" + ((float)elapsed_time/1000) + " / " + seconds_since_simulation_start + "), Frames since report(" + frames_since_report + "), Frames per second(" + frames_per_second + ")");
            print("\t(");
            for (int i = 0; i < world.species.size(); i++) {
                print(world.species.get(i).creatures.size());
                if (i+1 == world.species.size()) {
                    println(")");
                } else {
                    print(", ");
                }
            }            
            frames_since_report = 0;
            previous_report_time = millis();
        }
    }
    

    
    
    
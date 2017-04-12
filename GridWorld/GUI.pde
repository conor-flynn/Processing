    import java.awt.Toolkit;
    import java.awt.datatransfer.Clipboard;
    import java.awt.datatransfer.StringSelection;
    
    class GUI {
      
        World world;
        
        Creature creature;
      
        boolean mouseDown;
        PVector dragStart;
        PVector location;
        PVector worldCenter;
        float zoomLevel;
        PFont font;
        
        float elapsed_time_since_screen_clear;
        
        public GUI(World world) {
            this.world = world;
            this.creature = null;
            
            mouseDown = false;
            dragStart = new PVector();
            location = new PVector();
            zoomLevel = -1;
              
            float part = Settings.WORLD_WIDTH / 8.0;
            worldCenter = new PVector(-part, -part);
            
            font = createFont("Arial", 160, true);
            
            elapsed_time_since_screen_clear = 0f;
            
            resetPosition();
        }
        
        void resetPosition() {
            location.x = width/2;
            location.y = height/2;
            
            location.x += worldCenter.x;
            location.y += worldCenter.y;
            
            zoomLevel = .5;
            // ----
            location.x = 228;
            location.y = 14.65;
            zoomLevel = 0.3113;
        }
        
        void preDraw() {
            translate(location.x, location.y);
            scale(zoomLevel);
            
            if (Settings.SCREEN_CLEAR_TIMER > 0f) {
                elapsed_time_since_screen_clear += (1f / frameRate);
                if (elapsed_time_since_screen_clear >= Settings.SCREEN_CLEAR_TIMER) {
                    background(0,0,0);
                    elapsed_time_since_screen_clear -= Settings.SCREEN_CLEAR_TIMER;
                }
            }
            
        }
        
        void postDraw() {
            drawSpeciesInfo();
            drawSelectedCreature();
            noStroke();
        }
        /*
        void draw_world_connection(int dx, int dy, int ox, int oy, int channel) {
            // destination x, destination y, origin x, origin y, creature/tile, R G or B
            Tile origin = world.get_tile_at_point(ox, oy);
            assert(origin != null);
            
            float destx = world.get_tile_posx_by_index(dx);
            float desty = world.get_tile_posy_by_index(dy);
            
            float originx = world.get_tile_posx_by_index(ox);
            float originy = world.get_tile_posy_by_index(oy);
            
            if (channel == 0) {
                stroke(255,0,0);
            } else if (channel == 1) {
                stroke(0,255,0);
            } else if (channel == 2) {
                stroke(0,0,255);
            }
            if (type == 0) {
                strokeWeight(6);   
            } else {
                strokeWeight(3);
            }
            line(originx, originy, destx, desty);
        }
        */
        void drawSelectedCreature() {
            if (creature == null) {
                return; 
            }
            //creature.tile.debug_draw(color(100,100,100), 3);
            /*
            if (creature.markedForDeath) {
                //println("Creature leaving scope.");
                creature = null;
                return;
            }
            //println("...");
            Brain brain = creature.brain;
            ArrayList<Input> world_inputs = brain.world_inputs;
            int xx = creature.tile.get_x_index();
            int yy = creature.tile.get_y_index();
            for (Input input : world_inputs) {
                WorldConnection spot = input.connection;
                int newx = spot.x + xx;
                int newy = spot.y + yy;
                int channel = input.channel;
                draw_world_connection(newx, newy, xx, yy, channel);
            }
            */
        }
        void drawSpeciesInfo() {
            fill(255);
            textFont(font, 32);
            scale(1,-1);
            
            int species_index = -1;
            int global_max_gen = -1;
            
            int max_gen_index = -1;
            
            int xx = 5;//Settings.WORLD_WIDTH;
            int yy = 34;//-Settings.WORLD_WIDTH;
            
            int x0 = xx-5;
            int y0 = yy-35;
            int w0 = 1000;
            int h0 = 2500 + (150 * (world.species.size()));
            fill(255,0,0);
            rect(x0,y0,w0,h0);
            
            fill(255);
            text("Frame rate : " + frameRate, xx, yy);
            yy += 50;
            text("Targe rate : " + Settings.TARGET_FRAME_RATE, xx, yy);
            yy += 50;
            text("Generation : " + world.generation, xx, yy);
            yy += 50;
            text("Num tiles respawning : " + world.num_tiles_in_queue, xx, yy);
            yy += 50;
            text("Plant Matter Consumed : " + world.plantMatterConsumed, xx, yy);
            yy += 50;
            text("Creature Matter Consumed : " + world.creatureMatterConsumed, xx, yy);
            yy += 50;
            /*
            text("Asexual Reproduction : " + world.asexual_reproduction, xx, yy);
            yy += 50;
            text("Sexual Reproduction : " + world.sexual_reproduction, xx, yy);
            yy += 50;
            */
            text("Fresh spawn count : " + world.creature_fresh_spawn_counter, xx, yy);
            yy += 50;
            text("Useless Fresh spawns : " + world.creature_fresh_spawn_never_action, xx, yy);
            yy += 50;
            double prop = ((double)world.creature_fresh_spawn_never_action) / ((double)world.creature_fresh_spawn_counter);
            text("Percent useless spawns : " + prop, xx, yy);
            yy += 50;
            text("Creature NEVER action : " + world.creature_never_action, xx, yy);
            yy += 50;
            text("Creature no action : " + world.creature_no_action, xx, yy);
            yy += 50;
            text("Creature move action : " + world.creature_move_action, xx, yy);
            yy += 50;
            text("Creature sexual action : " + world.creature_sexual_action, xx, yy);
            yy += 50;
            // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
            // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
            // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
            for (int i = 0; i < world.species.size(); i++) {
                Species target = world.species.get(i);
                int max_gen = -1;
                int total_gen = 0;
                float average_brain_size = 0;
                float average_axon_size = 0;
                global_max_gen = -1;
                for (int j = 0; j < target.creatures.size(); j++) {
                    if (target.creatures.get(j).generation > max_gen) {
                       max_gen = target.creatures.get(j).generation;
                       if (max_gen > global_max_gen) {
                           global_max_gen = max_gen;
                           species_index = i;
                           max_gen_index = j;
                       }
                    }
                    total_gen += target.creatures.get(j).generation;
                    average_brain_size += target.creatures.get(j).brain.brain_size();
                    average_axon_size += target.creatures.get(j).brain.num_axons;
                }
                average_brain_size /= target.creatures.size();
                average_axon_size /= target.creatures.size();
                total_gen /= target.creatures.size();
                String popSize = "(" + world.species.get(i).creatures.size() + ")";
                String genCount = "(" + max_gen + ")";
                String avrCount = "(" + total_gen + ")";
                String avr_brain_count = "(" + average_brain_size + ")";
                String avr_axon_count = "(" + average_axon_size + ")";
                text("Population : " + popSize, xx, yy);
                yy += 50;
                text("---Max generation number : " + genCount, xx+50, yy);
                yy += 50;
                text("---Average generation number : " + avrCount, xx+50, yy);
                yy += 50;
                text("---Average brain size : " + avr_brain_count, xx+50, yy);
                yy += 50;
                text("--Average axon count : " + avr_axon_count, xx+50, yy);
                yy += 50;
            }
            // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
            // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
            // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
            scale(1,-1);
            
            // +~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~
            // +~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~
            // +~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~
            
            //if (species_index >= 0 && creature_index >= 0) {
            //    creature = world.species.get(species_index).creatures.get(creature_index); 
            //}
        }
        
        PVector mouseToScreen() {
            return new PVector(mouseX, mouseY - height); 
        }
        
        PVector mouseToWorld() {
            return screenToWorld(mouseToScreen()); 
        }
        
        // Assuming (0,0) is bottom left, (width,height) is top right
        PVector screenToWorld(PVector input) {
             float x = input.x;
             float y = input.y;
             x -= location.x;
             y += location.y;
             y *= -1;
             
             x /= zoomLevel;
             y /= zoomLevel;
             return new PVector(x,y);
        }
        
        Tile getTileFromMouse() {
            PVector loc = mouseToWorld();    
            if (loc.x < 0 || loc.x >= Settings.WORLD_WIDTH || loc.y < 0 || loc.y > Settings.WORLD_WIDTH) {
                //println("Searching for tile that is out of bounds.");
                return null;
            }            
            int x_index = floor(loc.x / Settings.TILE_WIDTH);
            int y_index = floor(loc.y / Settings.TILE_WIDTH);
            y_index = Settings.NUM_TILES - y_index;
            
            return world.get_tile_at_point(x_index, y_index);
        }
        Creature find_creature_near_tile(Tile target) {
            assert(target != null);
            
            int xx = target.get_x_index();
            int yy = target.get_y_index();
            
            int dist = 10;
            for (int x = -dist; x <= dist; x++) {
                for (int y = -dist; y <= dist; y++) {
                    int newx = x + xx;
                    int newy = y + yy;
                    Tile spot = world.get_tile_at_point(newx, newy);
                    if (spot != null && spot.creature != null) {
                        //spot.creature.__debugging = true;
                        return spot.creature;
                    }
                }
            }
            
            
            return null;
        }
        
        
        
        
        
        
        
        
        
        
        void mousePressed() {
            if (mouseButton == RIGHT) {
                Tile target = getTileFromMouse();
                if (target != null) {
                    creature = find_creature_near_tile(target);
                    if (creature == null) return;
                    println("Species pop size : " + creature.species.creatures.size());
                    println("Creature neuron count : " + (creature.brain.world_inputs.size() + creature.brain.worker_neurons.size()));
                    println("Creature additional mutation rate : " + creature.brain.additional_mutate_rate);
                    
                    Clipboard clipper = Toolkit.getDefaultToolkit().getSystemClipboard();
                    String s = creature.brain.printout_brain(false);
                    StringSelection data = new StringSelection(s);
                    clipper.setContents(data, data);
                }
            }
        }
        
        void mouseDragged(MouseEvent event) {
            location.x += mouseX - pmouseX;
            location.y -= mouseY - pmouseY;
        }
        
        void mouseReleased() {
        }        
        void mouseWheel(MouseEvent event) {
            location.x -= mouseX;
            location.y -= (height - mouseY);
            
            float speed = 1.05;
            float zoomIn = speed;
            float zoomOut = 1.0 / speed;
            
            float delta = event.getCount() > 0 ? zoomOut : event.getCount() < 0 ? zoomIn : 1.0;
            
            zoomLevel *= delta;
            location.x *= delta;
            location.y *= delta;
            
            location.x += mouseX;
            location.y += (height - mouseY);
        }        
        void keyPressed() {
            if (key == 'r') {
               resetPosition(); 
            } else if (key == 'k') {
               println("Location offset : (" + location.x + "," + location.y + ")");
               println("Zoom : (" + zoomLevel + ")");
            } else if (key == '`') {
               background(0,0,0); 
            }
            if (key == 'q') {
               Settings.TARGET_FRAME_RATE *= 1.1;
               if (Settings.TARGET_FRAME_RATE < 10) Settings.TARGET_FRAME_RATE++;
               frameRate(Settings.TARGET_FRAME_RATE);
            } else if (key == 'w') {
               Settings.TARGET_FRAME_RATE *= 0.9;
               if (Settings.TARGET_FRAME_RATE < 1) Settings.TARGET_FRAME_RATE = 1;
               frameRate(Settings.TARGET_FRAME_RATE);
            } else if (key == 'e') {
                background(0,0,0);
                Settings.DRAW_TILES = !Settings.DRAW_TILES;
            } else if (key == 'd') {
                Settings.ALWAYS_REDRAW = !Settings.ALWAYS_REDRAW;   
            } else if (key == 't') {
                Settings.DRAW_SIMULATION = !Settings.DRAW_SIMULATION;
                if (Settings.DRAW_SIMULATION == false) {
                    Settings.DEVELOPER_DEBUG_DRAW = false;
                    Settings.DRAW_CREATURES_BRAINS = false;
                    Settings.DRAW_SPECIES = false;
                    frameRate(99999);   
                    Settings.DRAW_SIMULATION_GENERATION_DELTA = world.generation;
                } else {
                    frameRate(Settings.TARGET_FRAME_RATE);
                    world.report();
                }
            } else if (key == 'y') {
                Settings.DEVELOPER_DEBUG_DRAW = !Settings.DEVELOPER_DEBUG_DRAW;
            } else if (key == 'u') {
                Settings.DRAW_CREATURES_BRAINS = !Settings.DRAW_CREATURES_BRAINS;
            } else if (key == 'g') {
                Settings.TIME_PER_REPORT += 1;
                println("Time per report(" + Settings.TIME_PER_REPORT + ")");
            } else if (key == 'h') {
                Settings.TIME_PER_REPORT -= 1;
                if (Settings.TIME_PER_REPORT < 1) Settings.TIME_PER_REPORT = 1;
                println("Time per report(" + Settings.TIME_PER_REPORT + ")");
            } else if (key == 'b') {
                Settings.DRAW_SPECIES = !Settings.DRAW_SPECIES;
            } else if (key == 'n') {
                Settings.DRAW_SPECIES_INDEX++;
                if (Settings.DRAW_SPECIES_INDEX >= Settings.NUM_SPECIES) {
                    Settings.DRAW_SPECIES_INDEX = 0;
                }
            } else if (key == 'v') {
                Settings.DRAW_SPECIES_INDEX--;
                if (Settings.DRAW_SPECIES_INDEX < 0) {
                    Settings.DRAW_SPECIES_INDEX = (Settings.NUM_SPECIES-1);
                }
            } else if (key == 'z') {
                Species target = world.species.get(Settings.DRAW_SPECIES_INDEX);
                for (Creature creature : target.creatures) {
                    if (random(1) < 0.1) {
                        creature.killCreature();
                    }
                }
            }
        }
    }
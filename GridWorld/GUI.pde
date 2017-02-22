/*

    Hilighting a species
    Hilighting a creature
      Hilighting similar colored creatures within the same species
      
      
    Drawing a brain
*/    

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
            //drawSelectedCreature();
        }
        
        void drawSelectedCreature() {
            //if (creature == null) {
            //    return; 
            //}
            //if (creature.markedForDeath) {
            //    println("Creature leaving scope.");
            //    creature = null;
            //    return;
            //}
            
            
            //ArrayList<ArrayList<Float>> neurons = creature.brain.neurons;
            //ArrayList<ArrayList<ArrayList<Float>>> axons = creature.brain.axons;
            
            //fill(255);
            //textFont(font, 32);
            //scale(1,-1);
            //float x = -200;
            //float y = 0;
            //float y_delta = -35;
            
            //for (int layer = 0; layer < neurons.size(); layer++) {
            //    ArrayList<Float> neuronLayer = neurons.get(layer);
                
            //    y = (-Settings.WORLD_WIDTH/2) - (y_delta * (neuronLayer.size()/2));
            //    for (int neuron = 0; neuron < neuronLayer.size(); neuron++) {
            //         float val = neuronLayer.get(neuron);
            //         //val *= 10;
            //         //val = (int)val;
            //         //val /= 10;
            //         text(val, x, y);
            //         y += y_delta;
            //    }
            //    x -= 200;
            //}
        }
        
        void drawSpeciesInfo() {
            fill(255);
            textFont(font, 32);
            scale(1,-1);
            
            int species_index = -1;
            int creature_index = -1;
            int global_max_gen = -1;
            
            int xx = 0;//Settings.WORLD_WIDTH;
            int yy = 24;//-Settings.WORLD_WIDTH;
            
            int x0 = xx-10;
            int y0 = yy-30;
            int w0 = 650;
            int h0 = 500 + (150 * (world.species.size()));
            fill(255,0,0);
            rect(x0,y0,w0,h0);
            
            fill(255);
            for (int i = 0; i < world.species.size(); i++) {
                Species target = world.species.get(i);
                int max_gen = -1;
                int total_gen = 0;
                int[] gen_numbers = new int[target.creatures.size()];
                for (int j = 0; j < target.creatures.size(); j++) {
                    if (target.creatures.get(j).generation > max_gen) {
                       max_gen = target.creatures.get(j).generation;
                       if (max_gen > global_max_gen) {
                           global_max_gen = max_gen;
                           species_index = i;
                           creature_index = j;
                       }
                    }
                    total_gen += target.creatures.get(j).generation;
                    gen_numbers[j] = target.creatures.get(j).generation;
                }
                gen_numbers = sort(gen_numbers);
                int half_index = gen_numbers.length / 2;
                total_gen /= target.creatures.size();
                String popSize = "(" + world.species.get(i).creatures.size() + ")";
                String genCount = "(" + max_gen + ")";
                String avrCount = "(" + total_gen + ")";
                String medCount = "(" + gen_numbers[half_index] + ")";
                text("Population : " + popSize, xx, yy);
                yy += 50;
                text("---Max generation number : " + genCount, xx+50, yy);
                yy += 50;
                text("---Average generation number : " + avrCount, xx+50, yy);
                yy += 50;
                text("---Medium generation number : " + medCount, xx+50, yy);
                yy += 50;
            }
            text("Frame rate : " + frameRate, xx, yy);
            yy += 50;
            text("Targe rate : " + Settings.TARGET_FRAME_RATE, xx, yy);
            yy += 50;
            text("Generation : " + world.generation++, xx, yy);
            yy += 50;
            text("Plant Matter Consumed : " + world.plantMatterConsumed, xx, yy);
            yy += 50;
            text("Creature Matter Consumed : " + world.creatureMatterConsumed, xx, yy);
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
                println("Searching for tile that is out of bounds.");
                return null;
            }
            
            int x_index = floor(loc.x / Settings.TILE_WIDTH);
            int y_index = floor(loc.y / Settings.TILE_WIDTH);
            
            int tile_index = x_index + (y_index * Settings.NUM_TILES);
            
            if (tile_index < 0 || tile_index >= (Settings.NUM_TILES * Settings.NUM_TILES)) {
                println("Fatal: getTileFromMouse() returning illegal tile index.");
                return null;
            }
            
            println("Tile(" + x_index + "," + y_index + ")");
            Tile tile = world.tiles.get(tile_index);
            if (tile.creature != null) {
                println("Creature(" + tile.creature.life + ")"); 
            }
            
            return world.tiles.get(tile_index);
        }
        
        
        
        
        
        
        
        
        
        
        
        void mousePressed() {
            Tile target = getTileFromMouse();
            if (target == null) {
                return; 
            } else {
                creature = null; 
            }
            if (target.creature != null) creature = target.creature;
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
            }
        }
    }
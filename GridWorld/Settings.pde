    
    Boolean FORCE_REDRAW = false;
    
    static class Settings {
      
         // Game settings
             static final String WORLD_FILE_NAME = "world4.json";
             static int TARGET_FRAME_RATE = 1000;
             static float SCREEN_CLEAR_TIMER = 0f;
      
         // World settings
             static int NUM_TILES = -1;
             static final int TILE_WIDTH = 30;
             static int WORLD_WIDTH = -1;
             
             static final PVector WORLD_BOT_LEFT_CORNER = new PVector(0, 0);
             static final PVector WORLD_BOT_RIGHT_CORNER = new PVector(WORLD_WIDTH, 0);
             static final PVector WORLD_TOP_LEFT_CORNER = new PVector(0, WORLD_WIDTH);
             static final PVector WORLD_TOP_RIGHT_CORNER = new PVector(WORLD_WIDTH, WORLD_WIDTH);
             
             static final float BIOME_BLUR_RATE = 0.2;
         
         // Evolution settings
             static final int NUM_SPECIES = 5;
             static final int NUM_CREATURES_PER_SPECIES = 20;
             
             static final float REPRODUCTION_EFFICIENCY = 1.0; // How much energy gets passed to the child. 0.3 means 70% of the energy is lost.
             static final float CREATURE_CHILD_SACRIFICE_AMOUNT = 0.45; // How much of the creatures life is devoted t the child.
             
             static final float CREATURE_MINIMUM_DECAY_AMOUNT = 0.01;
             static final int CREATURE_STALL_MUTATION_LIMIT = 10;
             static final int CREATURE_DEATH_AGE = 1000;
             static final float CREATURE_PLANT_EAT_AMOUNT = 0.1;
             static final float CREATURE_CREATURE_EAT_AMOUNT = 1;
             
             static final float CREATURE_MINIMUM_MOVEMENT_THRESHOLD = 0.01f;
             static final float CREATURE_MINIMUM_REPRODUCTIVE_THRESHOLD = 0.15f;
    }
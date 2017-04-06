    
    Boolean FORCE_REDRAW = false;
    
    static class Settings {
        
            static final int D_TOO_LONG = 5;
      
         // Game settings
             static final String WORLD_BIOME_DESCRIPTIONS = "world7.json";
             static final String WORLD_TILE_DESCRIPTIONS = "world7.bmp";
             static int TARGET_FRAME_RATE = 300;
             static final float SCREEN_CLEAR_TIMER = 0f;
             static boolean DRAW_TILES = true;
             static boolean ALWAYS_REDRAW = false;
             
             static boolean DRAW_SIMULATION = true;
             
             static int TIME_PER_REPORT = 15;
             
             
         // World settings
             static int NUM_TILES = -1;
             static final int TILE_WIDTH = 10;
             static int WORLD_WIDTH = -1;
             
             static final PVector WORLD_BOT_LEFT_CORNER = new PVector(0, 0);
             static final PVector WORLD_BOT_RIGHT_CORNER = new PVector(WORLD_WIDTH, 0);
             static final PVector WORLD_TOP_LEFT_CORNER = new PVector(0, WORLD_WIDTH);
             static final PVector WORLD_TOP_RIGHT_CORNER = new PVector(WORLD_WIDTH, WORLD_WIDTH);
             
             static final float BIOME_BLUR_RATE = 0.0;
         
         // Evolution settings
             static final int NUM_SPECIES = 10;
             static final int NUM_CREATURES_PER_SPECIES = 1;
             
             static final float CREATURE_EAT_CREATURE_MULTIPLIER = 0.95f;
             static final float CREATURE_EAT_PLANT_AMOUNT = 1.0f;
             //static final float CREATURE_REPRODUCTIVE_INEFFICIENCY_MULTIPLIER = 1.05f;    // For every 1 food given to child, 1.1 food is subtracted from parent
             static final float CREATURE_ASEXUAL_REPRODUCTION_COST = 1.05f;
             static final float CREATURE_SEXUAL_REPRODUCTION_COST  = 0.501f;
             static final int CREATURE_ASEXUAL_REPRODUCTIVE_LIMIT = 3;
             static final int CREATURE_SEXUAL_REPRODUCTIVE_LIMIT = 10;
             
             static final float CREATURE_MINIMUM_ACTION_THRESHOLD = 0.05f;
             
             static final int FOOD_TRAMPLE_RECOVERY_AMOUNT = 10;
             static final int CREATURE_FOOD_TRAMPLE_PER_FRAME = 0;
             static final int FOOD_TRAMPLE_AMOUNT_MAX = (FOOD_TRAMPLE_RECOVERY_AMOUNT * 3);
             
             //static final float FOOD_RESPAWN_TIME = 165f;
             static final float CREATURE_STARVATION_TIMER = 15f;    //45
             
             static final float CREATURE_BIRTH_FOOD = 1;
             static final float CREATURE_MAX_FOOD = 3;
             static final float FOOD_BIRTH_FOOD = 1;
             
             static final float OVER_EAT_PUNISHMENT = 0.25f;
             
             static final int CREATURE_DEATH_AGE = (int)(1000 * CREATURE_STARVATION_TIMER);
             
             static final float CREATURE_COLOR_MUTATION_AMOUNT = 3;
             
             static final int CREATURE_COLOR_SIMILARITY_THRESHOLD = 15; // [0 - 255]
             
             
             static final float CREATURE_MUTATION_RATE = 0.2f;
    }
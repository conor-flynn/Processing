    
    Boolean FORCE_REDRAW = false;
    
    static class Settings {
        
            static final int D_TOO_LONG = 5;
      
         // Game settings
             static final String WORLD_BIOME_DESCRIPTIONS = "earth1.json";
             static final String WORLD_TILE_DESCRIPTIONS = "earth1.bmp";
             static int TARGET_FRAME_RATE = 300;
             static final float SCREEN_CLEAR_TIMER = 0f;
             static boolean DRAW_TILES = true;
             static boolean ALWAYS_REDRAW = false;
             
             static boolean DRAW_SIMULATION = true;
             static boolean DEVELOPER_DEBUG_DRAW = false;
             static boolean DRAW_CREATURES_BRAINS = false;
             static int DRAW_SIMULATION_GENERATION_DELTA = 0;
             static boolean DRAW_SPECIES = false;
             static int DRAW_SPECIES_INDEX = 0;
             
             static int TIME_PER_REPORT = 10;
             
             
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
             static final int NUM_CREATURES_PER_SPECIES = 10;
             
             static final float CREATURE_EAT_CREATURE_MULTIPLIER = 0.95f;
             static final float CREATURE_EAT_PLANT_AMOUNT = 1.0f;
             //static final float CREATURE_REPRODUCTIVE_INEFFICIENCY_MULTIPLIER = 1.05f;    // For every 1 food given to child, 1.1 food is subtracted from parent
             static final float CREATURE_ASEXUAL_REPRODUCTION_COST = 9.0f;
             static final float CREATURE_SEXUAL_REPRODUCTION_COST  = 0.6f;
             static final int CREATURE_ASEXUAL_REPRODUCTIVE_LIMIT = 3;
             static final int CREATURE_SEXUAL_REPRODUCTIVE_LIMIT = 10;
             
             static final float CREATURE_MINIMUM_ACTION_THRESHOLD = 0.0005f;
             
             //static final float FOOD_RESPAWN_TIME = 165f;
             static final float CREATURE_STARVATION_TIMER = 20f;    //45
             
             static final float CREATURE_BIRTH_FOOD = 1;
             static final float CREATURE_MAX_FOOD = 10;
             
             static final float OVER_EAT_PUNISHMENT = 0.10f;
             
             static final int CREATURE_DEATH_AGE = (int)(20 * CREATURE_STARVATION_TIMER);
             
             static final float CREATURE_COLOR_MUTATION_AMOUNT = 2;
             
             
             static final float CREATURE_MUTATION_RATE_BASE = 0.01f;
             static final float CREATURE_MUTATION_RATE_ADDITIONAL_MUTATION_RATE = 0.01f;
             
             static final float AXON_INITIAL_AMOUNT = 0.01f;
             static final float AXON_MUTATION_AMOUNT = 0.0001;
             
             static final int CREATURE_BRAIN_SIZE_IGNORE = 450;
             static final float CREATURE_BRAIN_SIZE_PORTION = 30.0f;
             
             // ------
             static final int TILE_NOVELTY_EXPIRATION_FRAME_COUNT = 450;
             static final int NOVELTY_LOSS_PER_FRAME = 1;
             static final int NOVELTY_STARTING_POINT = 100;
             static final int TILE_NOVELTY_EXPIRATION_EXPONETIAL_FACTOR = 1;
             static final float NOVELTY_SEPARATION_RATE = 0.0;
             // ------
             static final int NOVELTY_REWARD_NEW_TILE = 100;
             static final int NOVELTY_REWARD_KILL_CREATURE = 1;
             // ------
    }
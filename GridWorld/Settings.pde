    
    Boolean FORCE_REDRAW = false;
    
    static class Settings {
      
         // Game settings
             static final String WORLD_FILE_NAME = "world4.json";
             static int TARGET_FRAME_RATE = 1000;
             static final float SCREEN_CLEAR_TIMER = 0f;
             static boolean DRAW_TILES = true;
             static boolean ALWAYS_REDRAW = false;
             
      
         // World settings
             static int NUM_TILES = -1;
             static final int TILE_WIDTH = 30;
             static int WORLD_WIDTH = -1;
             
             static final PVector WORLD_BOT_LEFT_CORNER = new PVector(0, 0);
             static final PVector WORLD_BOT_RIGHT_CORNER = new PVector(WORLD_WIDTH, 0);
             static final PVector WORLD_TOP_LEFT_CORNER = new PVector(0, WORLD_WIDTH);
             static final PVector WORLD_TOP_RIGHT_CORNER = new PVector(WORLD_WIDTH, WORLD_WIDTH);
             
             static final float BIOME_BLUR_RATE = 0.0;
         
         // Evolution settings
             static final int NUM_SPECIES = 3;
             static final int NUM_CREATURES_PER_SPECIES = 10;
             
             static final float CREATURE_EAT_CREATURE_MULTIPLIER = 1.5f;
             static final float CREATURE_EAT_PLANT_MULTIPLIER = 0.9f;
             
             static final float CREATURE_MINIMUM_MOVEMENT_THRESHOLD = 0.01f;
             static final float CREATURE_MINIMUM_REPRODUCTIVE_THRESHOLD = 0.15f;
             
             static final float FOOD_RESPAWN_TIME = 60f;
             static final float CREATURE_STARVATION_TIMER = 120f;    //45
             
             static final float CREATURE_BIRTH_FOOD = 1;
             static final float CREATURE_MAX_FOOD = 3;
             static final float FOOD_BIRTH_FOOD = 1;
             
             static final float OVER_EAT_PUNISHMENT = 2.25f;
             
             static final int CREATURE_REPRODUCTIVE_LIMIT = 3;
             static final int CREATURE_DEATH_AGE = (int)(5 * CREATURE_STARVATION_TIMER);
    }
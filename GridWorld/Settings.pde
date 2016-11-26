    static class Settings {
      
         // Game settings
             static int TARGET_FRAME_RATE = 60;
      
         // World settings
             static final int NUM_TILES = 50;
             static final int TILE_WIDTH = 30;
             static final int WORLD_WIDTH = NUM_TILES * TILE_WIDTH;
             
             static final PVector WORLD_BOT_LEFT_CORNER = new PVector(0, 0);
             static final PVector WORLD_BOT_RIGHT_CORNER = new PVector(WORLD_WIDTH, 0);
             static final PVector WORLD_TOP_LEFT_CORNER = new PVector(0, WORLD_WIDTH);
             static final PVector WORLD_TOP_RIGHT_CORNER = new PVector(WORLD_WIDTH, WORLD_WIDTH);
         
         // Evolution settings
             static final int NUM_FOOD = 200;
             static final int NUM_SPECIES = 5;
             static final int NUM_CREATURES_PER_SPECIES = 10;
             
             static final float FOOD_GROWTH_RATE = 0.01;
             static final float FOOD_SPAWN_AMOUNT = 1.0;
    }
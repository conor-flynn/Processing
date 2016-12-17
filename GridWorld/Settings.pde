    static class Settings {
      
         // Game settings
             static final String WORLD_FILE_NAME = "world2.json";
             static int TARGET_FRAME_RATE = 600;
      
         // World settings
             static int NUM_TILES = -1;
             static final int TILE_WIDTH = 30;
             static final int WORLD_WIDTH = NUM_TILES * TILE_WIDTH;
             
             static final PVector WORLD_BOT_LEFT_CORNER = new PVector(0, 0);
             static final PVector WORLD_BOT_RIGHT_CORNER = new PVector(WORLD_WIDTH, 0);
             static final PVector WORLD_TOP_LEFT_CORNER = new PVector(0, WORLD_WIDTH);
             static final PVector WORLD_TOP_RIGHT_CORNER = new PVector(WORLD_WIDTH, WORLD_WIDTH);
             
             static final float BIOME_BLUR_RATE = 0.2;
         
         // Evolution settings
             static final int NUM_FOOD = 200;
             static final int NUM_SPECIES = 5;
             static final int NUM_CREATURES_PER_SPECIES = 10;
             
             static final float FOOD_GROWTH_RATE = 0.3;
             static final float FOOD_SPAWN_AMOUNT = 1.0;
             
             static final float REPRODUCTION_EFFICIENCY = 0.95; // How much energy gets passed to the child. 0.3 means 70% of the energy is lost.
             static final float CREATURE_VS_CREATURE_EAT_EFFICIENCY = 0.9; // How much life is passed to the creature. At 0.9, a creature gains 90% of the life it eats.
             static final float CREATURE_VS_CREATURE_EAT_PROPORTION = 1.0; // How much of the creatures life is consumed each time. At 0.4, a creature chomps at 40% of their total life.
             static final float CREATURE_CHILD_SACRIFICE_AMOUNT = 0.45; // How much of the creatures life is devoted t the child.
    }
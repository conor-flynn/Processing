class Biome {
    String label;
    float   color_red,
            color_green,
            color_blue,
            
            tiles_per_creature,
            //food_spawn_rate,
            //food_energy_amount,
            //food_energy_growth_amount,
            
            movement_resistance,
            food_intensity,
            tile_intensity;
    
    public Biome(
      String label, 
      float color_red, 
      float color_green, 
      float color_blue,
      float tiles_per_creature,
      //float food_spawn_rate,
      //float food_energy_amount,
      //float food_energy_growth_amount,
      float movement_resistance,
      float food_intensity,
      float tile_intensity
      ) {
        this.label = label;
        this.color_red = color_red;
        this.color_green = color_green;
        this.color_blue = color_blue;
        
        this.tiles_per_creature = tiles_per_creature;
        //this.food_spawn_rate = food_spawn_rate;
        //this.food_energy_amount = food_energy_amount;
        //this.food_energy_growth_amount = food_energy_growth_amount;
        this.movement_resistance = movement_resistance;
        
        this.food_intensity = food_intensity;
        this.tile_intensity = tile_intensity;
    }
}
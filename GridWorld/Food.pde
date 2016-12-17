class Food extends Tile {
  
    float current_life;
    Biome biome;
    
    public Food(int xx, int yy, int ww, int index, Biome biome) {
        super(xx, yy, ww, index, biome);
        this.biome = biome;
        this.current_life = this.biome.food_energy_amount;
    }
    
    void update() {
        if (this.current_life < 0) {
            this.current_life = 0; 
        } else if (this.current_life < this.biome.food_energy_amount) {
            this.current_life += this.biome.food_energy_growth_amount;
        }
    }
    
    void draw() {
       //float percentage = (this.current_life - this.biome.food_energy_amount) / this.biome.food_energy_amount;
       //float difference = this.biome.food_intensity - this.biome.tile_intensity;
       //difference *= percentage;
       float percentage = 1 - (this.current_life - this.biome.food_energy_amount) / this.biome.food_energy_amount;
       percentage *= biome.food_intensity;
       fill(color(biome.color_red*percentage, biome.color_green*percentage, biome.color_blue*percentage));
       rect(x-w/2,y-w/2,w,w);
    }
}
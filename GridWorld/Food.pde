class Food extends Tile {
  
    float current_life;
    Biome biome;
    Boolean regrowing;
    
    public Food(int xx, int yy, int ww, int index, Biome biome) {
        super(xx, yy, ww, index, biome);
        this.biome = biome;
        this.current_life = this.biome.food_energy_amount;
        this.regrowing = false;
    }
    
    void update() {
        if (this.current_life < 0) {
            this.current_life = 0; 
        }
        if (this.current_life < this.biome.food_energy_amount) {
            this.current_life += this.biome.food_energy_growth_amount;
            this.regrowing = true;
        }
    }
    
    void draw() {
        if (shouldRedraw || regrowing || FORCE_REDRAW) {
            float percentage = 1 - (this.current_life - this.biome.food_energy_amount) / this.biome.food_energy_amount;
            percentage *= biome.food_intensity;
            fill(color(biome.color_red*percentage, biome.color_green*percentage, biome.color_blue*percentage));
            rect(x-w/2,y-w/2,w,w);   
            shouldRedraw = false;
            regrowing = false;
        }
    }
    
    float getLifePercentage() {
        return (this.current_life / biome.food_energy_amount); 
    }
    
    float getEvaluation() {
        float r = biome.color_red   * biome.food_intensity;
        float g = biome.color_green * biome.food_intensity;
        float b = biome.color_blue  * biome.food_intensity;
        float w = getLifePercentage();
        
        return (((r + g + b)/255.0) + w) * 0.25;
    }
}
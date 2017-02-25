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
            this.regrowing = true;
            this.current_life += this.biome.food_energy_growth_amount;
            
            if (this.current_life > this.biome.food_energy_amount) {
                this.current_life = this.biome.food_energy_amount;
                this.regrowing = false;
                this.shouldRedraw = true;
            }            
        } else {
            regrowing = false;
        }
    }
    
    void draw() {
        if (shouldRedraw || regrowing || FORCE_REDRAW) {
            float percentage = biome.food_intensity;
            fill(color(biome.color_red*percentage, biome.color_green*percentage, biome.color_blue*percentage));
            rect(x-w/2,y-w/2,w,w);   
            shouldRedraw = false;
            //regrowing = false;
        }
    }
    
    float getLifePercentage() {
        return (this.current_life / biome.food_energy_amount); 
    }
    float _get_evaluation(float value, float life_percentage) {
        float result = (value * biome.food_intensity) / 255.0f;
        result *= 0.7f;    // The food color is 70% of it
        result += (life_percentage * 0.3f);    // The life percentage is 30% of it
        if (result < 0f || result > 1.0f) {
            println("Error------");
            println(value);
            println(life_percentage);
            println(result);
            println(biome.food_intensity);
        }
        assert(result >= 0f && result <= 1.0f);
        return result;
    }
    float get_tile_evaluation_by_channel(int index) {
        assert(index >= 0 && index <= 2);
        
        float life_percentage = getLifePercentage();
        switch(index) {
            case 0:
                return _get_evaluation(biome.color_red, life_percentage);
            case 1:
                return _get_evaluation(biome.color_green, life_percentage);
            case 2:
                return _get_evaluation(biome.color_blue, life_percentage);
        }
        assert(false);
        return 0f;
    }
}
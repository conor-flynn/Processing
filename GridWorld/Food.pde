class Food extends Tile {
  
    float current_life;
    float original_life;
    
    Biome biome;
    boolean edible;
    
    public Food(int xx, int yy, int ww, int index, Biome biome) {
        super(xx, yy, ww, index, biome);
        this.biome = biome;
        
        this.original_life = Settings.FOOD_BIRTH_FOOD;
        this.current_life = this.original_life;
        
        this.edible = true;
    }
    void update() {
        
        if (this.creature != null) {
            this.edible = false;
            return;
        }
        if (this.current_life == this.original_life) {
            this.edible = true;
            return;
        }
        
        this.current_life += (1 / Settings.FOOD_RESPAWN_TIME);
        if (this.current_life >= this.original_life) {
            this.current_life = this.original_life;
            this.edible = true;
            shouldRedraw = true;
        }
    }
    void draw() {
        if (shouldRedraw || FORCE_REDRAW) {
            fill(
                color(
                    _get_evaluation(biome.color_red),
                    _get_evaluation(biome.color_green),
                    _get_evaluation(biome.color_blue)));
            rect(x-w/2,y-w/2,w,w);   
            shouldRedraw = false;
        }
    }
    float _get_evaluation(float value) {
        if (this.edible) {
            return (value * biome.food_intensity);   
        } else {
            return (value * biome.tile_intensity);
        }
    }
    float get_tile_evaluation_by_channel(int index) {
        assert(index >= 0 && index <= 2);
        
        switch(index) {
            case 0:
                return _get_evaluation(biome.color_red);
            case 1:
                return _get_evaluation(biome.color_green);
            case 2:
                return _get_evaluation(biome.color_blue);
        }
        assert(false);
        return 0f;
    }
}
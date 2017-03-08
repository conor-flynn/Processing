class Food extends Tile {
  
    float current_life;
    float original_life;
    int trampled;
    
    Biome biome;
    boolean edible;
    
    public Food(int xx, int yy, int ww, int index, Biome biome) {
        super(xx, yy, ww, index, biome);
        this.biome = biome;
        
        this.original_life = Settings.FOOD_BIRTH_FOOD;
        this.current_life = this.original_life;
        
        this.edible = true;
        
        trampled = 0;
    }
    void update() {
        
        if (this.creature != null) {
            this.edible = false;
            trampled += Settings.CREATURE_FOOD_TRAMPLE_PER_FRAME;
            return;
        }
        if (trampled > 0) {
            if (trampled > Settings.FOOD_TRAMPLE_AMOUNT_MAX) {
                trampled = Settings.FOOD_TRAMPLE_AMOUNT_MAX;
            }
            trampled--;
            return;
        } else trampled = 0;
        if (this.current_life == this.original_life) {
            this.edible = true;
            return;
        } else {
            this.current_life = this.original_life;
            this.edible = true;
            shouldRedraw = true;
        }
    }
    void draw() {
        if (shouldRedraw || FORCE_REDRAW) {
            fill(
                color(
                    _get_evaluation(biome.color_red)*255f,
                    _get_evaluation(biome.color_green)*255f,
                    _get_evaluation(biome.color_blue)*255f));
            rect(x-w/2,y-w/2,w,w);   
            shouldRedraw = false;
        }
    }
    float _get_evaluation(float value) {
        if (this.edible) {
            return (value * biome.food_intensity) / 255.0f;   
        } else {
            return (value * biome.tile_intensity) / 300.0f;        // Slightly darker -> indicates food
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
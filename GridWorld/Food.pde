class Food extends Tile {
    float amount;
    public Food(int xx, int yy, int ww, color cc, int index) {
        super(xx, yy, ww, cc, index);
        c = color(0,255,0);
        amount = Settings.FOOD_SPAWN_AMOUNT;
    }
    
    void update() {
        if (amount < 0) amount = Settings.FOOD_GROWTH_RATE;
        else if (amount < 1) {
            amount += Settings.FOOD_GROWTH_RATE;
            if (amount > 1) amount = 1;
        }
    }
    
    void draw() {
       float green = amount * 255;
       c = color(0, green, 0);
       super.draw();
    }
}
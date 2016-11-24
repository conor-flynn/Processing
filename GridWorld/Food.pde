class Food extends Tile {
    float amount;
    float growth = 0.0045;
    public Food(int xx, int yy, int ww, color cc, int index) {
        super(xx, yy, ww, cc, index);
        c = color(0,255,0);
        amount = 1;
    }
    
    void update() {
        if (amount < 0) amount = growth;
        else if (amount < 1) {
            amount += growth;
            if (amount > 1) amount = 1;
        }
    }
    
    void draw() {
       float green = amount * 255;
       c = color(0, green, 0);
       super.draw();
    }
}
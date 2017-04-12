class Color {
    color value;
    Color(color v) {
        this.value = v;
        this.value = ((this.value << 8) >> 8);
    }
    int red() {
        return ((value >> 16) & 0xFF);
    }
    int green() {
        return ((value >> 8) & 0xFF);
    }
    int blue() {
        return ((value) & 0xFF);
    }
    String get_print() {
        return ("(" + red() + "," + green() + "," + blue() + ")");
    }
    @Override
    public boolean equals(Object other) {
        if (other == this) return true;
        
        if (!(other instanceof Color)) return false;
        
        Color casted = (Color) other;
        boolean identical = (this.value == casted.value);
        //boolean identical = (red() == casted.red()) && (green() == casted.green()) && (blue() == casted.blue());
        return identical;
    }
    @Override
    public int hashCode() {
        return Objects.hash(value);
    }
}
class V3 {
    float v1, v2, v3;
    V3(float v1, float v2, float v3) {
        this.v1 = v1;
        this.v2 = v2;
        this.v3 = v3;
    }
    float[] to_array() {
        float[] v = new float[3];
        v[0] = v1;
        v[1] = v2;
        v[2] = v3;
        return v;
    }
    String get_print() {
        String result = "(" + v1 + "," + v2 + "," + v3 + ")";
        return result;
    }
}
class V2 {
    float v1, v2;
    V2(float v1, float v2) {
        this.v1 = v1;
        this.v2 = v2;
    }
    float[] to_array() {
        float[] v = new float[2];
        v[0] = v1;
        v[1] = v2;
        return v;
    }
}
class BiomeGroup {
    HashMap<Biome, Float> links = new HashMap<Biome, Float>();
    
    Biome get_random_biome() {
        float value = random(1);
        for (Map.Entry me : links.entrySet()) {
            float v = (float)me.getValue();
            if (v >= value) {
                return ((Biome)me.getKey());
            } else {
                value -= v;
            }
        }
        println("Failed.");
        for (Map.Entry me : links.entrySet()) {
            println(((Float)me.getValue()));
        }
        assert(false);
        return null;
    }
}
class Biome {
    
    private int num_cycles;
    
    private String label;
    
    private int[] life_time;
    
    private V3[] tile_color;
    private V2[] tile_type;
    
    private V3[] food_color;
    private V2[] food_type;
    private float[] food_fertility;
    private int[] food_neighbors;
    private int[] food_respawn_time;
    
    int year;
    int day;
    
    int         _life_time;
    float[]     _tile_color;
    float[]     _tile_type;
    float[]     _food_color;
    float[]     _food_type;
    float       _food_fertility;
    int         _food_neighbors;
    int         _food_respawn_time;
    
    @Override
    public boolean equals(Object other) {
        if (other == this) return true;
        
        if (!(other instanceof Biome)) return false;
        
        Biome casted = (Biome) other;
        return (label.equals(casted.label));
    }
    public Biome(String label, int num_cycles) 
    {
        this.num_cycles = num_cycles;
        this.label = label;
        this.life_time = new int[num_cycles];
        this.tile_color = new V3[num_cycles];
        this.tile_type = new V2[num_cycles];
        this.food_color = new V3[num_cycles];
        this.food_type = new V2[num_cycles];
        this.food_fertility = new float[num_cycles];
        this.food_neighbors = new int[num_cycles];
        this.food_respawn_time = new int[num_cycles];
        
        day = 0;
        year = 0;
        
        _life_time = -1;
        _tile_color = new float[3];
        _tile_type = new float[2];
        _food_color = new float[3];
        _food_type = new float[2];
        _food_fertility = -1;
        _food_neighbors = -1;
        _food_respawn_time = -1;
    }
    
    int get_num_cycles() { return num_cycles; }
    
    void set_life_time(int v, int i) { life_time[i] = v; }
    void set_tile_color(String[] v, int i) { load(tile_color, convertf(v), i); }
    void set_tile_type(String[] v, int i) { load(tile_type, convertf(v), i); }
    void set_food_color(String[] v, int i) { load(food_color, convertf(v), i); }
    void set_food_type(String[] v, int i) { load(food_type, convertf(v), i); }
    void set_food_fertility(float v, int i) { food_fertility[i] = v; }
    void set_food_neighbors(int v, int i) { food_neighbors[i] = v; }
    void set_food_respawn_time(int v, int i) { food_respawn_time[i] = v; }
    
    int get_life_time() {
        return _life_time;
    }
    void make_life_time() {
        _life_time = life_time[year];
    }
    float[] get_tile_color() {
        return _tile_color;
    }
    void make_tile_color() {
        _tile_color = interp(tile_color, year, day).to_array();
    }
    float[] get_tile_type() {
        return _tile_type;
    }
    void make_tile_type() {
        _tile_type = interp(tile_type, year, day).to_array();
    }
    float[] get_food_color() {
        return _food_color;
    }
    void make_food_color() {
        _food_color = interp(food_color, year, day).to_array();
    }
    float[] get_food_type() {
        return _food_type;
    }
    void make_food_type() {
        _food_type = interp(food_type, year, day).to_array();
    }
    float get_food_fertility() {
        return _food_fertility;
    }
    void make_food_fertility() {
        _food_fertility = interpf(food_fertility, year, day);
    }
    int get_food_neighbors() {
        return _food_neighbors;
    }
    void make_food_neighbors() {
        _food_neighbors = interpi(food_neighbors, year, day);
    }
    int get_food_respawn_time() {
        return _food_respawn_time;
    }
    void make_food_respawn_time() {
        _food_respawn_time = interpi(food_respawn_time, year, day);
    }
    
    
    void load(V3[] source, float[] vals, int index) {
        assert(vals.length == 3);
        V3 v = new V3(vals[0], vals[1], vals[2]);
        source[index] = v;
    }
    void load(V2[] source, float[] vals, int index) {
        assert(vals.length == 2);
        V2 v = new V2(vals[0], vals[1]);
        source[index] = v;
    }
    
    
    
    
    
    
    
    
    
    int get_first(int year, int day) {
        return year;   
    }
    int get_second(int year, int day) {
        int val = year+1;
        if (val >= num_cycles) {
            val = 0;
        }
        return val;
    }
    V3 interp(V3 first, V3 second, int year, int day) {
        int year_length = life_time[year];
        float particular = ((float)day) / ((float)year_length);
        
        float v1 = (1-particular)*(first.v1) + (particular)*(second.v1);
        float v2 = (1-particular)*(first.v2) + (particular)*(second.v2);
        float v3 = (1-particular)*(first.v3) + (particular)*(second.v3);
        
        return new V3(v1,v2,v3);
    }
    V2 interp(V2 first, V2 second, int year, int day) {
        int year_length = life_time[year];
        float particular = ((float)day) / ((float)year_length);
        
        float v1 = (1-particular)*(first.v1) + (particular)*(second.v1);
        float v2 = (1-particular)*(first.v2) + (particular)*(second.v2);
        
        return new V2(v1,v2);
    }
    V3 interp(V3[] data, int year, int day) {
        V3 first = data[get_first(year, day)];
        V3 second = data[get_second(year, day)];
        return interp(first, second, year, day);
    }
    V2 interp(V2[] data, int year, int day) {
        V2 first = data[get_first(year, day)];
        V2 second = data[get_second(year, day)];
        return interp(first, second, year, day);
    }
    float interpf(float[] data, int year, int day) {
        int first = get_first(year, day);
        int second = get_second(year, day);
        float v1 = data[first];
        float v2 = data[second];
        int year_length = life_time[first];
        float particular = ((float)day) / ((float)year_length);
        
        float result = (1-particular)*(v1) + (particular)*(v2);
        return result;
    }
    int interpi(int[] data, int year, int day) {
        int first = get_first(year, day);
        int second = get_second(year, day);
        float v1 = data[first];
        float v2 = data[second];
        int year_length = life_time[first];
        float particular = ((float)day) / ((float)year_length);
        
        float result = (1-particular)*(v1) + (particular)*(v2);
        return (int)result;
    }
    
    
    
    
    
    
    
    
    void update() {
        int life = get_life_time();
        if (life > 0) {
            day++;
            if (day >= life) {
                year++;
                day = 0;
                if (year >= get_num_cycles()) {
                    year = 0;
                }
            }
        }
        make_life_time();
        make_tile_color();
        make_tile_type();
        make_food_color();
        make_food_type();
        make_food_fertility();
        make_food_neighbors();
        make_food_respawn_time();
        
        /*
        println("-----------");
        println(day);
        println(year);
        println(get_life_time());
        println(get_tile_color());
        println(get_tile_type());
        println(get_food_color());
        println(get_food_type());
        println(get_food_fertility());
        println(get_food_neighbors());
        println(get_food_respawn_time());
        */
    }
}

float[] convertf(String[] data) {
    float[] result = new float[data.length];
    for (int i = 0; i < data.length; i++) {
        result[i] = Float.parseFloat(data[i]);
    }
    return result;
}
int[] converti(String[] data) {
    int[] result = new int[data.length];
    for (int i = 0; i < data.length; i++) {
        result[i] = Integer.parseInt(data[i]);
    }
    return result;
}
V3 string_array_to_v3(String[] data) {
    assert(data.length == 3);
    float[] f = convertf(data);    
    return new V3(f[0], f[1], f[2]);
}
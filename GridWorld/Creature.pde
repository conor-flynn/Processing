class Creature {
    Species species;
    
    Brain brain;
    
    Tile tile;
    float red,green,blue;
    
    float life;
    int age;
    int generation;
    boolean markedForDeath;   
    
    int asexual_reproductive_count = 0;
    int sexual_reproductive_count = 0;
    
    int direction;
    
    boolean fresh_spawn = false;
    boolean made_action_sometime_during_life = false;
    int frames_since_last_food = 0;
    
    Novelty novelty;
    
    public Creature(Species species) {
        this.species = species;
      
        markedForDeath = false;
        red = green = blue = -1;
          
        brain = null;
        life = -1;
        age = 0;
        generation = 0;
    }
    void killCreature() {
        if (markedForDeath) return;
        markedForDeath = true;
        species.preGrave.add(this);
        this.life = 0;
    }
    float get_loss() {
        float multiplier = (1f) + (brain.adjusted_brain_size() / 2000.0f);
        float amount = (1 / Settings.CREATURE_STARVATION_TIMER) * multiplier;
        float resist = tile.getMovementResistance(brain.tile_type);
        assert(resist >= 0);
        amount += resist;
        assert(amount > 0);
        return amount;
    }
    boolean lose_standard_life() {
        float amount = get_loss();
        this.life -= amount;
        if (this.life <= 0) {
            killCreature();
            return true;
        }
        return false;
    }
    void add_life(float amount) {
        if (Settings.DEVELOPER_DEBUG_DRAW) {
            if (amount > 0) {
                tile.debug_draw(color(0,0,0),7);
            }
        }
        this.life += amount;
        if (this.life > Settings.CREATURE_MAX_FOOD) {
            float over = (this.life - Settings.CREATURE_MAX_FOOD);
            over *= Settings.OVER_EAT_PUNISHMENT;
            assert(over >= 0);
            this.life = Settings.CREATURE_MAX_FOOD;
            this.life -= over;
        }
        if (this.life <= 0) {
            killCreature();
        }
    }
    
    
    
    
    
    
    
    
    
    void update() {
        assert(tile != null);
        assert(brain != null);
        assert(this.life <= Settings.CREATURE_MAX_FOOD);
        if (markedForDeath) return;

        
        if (lose_standard_life()) return;
        
        assert(this.life > 0);
        age++;
        if (asexual_reproductive_count >= Settings.CREATURE_ASEXUAL_REPRODUCTIVE_LIMIT) {
            killCreature();
            return;
        }
        if (sexual_reproductive_count >= Settings.CREATURE_SEXUAL_REPRODUCTIVE_LIMIT) {
            killCreature();
            return;
        }
        if (age > Settings.CREATURE_DEATH_AGE) {
            killCreature();
            return;
        }
        frames_since_last_food++;
        brain.process();
        ArrayList<Float> results = brain.process_results;
        assert(results.size() == (3));
        
        //float mov_x = results.get(0);
        //float mov_y = results.get(1);
        float mov = results.get(0);
        
        float a_sex = results.get(1);
        
        float direction = results.get(2);
        
        //assert(abs(mov_x) <= 1);
        //assert(abs(mov_y) <= 1);
        assert(abs(mov) <= 1);
        assert(abs(a_sex) <= 1);
        assert(abs(direction) <= 1);
        
        if (abs(direction) > Settings.CREATURE_MINIMUM_ACTION_THRESHOLD) {
            made_action_sometime_during_life = true;
            alter_direction(direction);   
        }
        
        if (a_sex > Settings.CREATURE_MINIMUM_ACTION_THRESHOLD) {
            if (!asexually_reproduce()) species.world.creature_no_action++;
        } else {
            if (!tryMove(mov)) species.world.creature_no_action++;   
        }
    }
    void rotate_by_int(int value) {
        direction += value;
        direction = modu(direction, 4);
    }
    void alter_direction(float amount) {
        if (amount < 0) {
            int val = ceil(amount / Settings.CREATURE_MINIMUM_ACTION_THRESHOLD);
            direction += val;
            direction = modu(direction, 4);
            assert(direction >= 0 && direction <= 3);
        } else {
            int val = floor(amount / Settings.CREATURE_MINIMUM_ACTION_THRESHOLD);
            direction += val;
            direction = modu(direction, 4);
            assert(direction >= 0 && direction <= 3);
        }
    }
    boolean asexually_reproduce() {
        made_action_sometime_during_life = true;
        species.world.creature_sexual_action++;
        if (markedForDeath) return true;
        
        /*
        if (this.life <= Settings.CREATURE_ASEXUAL_REPRODUCTION_COST) {
            killCreature();
            return;
        }
        */
        float energy_cost = get_energy_spent_asexually_reproducing();
        if (this.life <= energy_cost) {
            killCreature();
            return true;
        }
        
        int hope_x = 0;
        int hope_y = +1;
        int x_tile = get_rotated_x(hope_x, hope_y, direction);
        int y_tile = get_rotated_y(hope_x, hope_y, direction);
        x_tile += tile.get_x_index();
        y_tile += tile.get_y_index();
        
        Tile target = species.world.get_tile_at_point(x_tile, y_tile);
        if (target == null || target.creature != null) {
            killCreature();
            return true;
        }
        
        Creature newCreature = new Creature(species);
            newCreature.brain = new Brain(brain, newCreature);
            newCreature.copy_color(this);            
            newCreature.brain.mutate_count(1);
            newCreature.tile = null;
            
        target.creatureEntering(newCreature);
                 
            newCreature.generation = generation+1;
            newCreature.life = Settings.CREATURE_BIRTH_FOOD;
            newCreature.direction = direction;
            newCreature.rotate_by_int(2);
        species.creatures.add(newCreature);
        add_life(-energy_cost);
        asexual_reproductive_count++;
        if (Settings.DEVELOPER_DEBUG_DRAW) tile.debug_draw(color(255,0,255),5);
        return true;
    }
    void cross_with(Creature other) {
        assert(this.life > Settings.CREATURE_SEXUAL_REPRODUCTION_COST);
        assert(other.life > Settings.CREATURE_SEXUAL_REPRODUCTION_COST);
        
        int hope_x = 0;
        int hope_y = -1;
        int tile_x = get_rotated_x(hope_x, hope_y, direction);
        int tile_y = get_rotated_y(hope_x, hope_y, direction);
        tile_x += tile.get_x_index();
        tile_y += tile.get_y_index();
        
        Tile target = species.world.get_tile_at_point(tile_x, tile_y);
        if (target == null || target.creature != null) {
            killCreature();
            other.killCreature();
            return;
        }
        
        Creature newCreature = new Creature(species);
            newCreature.brain = new Brain(this.brain, other.brain, newCreature);
            newCreature.copy_color(this);            
            newCreature.brain.mutate_count(1);
            newCreature.tile = target;
            newCreature.tile.creature = newCreature;     
            newCreature.generation = generation+1;
            newCreature.life = Settings.CREATURE_BIRTH_FOOD;
        species.creatures.add(newCreature);
        
        this.add_life(-Settings.CREATURE_SEXUAL_REPRODUCTION_COST);
        assert(this.life > 0);
        other.add_life(-Settings.CREATURE_SEXUAL_REPRODUCTION_COST);
        assert(other.life > 0);
        sexual_reproductive_count++;
        species.world.sexual_reproduction++;
        if (Settings.DEVELOPER_DEBUG_DRAW) tile.debug_draw(color(255,255,255),5);
    }
    boolean tryMove(float val) {
        if (markedForDeath) return false;
        
        if (val > Settings.CREATURE_MINIMUM_ACTION_THRESHOLD) {
            made_action_sometime_during_life = true;
            species.world.creature_move_action++;
        } else {
            return false;
        }
        int move_tile = -approx_to_exact(val);
        int eat_tile = move_tile - 1;
        
        int move_x = get_rotated_x(0, move_tile, direction);
        int move_y = get_rotated_y(0, move_tile, direction);
        
        int eat_x = get_rotated_x(0, eat_tile, direction);
        int eat_y = get_rotated_y(0, eat_tile, direction);
        
        
        move_x += tile.get_x_index();
        move_y += tile.get_y_index();
        
        eat_x += tile.get_x_index();
        eat_y += tile.get_y_index();
        
        Tile target = species.world.get_tile_at_point(move_x, move_y);
        if (target == null) {
            // Trying to move to a tile that doesn't exist.
            killCreature();
            return false;
        }
        
        if (target.creature == null) {
            // Trying to move to an empty tile
            move_to_empty_tile(target);
            
            Tile next_target = species.world.get_tile_at_point(eat_x, eat_y);
            if (next_target == null) {
                // The next tile doesn't exist.
            } else {
                if (next_target.creature == null) {
                    // The next tile doesn't have a creature
                    if (next_target.isFood) {
                        eat_food_at_empty_tile(next_target);
                    }
                } else {
                    // The next tile has a creature
                    eat_creature(next_target.creature);
                }
            }
        } else {
            // Moving to a tile with a creature
            //species.world.tryToSexuallyReproduce(this, target.creature);
            return false;
        }
        return true;
    }
    void move_to_empty_tile(Tile destination) {
        int current_x = tile.get_x_index();
        int current_y = tile.get_y_index();
        int target_x = destination.get_x_index();
        int target_y = destination.get_y_index();
        
        assert( abs(current_x - target_x) <= 1 );
        assert( abs(current_y - target_y) <= 1 );
        
        float val = tile.getMovementResistance(brain.tile_type);
        assert(val >= 0);
        add_life(-val);
        tile.creatureLeaving(this);
        destination.creatureEntering(this);
    }
    void eat_food_at_empty_tile(Tile destination) {
        float val = destination.eatFood(brain.food_type);
        species.world.plantMatterConsumed += val;
        add_life(val);
        frames_since_last_food = 0;
        if (Settings.DEVELOPER_DEBUG_DRAW) tile.debug_draw(color(0,255,0),5);
    }
    void eat_creature(Creature target) {
        if (target.markedForDeath) return;
        if (target.life <= 0) {
            target.killCreature();
            return;
        }
        species.world.creatureMatterConsumed += target.life;
        add_life(target.life * Settings.CREATURE_EAT_CREATURE_MULTIPLIER);
        target.killCreature();
        if (Settings.DEVELOPER_DEBUG_DRAW) tile.debug_draw(color(255,0,0),5);
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
        
    float sig(float input) {
        float denom = 1 + exp(-input);
        return 1.0 / denom;
    }    
    float negsig(float input) {
       float val = sig(input); 
       val *= 2;
       return val-1;
    }    
    void buildColor() {
       red = random(255);
       green = random(255);
       blue = random(255);
    }    
    float clamp(float val, float lower, float upper) {
       if (val < lower) return lower;
       if (val > upper) return upper;
       return val;
    }
    void copy_color(Creature target) {
        red = target.red;
        green = target.green;
        blue = target.blue;
    }
    void mutate_color(float delta) {
        /*
        float delta = 2;
        float d1 = random(delta) - (delta/2);
        float d2 = random(delta) - (delta/2);
        float d3 = random(delta) - (delta/2);
        */
        float val = delta;
        float d1 = random(-val, +val);
        float d2 = random(-val, +val);
        float d3 = random(-val, +val);
        
        red   += d1;
        green += d2;
        blue  += d3;
        
        red = clamp(red, 0, 255);
        green = clamp(green, 0, 255);
        blue = clamp(blue, 0, 255);
    }
    int approx_to_exact(float val) {
        return (int)roundAway(val);   
    }
    float roundAway(float val) {
        if (val < 0) {
            return floor(val); 
        } else {
            return ceil(val);
        }
    }
    float[] get_color() {
        float[] cc = new float[3];
        cc[0] = red;
        cc[1] = green;
        cc[2] = blue;
        return cc;
    }
    
    
    
    
    
    
    
    
    
    
    void draw() {
      
        if (tile == null) {
            println("Invalid tile for this creature");
            return;
        }
        
        int x = tile.x;
        int y = tile.y;
        int w = tile.w;
        
        x += 5;
        y += 5;
        
        x -= w/2;
        y -= w/2;     
        
        w -= 10;
        fill(color(red, green, blue));        
        rect(x,y,w,w);
        if (Settings.DRAW_CREATURES_BRAINS) {
            draw_facing_direction();
            draw_brain();
        }
    }
    void draw_brain() {
        int xx = tile.get_x_index();
        int yy = tile.get_y_index();
        yy -= 1;
        for (Input input : brain.world_inputs) {
            WorldConnection spot = input.connection;
            int newx = get_rotated_x(spot.x, spot.y, direction) + xx;
            int newy = get_rotated_y(spot.x, spot.y, direction) + yy;
            int channel = input.channel;
            draw_world_connection(newx, newy, xx, yy, channel);
        }
    }
    void draw_world_connection(int dx, int dy, int ox, int oy, int channel) {
        // destination x, destination y, origin x, origin y, creature/tile, R G or B
        //Tile origin = world.get_tile_at_point(ox, oy);
        //assert(origin != null);
        
        float destx = world.get_tile_posx_by_index(dx);
        float desty = world.get_tile_posy_by_index(dy);
        
        float originx = world.get_tile_posx_by_index(ox);
        float originy = world.get_tile_posy_by_index(oy);
        
        float slope_x = (destx - originx);
        float slope_y = (desty - originy);
        
        float perpx = get_rotated_x(slope_x, slope_y, 1);
        float perpy = get_rotated_y(slope_x, slope_y, 1);
        
        float mag = pow((perpx*perpx) + (perpy*perpy), 0.5f);
        perpx /= mag;
        perpy /= mag;
        
        perpx*= 2;
        perpy*= 2;
        
        if (channel == 0) {
            originx += perpx;
            originy += perpy;
            destx += perpx;
            desty += perpy;
            stroke(255,0,0);
        } else if (channel == 1) {
            stroke(0,255,0);
        } else if (channel == 2) {
            originx -= perpx;
            originy -= perpy;
            destx -= perpx;
            desty -= perpy;
            stroke(0,0,255);
        }
        strokeWeight(1);
        line(originx, originy, destx, desty);
    }
    void draw_facing_direction() {
        int dirx = 0;
        int diry = 0;
        if (direction == 0) {
            dirx = 0;
            diry = 1;
        } else if (direction == 1) {
            dirx = 1;
            diry = 0;
        } else if (direction == 2) {
            dirx = 0;
            diry = -1;
        } else if (direction == 3) {
            dirx = -1;
            diry = 0;
        }
        stroke(255,255,255);
        strokeWeight(0);
        int centerx = (int)(tile.x);
        int centery = (int)(tile.y);
        int line_length = 20;
        dirx *= line_length;
        diry *= line_length;
        line(centerx, centery, centerx+dirx, centery+diry);
    }
    float get_energy_spent_asexually_reproducing() {
        float v = (1 + ((brain.adjusted_brain_size()) / Settings.CREATURE_BRAIN_SIZE_PORTION));
        if (v > (Settings.CREATURE_MAX_FOOD-1)) return (Settings.CREATURE_MAX_FOOD-1);
        else return v;
    }
    int genome_distance(Creature other) {
        return floor(random(0, 30));
    }
}
class Novel {
    Tile current;
    Novel younger;
    Novel older;
    long expire_frame;
}
class Novelty {
    World world;
    Novel oldest;
    Novel youngest;
    HashMap<Tile, Novel> links;
    Novelty deep_copy() {
        Novelty new_novelty = new Novelty();
        
        new_novelty.world = world;
        
        Novel worker = youngest;
        while (worker != null) {
            links.put(worker.current, make_new_novel(worker.current, worker.expire_frame));
        }
        
        return new_novelty;
    }
    void update() {
        if (youngest == null) return;
        
        int gen = world.generation;
        while(youngest != null && (youngest.expire_frame <= gen)) {
            links.remove(youngest.current);
            
            if (youngest.older == null) {
            
                // Case: respawned the respawn_youngest_tile, and there is ONLY a respawn_youngest_tile.
                
                youngest = null;
                
                return;
                
            } else if (youngest.older == oldest) {
            
                // Case: There are only two tiles. Clear the first one, and replace it with the second one.
                
                youngest = oldest;
                youngest.younger = null;
                youngest.older = null;
                oldest = null;
                
            } else {
            
                // Case: Remove the respawn_youngest_tile and increment the chain
            
                youngest = youngest.older;
                youngest.younger = null;
                
            }
        }
    }
    boolean add_tile(Tile worker, long expire_frame) {
        // returns true if this is novel
        Novel target = links.get(worker);
        if (target == null) {
            target = make_new_novel(worker, expire_frame);
            links.put(worker, target);
            return true;
        } else {
            update_novel(target, expire_frame);
            return false;
        }
    }
    void update_novel(Novel worker, long expire_frame) {
        Tile temp = worker.current;
        assert(worker.expire_frame != expire_frame);    // Right?????????????///
        links.remove(temp);
        
        if (worker.younger == null) {
            youngest = null;
        } else if (worker.older == null) {
            oldest = oldest.younger;
            oldest.older = null;
        }
        worker = null;
        Novel new_novel = make_new_novel(temp, expire_frame);
        links.put(temp, new_novel);        
    }
    Novel make_new_novel(Tile _worker, long expire_frame) {
        Novel new_novel = new Novel();
        new_novel.current = _worker;
        new_novel.expire_frame = expire_frame;
        
        if (youngest == null) {
    
            // Case: there is no chain that exists
            
            youngest = new_novel;
            youngest.younger = null;
            youngest.older = null;
            assert(oldest == null);
            
            return new_novel;
        } else if (oldest == null) {
            
            // Case: there is a chain of 1 item
            
            if (youngest.expire_frame <= new_novel.expire_frame) {
            
                // Case:
                    // There was only a 'respawn_youngest_tile'. 
                    // The new link should go after the 'respawn_youngest_tile'
            
                oldest = new_novel;
                
                youngest.older = oldest;
                youngest.older.younger = youngest;
                youngest.older.older = null;
                
                return new_novel;
            } else {
            
                // Case:
                    // There was only a 'respawn_youngest_tile'. 
                    // The new link should go before the 'respawn_youngest_tile'
            
                oldest = youngest;
                youngest = new_novel;
                
                youngest.younger = null;
                youngest.older = oldest;
                youngest.older.younger = youngest;
                youngest.older.older = null;
                
                return new_novel;
            }
        }
        if (oldest.expire_frame <= new_novel.expire_frame) {
        
            // Case:
                // The new link should be added to the end of the chain
        
            new_novel.younger = oldest;
            new_novel.younger.older = new_novel;
            
            oldest = new_novel;
            
            return new_novel;
            
        } else {
        
            // Case:
                // The respawn time is less than the oldest tile, 
                // so it has to be inserted somewhere into the chain
                
            Novel worker = oldest;
            
            while (true) {
            
                worker = worker.younger;
                if (worker == null) {
                    
                    // Case: worker is null, 'guy' should be inserted in front of the youngest tile
                    
                    new_novel.younger = null;
                    new_novel.older = youngest;
                    new_novel.older.younger = new_novel;
                    
                    youngest = new_novel;
                    
                    return new_novel;
                }
                
                if (worker.expire_frame <= new_novel.expire_frame) {
                    
                    // Case: Adding somewhere in the middle of the chain
                    
                    new_novel.younger = worker;
                    new_novel.older = worker.older;
                    
                    new_novel.younger.older = new_novel;
                    new_novel.older.younger = new_novel;
                    
                    return new_novel;
                
                }
            }
        }
    }
}
class CreatureLink {
    Creature creature;
    
    CreatureLink left;    int left_distance;
    CreatureLink right;   int right_distance;    
    
    void set_left(CreatureLink source) {
        left = source;
        left_distance = creature.genome_distance(left.creature);
    }
    void set_right(CreatureLink source) {
        right = source;
        right_distance = creature.genome_distance(right.creature);
    }
}
class Genome {
    
    CreatureLink origin;
    int num_creatures;
    
    void add_random_creature(Creature creature) {
        
        // Adds the random creature to a random point in the genome
        
        int splice = floor(random(0, num_creatures));
        CreatureLink worker = origin;
        for (int i = 0; i < splice; i++) {
            worker = worker.right;
        }
        
        CreatureLink new_link = new CreatureLink();
        
        new_link.creature = creature;
        new_link.set_left(worker);
        new_link.set_right(worker.right);
        
        new_link.left.set_right(new_link);
        new_link.right.set_left(new_link);
        
    }
    
    void add_offspring(CreatureLink parent, Creature child_creature) {
        int distance = parent.creature.genome_distance(child_creature);
        if (distance == 0) {
            // Just put it on the left or right
        } else {
            
        }
    }
}
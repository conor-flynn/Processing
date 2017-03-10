import java.util.Map;

class Brain {
  
    Creature creature;
    Parameters params;
    ArrayList<Float> process_results = new ArrayList<Float>();
    ArrayList<Input> world_inputs = new ArrayList<Input>();
    HashMap<Integer, Neuron> worker_neurons = new HashMap<Integer, Neuron>();
    HashMap<Integer, Neuron> output_neurons = new HashMap<Integer, Neuron>();
    int neuron_id_count = 0;
    
    Neuron constant_neuron;
    Neuron random_neuron;
    
    Neuron life_neuron;
    Neuron timer_1_neuron;
    boolean timer_1_direction = true;
    Neuron timer_2_neuron;
    boolean timer_2_direction = true;
    
    Neuron age_neuron;
    Neuron reproductive_neuron;
    
    Memory memory_1;
    Memory memory_2;
    
    int special_inputs_count = 9;
    
    Brain(Creature creature) {
        this.creature = creature;
        // Output setup
        {
            assert(neuron_id_count >= 0 && neuron_id_count < 3);
            
            output_neurons.put(neuron_id_count, new Neuron(neuron_id_count));
            neuron_id_count++;
            process_results.add(0f);
            
            output_neurons.put(neuron_id_count, new Neuron(neuron_id_count));
            neuron_id_count++;
            process_results.add(0f);
            
            output_neurons.put(neuron_id_count, new Neuron(neuron_id_count));
            neuron_id_count++;
            process_results.add(0f);
            
            output_neurons.put(neuron_id_count, new Neuron(neuron_id_count));
            neuron_id_count++;
            process_results.add(0f);
            
            output_neurons.put(neuron_id_count, new Neuron(neuron_id_count));
            neuron_id_count++;
            process_results.add(0f);
            
            output_neurons.put(neuron_id_count, new Neuron(neuron_id_count));
            neuron_id_count++;
            process_results.add(0f);
            
            output_neurons.put(neuron_id_count, new Neuron(neuron_id_count));
            Neuron memory_input_1 = new Neuron(-2);
            memory_1 = new Memory(memory_input_1, output_neurons.get(neuron_id_count));
            neuron_id_count++;
            process_results.add(0f);
            
            output_neurons.put(neuron_id_count, new Neuron(neuron_id_count));
            Neuron memory_input_2 = new Neuron(-2);
            memory_2 = new Memory(memory_input_2, output_neurons.get(neuron_id_count));
            neuron_id_count++;
            process_results.add(0f);
        }
        
        int num_initial_workers = 0;
        for (int i = 0; i < num_initial_workers; i++) {
            worker_neurons.put(neuron_id_count, new Neuron(neuron_id_count));
            neuron_id_count++;    
        }
        
        constant_neuron = new Neuron(-2);
        random_neuron = new Neuron(-2);
        life_neuron = new Neuron(-2);
        timer_1_neuron = new Neuron(-2);
        timer_2_neuron = new Neuron(-2);
        age_neuron = new Neuron(-2);
        reproductive_neuron = new Neuron(-2);
        
        params = new Parameters();
        
        for (int i = 0; i < 8; i++) {
            add_new_input();
            add_new_input();
            add_new_connection_from_any_input();
            add_new_connection_from_any_input();
            bisect_any_connection();
            add_any_new_connection();
            add_any_new_connection();
        }
    }
    int brain_size() {
        return (20*world_inputs.size()) + (worker_neurons.size());   
    }
    float _brain_size_multiplier() {        
        return (1f + (brain_size() / params.brain_size_multiplier_divider));
    }
    void add_any_new_connection() {
        
        int choice =  (world_inputs.size()) 
                    + (special_inputs_count) 
                    + (worker_neurons.size()) 
                    + (output_neurons.size());
                    
        int index = ((int)random(0, choice));
        if (choice < (world_inputs.size() + special_inputs_count)) {
            add_new_connection_from_any_input();
        } else {
            add_new_connection_from_middle_neuron_to_middle_neuron_or_output_neuron();
        }
    }
    void mutate_count(int x) {
        while (x > 0) {
            mutate();
            x--;
        }
    }
    void mutate() {
        
        if (random(1) > 0.10f) return;
        //if (random(1) < params.ichance_mutate_parameters) params.mutate();
        
        if (random(1) < params.chance_bisect_any_connection) {
            // TODO: Add new connections from THIS new bisection
            bisect_any_connection();
            add_any_new_connection();
            add_any_new_connection();
        }
        if (random(1) < params.chance_add_new_input){
            // TODO: Add new connections from THIS new input
            add_new_input();
            add_any_new_connection();
            add_any_new_connection();
        }
        if (random(1) < params.chance_remove_world_input) remove_world_input();
        if (random(1) < params.chance_remove_random_middle_neuron) remove_random_middle_neuron();
        if (random(1) < params.chance_remove_random_axon) remove_random_axon();
        if (random(1) < params.chance_add_any_new_connection) add_any_new_connection();
        if (random(1) < params.chance_mutate_any_axon) mutate_any_axon();
        
        creature.mutate_color(params.creature_color_mutation_range);
    }
    void remove_random_axon_from_special_inputs() {
        Neuron source = get_random_special_neuron();
        if (source.neuron_connections.size() == 0) return;
        
        int index = ((int)random(0, source.neuron_connections.size()));
        Axon axon = source.neuron_connections.get(index);
        
        Neuron target = get_middle_or_end_neuron_from_id(axon.target_id);
        assert(--target.static_connections_count >= 0);
        source.neuron_connections.remove(index);
    }
    void remove_random_axon_from_world_inputs() {
        Input source = get_random_world_input();
        if (source == null) return;
        if (source.neuron_connections.size() == 0) return;
        int index = ((int)random(0, source.neuron_connections.size()));
        Axon axon = source.neuron_connections.get(index);
        
        Neuron target = get_middle_or_end_neuron_from_id(axon.target_id);
        assert(--target.static_connections_count >= 0);
        source.neuron_connections.remove(index);
    }
    void remove_random_axon_from_random_middle_neuron() {
        Neuron source = get_random_worker_neuron();
        if (source == null) return;
        if (source.neuron_connections.size() == 0) return;
        
        int index = ((int)random(0, source.neuron_connections.size()));
        Axon axon = source.neuron_connections.get(index);
        
        Neuron target = get_middle_or_end_neuron_from_id(axon.target_id);
        assert(--target.static_connections_count >= 0);
        source.neuron_connections.remove(index);
    }
    void remove_random_axon() {
        int choice = (special_inputs_count) + (world_inputs.size()) + (worker_neurons.size());
        
        if (choice < special_inputs_count) {
            remove_random_axon_from_special_inputs();
            return;
        }
        choice -= special_inputs_count;
        if (choice < world_inputs.size()) {
            remove_random_axon_from_world_inputs();
            return;
        } else {
            remove_random_axon_from_random_middle_neuron();
            return;
        }
    }
    void remove_connections_from_any_input_to_neuron(Neuron target) {
        
        remove_connections_from_world_inputs_to_neuron(target);        
        
        remove_connections_from_special_input_to_neuron(constant_neuron,           target);
        remove_connections_from_special_input_to_neuron(random_neuron,             target);
        remove_connections_from_special_input_to_neuron(life_neuron,               target);
        remove_connections_from_special_input_to_neuron(timer_1_neuron,            target);
        remove_connections_from_special_input_to_neuron(timer_2_neuron,            target);
        remove_connections_from_special_input_to_neuron(age_neuron,                target);
        remove_connections_from_special_input_to_neuron(reproductive_neuron,       target);
        remove_connections_from_special_input_to_neuron(memory_1.input_neuron,     target);
        remove_connections_from_special_input_to_neuron(memory_2.input_neuron,     target);
    }
    void remove_connections_from_special_input_to_neuron(Neuron source, Neuron target) {
        for (int i = 0; i < source.neuron_connections.size(); i++) {
            if (source.neuron_connections.get(i).target_id == target.neuron_id) {
                source.neuron_connections.remove(i);
                assert(--target.static_connections_count >= 0);
                i--;
            }
        }
        for (Axon axon : source.neuron_connections) {
            assert(axon.target_id != target.neuron_id);   
        }
    }
    void remove_connections_from_world_inputs_to_neuron(Neuron target) {
        for (Input input : world_inputs) {
            for (int i = 0; i < input.neuron_connections.size(); i++) {
                if (input.neuron_connections.get(i).target_id == target.neuron_id) {
                    input.neuron_connections.remove(i);
                    assert(--target.static_connections_count >= 0);
                    i--;
                }
            }
        }
        for (Input input : world_inputs) {
            for (Axon axon : input.neuron_connections) {
                assert(axon.target_id != target.neuron_id);
            }
        }
    }
    void remove_connections_from_middle_neurons_to_middle_neuron(Neuron target) {
        for (Map.Entry me : worker_neurons.entrySet()) {
            Neuron source = ((Neuron)me.getValue());
            if (source.neuron_id == target.neuron_id) continue;
            for (int i = 0; i < source.neuron_connections.size(); i++) {
                if (source.neuron_connections.get(i).target_id == target.neuron_id) {
                    source.neuron_connections.remove(i);
                    assert(--target.static_connections_count >= 0);
                    i--;
                }
            }
        }
        for (Map.Entry me : worker_neurons.entrySet()) {
            for (Axon axon : ((Neuron)me.getValue()).neuron_connections) {
                assert(axon.target_id != target.neuron_id);
            }
        }
    }
    void remove_middle_neuron(Neuron source) {
        assert(source != null);
        assert(source.static_connections_count >= 0);
        remove_connections_from_any_input_to_neuron(source);
        remove_connections_from_middle_neurons_to_middle_neuron(source);
        
        if (source.static_connections_count != 0) {
            println(source.static_connections_count);
        }
        assert(source.static_connections_count == 0);
        
        for (Axon axon : source.neuron_connections) {
            Neuron target = get_middle_or_end_neuron_from_id(axon.target_id);
            assert(--target.static_connections_count >= 0);
        }
        
        worker_neurons.remove(source.neuron_id);
    }
    void remove_random_middle_neuron() {
        Neuron source = get_random_worker_neuron();
        if (source == null) return;
        remove_middle_neuron(source);
    }
    void remove_world_input() {
        
        if (world_inputs.size() == 0) return;
        
        int choice = ((int)random(0, world_inputs.size()));
        Input input = world_inputs.get(choice);
        for (Axon axon : input.neuron_connections) {
            Neuron target = get_middle_or_end_neuron_from_id(axon.target_id);
            assert(--target.static_connections_count >= 0);
        }
        world_inputs.remove(choice);
    }
    Brain(Brain a, Brain b, Creature creature) {
        
    }
    Brain(Brain source, Creature creature) {
        this.creature = creature;
        
        for (Float f : source.process_results) process_results.add(0f);
        for (Input inp : source.world_inputs) world_inputs.add(inp.deep_copy());
        for (Map.Entry me : source.worker_neurons.entrySet()) {
            Neuron neuron = ((Neuron)me.getValue());
            worker_neurons.put(neuron.neuron_id, neuron.deep_copy());
        }
        for (Map.Entry me : source.output_neurons.entrySet()) {
            Neuron neuron = ((Neuron)me.getValue());
            output_neurons.put(neuron.neuron_id, neuron.deep_copy());
        }
        neuron_id_count = source.neuron_id_count;
        
        constant_neuron = source.constant_neuron.deep_copy();
        random_neuron   = source.random_neuron.deep_copy();
        
        timer_1_neuron = source.timer_1_neuron.deep_copy();
        timer_2_neuron = source.timer_2_neuron.deep_copy();
        life_neuron = source.life_neuron.deep_copy();
        
        age_neuron = source.age_neuron.deep_copy();
        reproductive_neuron = source.reproductive_neuron.deep_copy();
        
        memory_1 = source.memory_1.deep_copy();
        memory_2 = source.memory_2.deep_copy();
        
        params = source.params.deep_copy();
    }
    void mutate_any_axon() {
        // Axons aren't weighted evenly
        int index = (world_inputs.size()) + (worker_neurons.size()) + (special_inputs_count);
        int choice = ((int)random(0, index));
        
        if (choice < special_inputs_count) {
            mutate_special_input_axon();
            return;
        }
        choice -= special_inputs_count;
        
        if (choice < world_inputs.size()) {
            mutate_input_axon();
        } else {
            mutate_worker_neuron_axon();
        }
    }
    void mutate_special_input_axon() {
        ArrayList<Axon> axons = get_random_special_neuron().neuron_connections;
        if (axons.size() == 0) return;
        Axon worker = get_random_axon_from_axons(axons);
        assert(worker != null);
        worker.weight += random(-params.axon_weight_mutation_range, params.axon_weight_mutation_range);
    }
    void mutate_input_axon() {
        
        assert(world_inputs.size() > 0);
        Input source = get_random_world_input();
        assert(source != null);
        if (source.neuron_connections.size() == 0) return;
        
        Axon worker = get_random_axon_from_input(source);
        assert(worker != null);
        worker.weight += random(-params.axon_weight_mutation_range, params.axon_weight_mutation_range);         
    }
    void mutate_worker_neuron_axon() {
        if (worker_neurons.size() == 0) return;
        Neuron source = get_random_worker_neuron();
        if (source == null) return;
        
        if (source.neuron_connections.size() == 0) return;
        
        Axon worker = get_random_axon_from_neuron(source);
        assert(worker != null);
        worker.weight += random(-params.axon_weight_mutation_range, params.axon_weight_mutation_range); 
    }
    boolean has_connection(int original_neuron_id, int current_neuron_id) {
        if (original_neuron_id == current_neuron_id) return true;
        
        Neuron current = get_middle_or_end_neuron_from_id(current_neuron_id);
        assert(current != null);
        
        for (Axon axon : current.neuron_connections) {
            if (has_connection(original_neuron_id, axon.target_id)) return true;
        }
        return false;
    }
    boolean try_to_form_connection(Neuron source, Neuron target) {
        if (!has_connection(source.neuron_id, target.neuron_id)) {
            form_connection(source, target);
            return true;
        }
        return false;
    }
    void form_connection(Neuron source, Neuron target) {
        assert(output_neurons.get(source.neuron_id) == null);
        if (source.neuron_id == target.neuron_id) {
            return;  
        }
        // Assumes there is no connection already
        Axon new_axon = new Axon();
        new_axon.source_id = source.neuron_id;
        new_axon.target_id = target.neuron_id;
        new_axon.weight = random(-params.new_axon_initial_weight, params.new_axon_initial_weight);
        source.neuron_connections.add(new_axon);
        target.static_connections_count++;
    }
    void add_new_connection_from_middle_neuron_to_middle_neuron_or_output_neuron() {
        if (worker_neurons.size() == 0) return;
        
        Neuron source = get_random_worker_neuron();
        if (source == null) return;
        Neuron target = get_random_worker_neuron_or_output_neuron();
        if (target == null) return;
        if (source.neuron_id == target.neuron_id) return;
        
        form_connection(source, target);
    }    
    void bisect_axon(Axon original_axon) {
        assert(original_axon != null);
        
        Neuron end_neuron = get_middle_or_end_neuron_from_id(original_axon.target_id);
        Neuron middle_neuron = new Neuron(neuron_id_count++);
        
        Axon empty_axon = new Axon();
        empty_axon.source_id = middle_neuron.neuron_id;
        empty_axon.target_id = end_neuron.neuron_id;
        empty_axon.weight = 1;
        
        original_axon.target_id = middle_neuron.neuron_id;
        
        middle_neuron.neuron_connections.add(empty_axon);
        middle_neuron.static_connections_count++;
        
        worker_neurons.put(middle_neuron.neuron_id, middle_neuron);
    }
    void bisect_special_input_connection() {
        int choice = ((int)random(0, special_inputs_count));
        
        Neuron worker = get_random_special_neuron();
        
        if (worker.neuron_connections.size() == 0) return;
        
        Axon thing = get_random_axon_from_neuron(worker);
        assert(thing != null);
        bisect_axon(thing);
    }
    void bisect_any_connection() {
        
        int size = (world_inputs.size()) + (worker_neurons.size()) + (special_inputs_count);
        int random = ((int)random(0, size));
        
        if (random < special_inputs_count) {
            bisect_special_input_connection();
            return;
        }
        random -= special_inputs_count;
        
        if (random < world_inputs.size()) {
            bisect_input_connection();
            return;
        }
        
        random -= world_inputs.size();
        assert (random >= 0);
        
        if (random < worker_neurons.size()) {
            bisect_worker_neuron_connection();
            return;
        }
        assert(false);
    }
    void bisect_input_connection() {
        
        Input source = get_random_world_input();
        if (source.neuron_connections.size() == 0) return;
        
        Axon thing = get_random_axon_from_input(source);
        assert(thing != null);
        
        bisect_axon(thing);
    }
    void bisect_worker_neuron_connection() {
        Neuron source_neuron = get_random_worker_neuron();
        if (source_neuron == null) return;
        if (source_neuron.neuron_connections.size() == 0) return;
        Axon original_axon = get_random_axon_from_neuron(source_neuron);
        assert(original_axon != null);
        
        bisect_axon(original_axon);
    }
    void add_new_connection_from_any_input() {
        int choice_size = world_inputs.size() + special_inputs_count;
        int choice = ((int)random(0, choice_size));
        if (choice < world_inputs.size()) {
            add_new_connection_from_world_input();
        } else {
            add_new_connection_from_special_input();
        }
    }
    void add_new_connection_from_special_input() {
        Neuron source = get_random_special_neuron();        
        Neuron target = get_random_worker_neuron_or_output_neuron();
        assert(target != null);
        form_connection(source, target);
    }
    void add_new_connection_from_world_input() {
        
        assert(world_inputs.size() > 0);
        
        Input selection = get_random_world_input();       
        
        ArrayList<Integer> current_connections = new ArrayList<Integer>();
        for (Axon axon : selection.neuron_connections) {
            current_connections.add(axon.target_id);   
        }
        
        Neuron target = get_random_worker_neuron_or_output_neuron();
        assert(target != null);
        if (current_connections.contains(target.neuron_id)) {
            return;
        }
        Axon new_axon = new Axon();
        new_axon.target_id = target.neuron_id;
        new_axon.weight = random(-params.new_axon_initial_weight, params.new_axon_initial_weight);
        target.static_connections_count++;
        
        selection.neuron_connections.add(new_axon);
    }
    void add_new_input() {
        
        ArrayList<WorldConnection> currents = new ArrayList<WorldConnection>();
        
        int left_x = 0, 
            right_x = 0, 
            bot_y = 0, 
            top_y = 0;
        int creature_or_tile = ((int)random(0,2));
        int new_channel = ((int)random(0,3));
        
        for (Input input : world_inputs) {
            if (input.creature_or_tile != creature_or_tile) continue;
            if (input.channel != new_channel) continue;
            
            int channel = input.channel;
            
            WorldConnection current = input.connection;
            assert(!currents.contains(current));
            currents.add(current);
            
            int x = current.x;
            int y = current.y;
            
            if (x < left_x) left_x = x;
            if (x > right_x) right_x = x;
            if (y < bot_y) bot_y = y;
            if (y > top_y) top_y = y;
        }
        
        while (true) {
            int new_x = ((int)(random(left_x-2, right_x+2)));
            int new_y = ((int)(random(bot_y-2, top_y+2)));
            WorldConnection new_connection = new WorldConnection(new_x, new_y);
            if (!currents.contains(new_connection)) {                
                Input new_input = new Input();                
                new_input.connection = new_connection;
                new_input.channel = new_channel;
                new_input.creature_or_tile = creature_or_tile;
                world_inputs.add(new_input);
                return;
            }
        }
    }
    float evaluate_position(Input input) {
        WorldConnection connection = input.connection;
        Tile current = creature.tile;
        int current_index = current.worldIndex;
        
        int current_x = current_index - (current_index / Settings.NUM_TILES);
        int current_y = (current_index / Settings.NUM_TILES);
        
        int target_x = current_x + connection.x;
        int target_y = current_y + connection.y;
        
        if ( (target_x < 0) || (target_x > Settings.NUM_TILES-1) ) {
            return -1.0f;
        }
        if ( (target_y < 0) || (target_y > Settings.NUM_TILES-1) ) {
            return -1.0f;   
        }
        
        int target_index = (target_x) + (target_y * Settings.NUM_TILES);
        //return random(-1f,1f);
        float result = -1;
        if (input.creature_or_tile == 0) {
            result = creature.species.world
                    .tiles.get(target_index).get_tile_evaluation_by_channel(input.channel);
        } else {
            result = creature.species.world
                    .tiles.get(target_index).get_tile_evaluation_by_channel_of_creature(input.channel);
        }
        return result;
    }  
    void process() {
        
         assert(creature != null);
         assert(random_neuron != null);
         assert(constant_neuron != null);
         
         assert(life_neuron != null);
         assert(timer_1_neuron != null);
         assert(timer_2_neuron != null);
         
         assert(age_neuron != null);
         assert(reproductive_neuron != null);
         
         assert(memory_1 != null);
         assert(memory_1.input_neuron != null);
         assert(memory_1.output_neuron != null);
         
         assert(memory_2 != null);
         assert(memory_2.input_neuron != null);
         assert(memory_2.output_neuron != null);
         
         assert(output_neurons.size() == 8);
         assert(process_results.size() == 8);
         
         for (Map.Entry me : worker_neurons.entrySet()) {
             Neuron target = ((Neuron)me.getValue());
             target.dynamic_connections_count = 0;
             target.current_data = 0;
         }
         memory_1.input_neuron.current_data = memory_1.output_neuron.current_data;
         memory_2.input_neuron.current_data = memory_2.output_neuron.current_data;
         for (Map.Entry me : output_neurons.entrySet()) {
             Neuron target = ((Neuron)me.getValue());
             target.dynamic_connections_count = 0;
             target.current_data = 0;
         }
         
         for (Input input : world_inputs) {
             float evaluation = evaluate_position(input);
             evaluation *= params.brain_input_multiplier;
             send_input(input, evaluation);
         }         
         
         random_neuron.current_data = random(-1f,1f);
         axon_iteration(random_neuron.neuron_connections, random_neuron.current_data * params.brain_input_multiplier);
         
         constant_neuron.current_data = 1;
         axon_iteration(constant_neuron.neuron_connections, constant_neuron.current_data * params.brain_input_multiplier);
         
         life_neuron.current_data = (creature.life / Settings.CREATURE_MAX_FOOD);
         axon_iteration(life_neuron.neuron_connections, life_neuron.current_data * params.brain_input_multiplier);
         
         if (timer_1_direction) {
             timer_1_neuron.current_data += (1f / (Settings.CREATURE_STARVATION_TIMER / 3));
             if (timer_1_neuron.current_data > 1f) {
                 timer_1_direction = false;   
             }
         } else {
             timer_1_neuron.current_data -= (1f / (Settings.CREATURE_STARVATION_TIMER / 3));
             if (timer_1_neuron.current_data < 0) {
                 timer_1_direction = true;
             }
         }
         if (timer_1_neuron.current_data < -1) {
             timer_1_neuron.current_data = -1;
             timer_1_direction = true;
         } else if (timer_1_neuron.current_data > 2) {
             timer_1_neuron.current_data = 2;
             timer_1_direction = false;
         }
         axon_iteration(timer_1_neuron.neuron_connections, timer_1_neuron.current_data * params.brain_input_multiplier);
         
         if (timer_2_direction) {
             timer_2_neuron.current_data += (1f / (Settings.CREATURE_STARVATION_TIMER / 2));
             if (timer_2_neuron.current_data > 1f) {
                 timer_2_direction = false;   
             }
         } else {
             timer_2_neuron.current_data -= (1f / (Settings.CREATURE_STARVATION_TIMER / 2));
             if (timer_2_neuron.current_data < 0) {
                 timer_2_direction = true;
             }
         }
         if (timer_2_neuron.current_data < -1) {
             timer_2_neuron.current_data = -1;
             timer_2_direction = true;
         } else if (timer_2_neuron.current_data > 2) {
             timer_2_neuron.current_data = 2;
             timer_2_direction = false;
         }
         axon_iteration(timer_2_neuron.neuron_connections, timer_2_neuron.current_data * params.brain_input_multiplier);
         
         age_neuron.current_data = ((float)this.creature.age) 
                                 / ((float)Settings.CREATURE_DEATH_AGE);
         reproductive_neuron.current_data = ((float)this.creature.reproductive_count) 
                                          / ((float)Settings.CREATURE_REPRODUCTIVE_LIMIT);
         axon_iteration(age_neuron.neuron_connections, age_neuron.current_data * params.brain_input_multiplier);
         axon_iteration(reproductive_neuron.neuron_connections, reproductive_neuron.current_data * params.brain_input_multiplier);
         
         axon_iteration(memory_1.input_neuron.neuron_connections, memory_1.input_neuron.current_data * params.brain_input_multiplier);
         axon_iteration(memory_2.input_neuron.neuron_connections, memory_2.input_neuron.current_data * params.brain_input_multiplier);
         
         for (Map.Entry me : output_neurons.entrySet()) {
             
             Neuron target = ((Neuron)me.getValue());
             float resulting_data = target.current_data;
             resulting_data = negsig(resulting_data);
             
             int result_index = target.neuron_id;
             assert(result_index >= 0 && result_index < process_results.size());
             process_results.set(result_index, resulting_data);    // TODO : Clamp current_data?
         }
    }
    boolean push_data_to_internal(Neuron neuron, float data) { //<>//
        // Pushes a value to the neuron. If this 'fills' the neuron, return true
        neuron.current_data += data;
        neuron.dynamic_connections_count++;
        int difference = neuron.static_connections_count - neuron.dynamic_connections_count;
        assert(difference >= 0);    // Either static_connections is wrong, or we are pushing to a neuron that has already fired.
        return (difference == 0);
    }
    void send_input(Input source, float data) {
        axon_iteration(source.neuron_connections, data);
    }
    void axon_iteration(ArrayList<Axon> axons, float current_data) {
        for (Axon axon : axons) {
            float data = current_data;    // TODO : should we clamp this data with sig function?
            data *= axon.weight;
            
            data = negsig(data);
            
            Neuron target = worker_neurons.get(axon.target_id);
            if (target != null) {
                
                assert(target.neuron_id == axon.target_id);
                if (push_data_to_internal(target, data)) {
                    propagate(target.neuron_id);   
                }
            } else {
                target = output_neurons.get(axon.target_id);
                
                assert(target != null);    // If not a worker neuron, the neuron HAS to be an output neuron
                assert(target.neuron_id == axon.target_id);
                
                send_to_output(target.neuron_id, data);
            }
        }
    }
    void send_to_output(int neuron_id, float data) {
        
       Neuron target = output_neurons.get(neuron_id);
       assert(target != null);
       
       target.current_data += data;
    }
    void propagate(int neuron_id) {
        
        Neuron source = worker_neurons.get(neuron_id);
        assert(source != null);
        axon_iteration(source.neuron_connections, source.current_data);        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    Neuron get_random_special_neuron() {
        Neuron source = null;
        
        int choice = ((int)random(0, special_inputs_count));
        if (choice == 0) {
            source = random_neuron;
        } else if (choice == 1) {
            source = constant_neuron;
        } else if (choice == 2) {
            source = memory_1.input_neuron;
        } else if (choice == 3) {
            source = memory_2.input_neuron;
        } else if (choice == 4) {
            source = life_neuron;   
        } else if (choice == 5) {
            source = timer_1_neuron;
        } else if (choice == 6) {
            source = timer_2_neuron;
        } else if (choice == 7) {
            source = age_neuron;
        } else if (choice == 8) {
            source = reproductive_neuron;
        }
        assert(source != null);
        
        return source;
    }
    Input get_random_world_input() {
        int iteration = ((int)random(0, world_inputs.size()));
        Input selection = null;
        for (Input input : world_inputs) {
            if (iteration == 0) {
                selection = input;
                break;
            }
            iteration--;
        }
        assert(selection != null);
        return selection;
    }
    Axon get_random_axon_from_axons(ArrayList<Axon> axons) {
        if (axons.size() == 0) return null;
        int choice = ((int)random(0, axons.size()));
        for (Axon axon : axons) {
            if (choice == 0) return axon;
            choice--;
        }
        assert(false);
        return null;
    }
    Axon get_random_axon_from_input(Input source) {
        return get_random_axon_from_axons(source.neuron_connections);
    }
    Neuron get_random_worker_neuron_or_output_neuron() {
        int index = (worker_neurons.size()) + (output_neurons.size());
        int choice = ((int)random(0, index));
        
        if (choice < worker_neurons.size()) {
            return get_random_worker_neuron();
        } else {
            return get_random_output_neuron();
        }
    }
    Neuron get_random_output_neuron() {
        assert(output_neurons.size() == 8);
        Neuron selection = null;
        int _index = ((int)random(0, output_neurons.size()));
        for (Map.Entry me : output_neurons.entrySet()) {
            if (_index == 0) {
                selection = ((Neuron)me.getValue());
                break;
            }
            _index--;
        }
        assert(selection != null);
        return selection;
    }
    Neuron get_random_worker_neuron() {
        if (worker_neurons.size() == 0) return null;
        //assert(worker_neurons.size() > 0);
        Neuron selection = null;
        int _index = ((int)random(0, worker_neurons.size()));
        for (Map.Entry me : worker_neurons.entrySet()) {
            if (_index == 0) {
                selection = ((Neuron)me.getValue());
                break;
            }
            _index--;
        }
        assert(selection != null);
        return selection;
    }
    Axon get_random_axon_from_neuron(Neuron worker) {
        return get_random_axon_from_axons(worker.neuron_connections);
    }
    Neuron get_middle_or_end_neuron_from_id(int neuron_id) {
        Neuron result = worker_neurons.get(neuron_id);
        if (result != null) return result;
        result = output_neurons.get(neuron_id);
        assert(result != null);
        return result;
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
}
class Parameters {
    // --
    float ichance_mutate_parameters            = 1f;
    // --
    int brain_size_multiplier_divider          = 2000;
    // --
    float brain_input_multiplier               = 1.0f;
    // --
    float chance_bisect_any_connection         = 0.10000f;    // adds 1 neuron, 1 connection
    float chance_add_new_input                 = 0.20000f;    // adds 1 neuron
    float chance_remove_world_input            = 0.07000f;    // remove 1 neuron, and 'x' connections
    float chance_remove_random_middle_neuron   = 0.03000f;    // remove 1 neuron, and 'x' + 'y' connections
    float chance_remove_random_axon            = 0.01000f;    // remove 1 connection
    float chance_add_any_new_connection        = 0.30000f;    // add 1 connection
    float chance_mutate_any_axon               = 0.20000f;    // mutate connection
    // --
    float new_axon_initial_weight              = 1f;
    // --
    float axon_weight_mutation_range           = 0.1f;
    // --
    float creature_color_mutation_range        = 0.10f;
    
    Parameters(){}
    Parameters deep_copy() {
        Parameters newp = new Parameters();
            newp.ichance_mutate_parameters = ichance_mutate_parameters;
            newp.brain_size_multiplier_divider = brain_size_multiplier_divider;
            newp.brain_input_multiplier = brain_input_multiplier;
            newp.chance_bisect_any_connection = chance_bisect_any_connection;
            newp.chance_add_new_input = chance_add_new_input;
            newp.chance_remove_world_input = chance_remove_world_input;
            newp.chance_remove_random_middle_neuron = chance_remove_random_middle_neuron;
            newp.chance_remove_random_axon = chance_remove_random_axon;
            newp.chance_add_any_new_connection = chance_add_any_new_connection;
            newp.chance_mutate_any_axon = chance_mutate_any_axon;
            newp.new_axon_initial_weight = new_axon_initial_weight;
            newp.axon_weight_mutation_range = axon_weight_mutation_range;
            newp.creature_color_mutation_range = creature_color_mutation_range;
        return newp;
    }
    int mut(int current, int lower_limit, int delta) {
        current += ((int)random(-delta-1, +delta+1));
        if (current > lower_limit) return current;
        return lower_limit;
    }
    float mut(float current, float lower_limit, float delta) {
        current += random(-delta, +delta);
        if (current > lower_limit) return current;
        return lower_limit;
    }
    void mutate() {
        // --
        ichance_mutate_parameters = mut(ichance_mutate_parameters,                           0.01f, 0.00001f);
        // --
        brain_size_multiplier_divider      = mut(brain_size_multiplier_divider,              1, 10);
        // --
        brain_input_multiplier             = mut(brain_input_multiplier,                     0.00001f, 0.0001f);
        chance_bisect_any_connection       = mut(chance_bisect_any_connection,               0.00001f, 0.0001f);
        chance_add_new_input               = mut(chance_add_new_input,                       0.00001f, 0.0001f);
        chance_remove_world_input          = mut(chance_remove_world_input,                  0.00001f, 0.0001f);
        chance_remove_random_middle_neuron = mut(chance_remove_random_middle_neuron,         0.00001f, 0.0001f);
        chance_remove_random_axon          = mut(chance_remove_random_axon,                  0.00001f, 0.0001f);
        chance_add_any_new_connection      = mut(chance_add_any_new_connection,              0.00001f, 0.0001f);
        chance_mutate_any_axon             = mut(chance_mutate_any_axon,                     0.00001f, 0.0001f);
        // --
        new_axon_initial_weight = mut(new_axon_initial_weight,                               0.00001f, 0.0001f);
        axon_weight_mutation_range = mut(axon_weight_mutation_range,                         0.00001f, 0.0001f);
        creature_color_mutation_range = mut(creature_color_mutation_range,                   0.00001f, 0.0001f);
        // --
    }
    String get_printout() {
        String result = "Brain Mutation Parameters:";
        
        // --
        result += "\n    ichance_mutate_parameters:                              " + ichance_mutate_parameters;
        // --
        result += "\n    brain_size_multiplier_divider:                              " + brain_size_multiplier_divider;
        // --
        result += "\n    chance_bisect_any_connection:                         " + chance_bisect_any_connection;
        result += "\n    chance_add_new_input:                                     " + chance_add_new_input;
        result += "\n    chance_remove_world_input:                             " + chance_remove_world_input;
        result += "\n    chance_remove_random_middle_neuron:         " + chance_remove_random_middle_neuron;
        result += "\n    chance_remove_random_axon:                         " + chance_remove_random_axon;
        result += "\n    chance_add_any_new_connection:                   " + chance_add_any_new_connection;
        result += "\n    chance_mutate_any_axon:                                " + chance_mutate_any_axon;
        // --
        result += "\n    new_axon_initial_weight:                                    " + new_axon_initial_weight;
        // --
        result += "\n    axon_weight_mutation_range:                            " + axon_weight_mutation_range;
        // --
        result += "\n    creature_color_mutation_range:                         " + creature_color_mutation_range;
        
        return result;
    }
}
class Neuron {
    int neuron_id;
    float current_data;
    int static_connections_count;            // The total number of connections into a neuron
    int dynamic_connections_count;           // The frame-number of connections into a neuron
    ArrayList<Axon> neuron_connections;
    
    Neuron(int neuron_id) {
        this.neuron_id = neuron_id;
        current_data = 0;
        static_connections_count = 0;
        dynamic_connections_count = 0;
        neuron_connections = new ArrayList<Axon>();
    }
    Neuron deep_copy() {
        Neuron new_neuron = new Neuron(neuron_id);
        
        new_neuron.neuron_id = neuron_id;
        new_neuron.current_data = current_data;
        new_neuron.static_connections_count = static_connections_count;
        assert(new_neuron.static_connections_count >= 0);
        new_neuron.dynamic_connections_count = 0;
        for (Axon axon : neuron_connections) {
            new_neuron.neuron_connections.add(axon.deep_copy());
        }
        return new_neuron;
    }
}
class Memory {
    Neuron input_neuron;
    Neuron output_neuron;
    
    Memory(Neuron input_neuron, Neuron output_neuron) {
        this.input_neuron = input_neuron;
        this.output_neuron = output_neuron;
    }
    Memory deep_copy() {
        Memory new_memory = new Memory(
                                  input_neuron.deep_copy(), 
                                  output_neuron.deep_copy());
        return new_memory;
    }
}
class Axon {
    int source_id = -1;
    int target_id = -1;
    float weight = 0;    
    Axon deep_copy() {
        
        Axon new_axon = new Axon();
        
        new_axon.source_id = source_id;
        new_axon.target_id = target_id;
        new_axon.weight = weight;
        
        return new_axon;
    }
}
class Input {
    int creature_or_tile = -1;
    int channel = -1;
    ArrayList<Axon> neuron_connections = new ArrayList<Axon>();
	WorldConnection connection = null;

    Input deep_copy() {
        Input new_input = new Input();
        for (Axon axon : neuron_connections) {
            new_input.neuron_connections.add(axon.deep_copy());
        }
        new_input.connection = connection.deep_copy();
        new_input.channel = channel;
        new_input.creature_or_tile = creature_or_tile;
        return new_input;
    }
}
class WorldConnection {
    int x,y; 
    WorldConnection(int x, int y) {
        this.x = x;
        this.y = y;
    }
    @Override
    public boolean equals(Object other) {
        if (other == this) return true;
        
        if (!(other instanceof WorldConnection)) return false;
        
        WorldConnection casted = (WorldConnection) other;
        return (this.x == casted.x && this.y == casted.y);
    }
    WorldConnection deep_copy() {
        return new WorldConnection(x,y);
    }
}
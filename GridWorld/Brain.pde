import java.util.Map;

class Brain {
  
    Creature creature;
    ArrayList<Float> process_results = new ArrayList<Float>();
    ArrayList<Input> world_inputs = new ArrayList<Input>();
    HashMap<Integer, Neuron> worker_neurons = new HashMap<Integer, Neuron>();
    HashMap<Integer, Neuron> output_neurons = new HashMap<Integer, Neuron>();
    int neuron_id_count = 0;
    Neuron constant_neuron;
    Neuron random_neuron;
    
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
        }
        
        worker_neurons.put(neuron_id_count, new Neuron(neuron_id_count));
        neuron_id_count++;
        
        worker_neurons.put(neuron_id_count, new Neuron(neuron_id_count));
        neuron_id_count++;
        
        worker_neurons.put(neuron_id_count, new Neuron(neuron_id_count));
        neuron_id_count++;
        
        constant_neuron = new Neuron(-2);
        random_neuron = new Neuron(-2);
        
        neuron_id_count = 6;
        for (int i = 0; i < 15; i++) {
            add_new_input();   
        }
        for (int i = 0; i < 100; i++) {
            add_new_connection_from_any_input();
        }
        for (int i = 0; i < 100; i++) {
            bisect_connection();   
        }
        for (int i = 0; i < 20; i++) {
            add_new_connection_from_middle_neuron_to_middle_neuron_or_output_neuron();
        }
        for (int i = 0; i < 50; i++) {
            mutate_any_axon();
        }
    }
    void mutate_any_axon() {
        // Axons aren't weighted evenly
        int index = (world_inputs.size()) + (worker_neurons.size());
        int choice = ((int)random(0, index));
        if (choice < world_inputs.size()) {
            mutate_input_axon();
        } else {
            mutate_worker_neuron_axon();
        }
    }
    void mutate_input_axon() {
        
        assert(world_inputs.size() > 0);
        Input source = get_random_world_input();
        assert(source != null);
        if (source.neuron_connections.size() == 0) return;
        
        Axon worker = get_random_axon_from_input(source);
        assert(worker != null);
        
        worker.weight += random(-0.1f, 0.1f);
    }
    void mutate_worker_neuron_axon() {
        assert(worker_neurons.size() > 0);
        Neuron source = get_random_worker_neuron();
        assert(source != null);
        
        if (source.neuron_connections.size() == 0) return;
        
        Axon worker = get_random_axon_from_neuron(source);
        assert(worker != null);
        
        worker.weight += random(-0.1f, 0.1f);
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
        // Assumes there is no connection already
        Axon new_axon = new Axon();
        new_axon.source_id = source.neuron_id;
        new_axon.target_id = target.neuron_id;
        new_axon.weight = random(-1f,1f);
        source.neuron_connections.add(new_axon);
        target.static_connections_count++;
    }
    void add_new_connection_from_middle_neuron_to_middle_neuron_or_output_neuron() {
        assert(worker_neurons.size() > 1);
        
        Neuron source = get_random_worker_neuron();
        assert(source != null);
        
        Neuron target = null;        
        while (target == null) {
            target = get_random_worker_neuron_or_output_neuron();    // TODO : get random worker OR output neuron
            assert(target != null);
            if (source.neuron_id == target.neuron_id) target = null;
        }
        if (has_connection(source.neuron_id, target.neuron_id)) return;
        // No recursive connection between source and target
        
        form_connection(source, target);
    }    
    void bisect_connection() {
        Neuron source_neuron = get_random_worker_neuron();
        if (source_neuron.neuron_connections.size() == 0) return;
        Axon original_axon = get_random_axon_from_neuron(source_neuron);
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
    void add_new_connection_from_any_input() {
        int choice_size = world_inputs.size() + 2;
        int choice = ((int)random(0, choice_size));
        if (choice < world_inputs.size()) {
            add_new_connection_from_world_input();
        } else {
            add_new_connection_from_special_input();
        }
    }
    void add_new_connection_from_special_input() {
        Neuron source = null;
        int _choice = ((int)random(0,2));
        if (_choice == 0) {
            source = constant_neuron;   
        } else {
            source = random_neuron;
        }
        assert(source != null);
        
        Neuron target = get_random_worker_neuron_or_output_neuron();
        assert(target != null);
        try_to_form_connection(source, target);
        /*
        ArrayList<Integer> current_connections = new ArrayList<Integer>();
        for (Axon axon : current.neuron_connections) {
            current_connections.add(axon.target_id);   
        }
        assert(current_connections.size() > 0);
        
        if (current_connections.size() == worker_neurons.size()) {
            return;
        }
        ArrayList<Integer> possible_connections = new ArrayList<Integer>();
        for (Map.Entry me : worker_neurons.entrySet()) {
            int possible_neuron_id = ((Neuron)me.getValue()).neuron_id;
            if (current_connections.contains(possible_neuron_id)) {
                continue;
            } else {
                possible_connections.add(possible_neuron_id);
            }   
        }
        if (possible_connections.size() == 0) return;
        
        int choice_index = ((int)random(0, possible_connections.size()));
        int choice = possible_connections.get(choice_index);    // choice == neuron_id
        
        Axon new_axon = new Axon();
        new_axon.target_id = choice;
        new_axon.weight = random(-1f, 1f);
        
        Neuron target = worker_neurons.get(choice);
        assert( target != null );
        target.static_connections_count++;
        */
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
        new_axon.weight = random(-1f,1f);
        target.static_connections_count++;
        
        selection.neuron_connections.add(new_axon);
    }
    void add_new_input() {
        
        assert(worker_neurons.size() > 0);
        
        ArrayList<WorldConnection> currents = new ArrayList<WorldConnection>();
        int left_x = 0, 
            right_x = 0, 
            bot_y = 0, 
            top_y = 0;
        for (Input input : world_inputs) {
            WorldConnection current = input.connection;
            assert(!(currents.contains(current)));
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
            if (! (currents.contains(new_connection)) ) {
                
                Input new_input = new Input();                
                new_input.connection = new_connection;
                
                Axon new_axon = new Axon();
                new_axon.weight = random(-1f,1f);
                
                int target_neuron_index = ((int)random(0, worker_neurons.size()));
                assert(target_neuron_index < worker_neurons.size());
                for (Map.Entry me : worker_neurons.entrySet()) {
                    if (target_neuron_index == 0) {
                        
                        Neuron target = ((Neuron)me.getValue());
                        
                        new_axon.target_id = target.neuron_id;
                        target.static_connections_count++;
                        
                        break;
                    }
                    target_neuron_index--;
                }
                assert(new_axon.target_id >= 0);
                
                new_input.neuron_connections.add(new_axon);
                world_inputs.add(new_input);
                return;
            }
        }
    }
    float evaluate_position(WorldConnection connection) {
        Tile current = creature.tile;
        int current_index = current.worldIndex;
        
        int current_x = current_index - (current_index / Settings.NUM_TILES);
        int current_y = (current_index / Settings.NUM_TILES);
        
        int target_x = current_x + connection.x;
        int target_y = current_y + connection.y;
        
        //
        // 10 tiles
        // [0-9] is accepted
        /*
            Are these cases handled properly?
                9 > (10-1)    accepts, which is All good
                10 > (10-1)   rejects, which is All good
        */
        if ( (target_x < 0) || (target_x > Settings.NUM_TILES-1) ) {
            return 0;
        }
        if ( (target_y < 0) || (target_y > Settings.NUM_TILES-1) ) {
            return 0;   
        }
        
        int target_index = (target_x) + (target_y * Settings.NUM_TILES);
        //return random(-1f,1f);
        return creature.species.world.tiles.get(target_index).getEvaluation();
    }  
    void process() {
        
         assert(creature != null);
         assert(random_neuron != null);
         assert(constant_neuron != null);
         //assert(random_neuron    .neuron_connections != null && random_neuron    .neuron_connections.size() > 0);
         //assert(constant_neuron  .neuron_connections != null && constant_neuron  .neuron_connections.size() > 0);
         assert(output_neurons.size() == 3);
         assert(process_results.size() == 3);
         
         for (Map.Entry me : worker_neurons.entrySet()) {
             Neuron target = ((Neuron)me.getValue());
             target.dynamic_connections_count = 0;
             target.current_data = 0;
         }
         for (Map.Entry me : output_neurons.entrySet()) {
             Neuron target = ((Neuron)me.getValue());
             target.dynamic_connections_count = 0;
             target.current_data = 0;
         }
         
         for (Input input : world_inputs) {
             float evaluation = evaluate_position(input.connection);
             send_input(input, evaluation);
         }         
         
         random_neuron.current_data = random(-1f,1f);
         axon_iteration(random_neuron.neuron_connections, random_neuron.current_data);
         
         constant_neuron.current_data = 1;
         axon_iteration(constant_neuron.neuron_connections, constant_neuron.current_data);
         
         for (Map.Entry me : output_neurons.entrySet()) {
             Neuron target = ((Neuron)me.getValue());
             int result_index = target.neuron_id;
             assert(result_index >= 0 && result_index < process_results.size());
             process_results.set(result_index, target.current_data);    // TODO : Clamp current_data?
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
        assert(source.neuron_connections.size() > 0);
        axon_iteration(source.neuron_connections, data);
    }
    void axon_iteration(ArrayList<Axon> axons, float current_data) {
        for (Axon axon : axons) {
            float data = current_data;    // TODO : should we clamp this data with sig function?
            data *= axon.weight;
            
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
    void mutate() {
        
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
    Axon get_random_axon_from_input(Input source) {
        int choice = ((int)random(0, source.neuron_connections.size()));
        for (Axon axon : source.neuron_connections) {
            if (choice == 0) {
                return axon;
            }
            choice--;
        }
        return null;
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
        assert(output_neurons.size() == 3);
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
        assert(worker_neurons.size() > 0);
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
        if (worker.neuron_connections.size() == 0) return null;
        int _index = ((int)random(0, worker.neuron_connections.size()));
        Axon result = worker.neuron_connections.get(_index);
        assert(result != null);
        return result;
    }
    Neuron get_middle_or_end_neuron_from_id(int neuron_id) {
        Neuron result = worker_neurons.get(neuron_id);
        if (result != null) return result;
        result = output_neurons.get(neuron_id);
        assert(result != null);
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
}

class Axon {
    int source_id = -1;
    int target_id = -1;
    float weight = 0;
}

class Input {
    ArrayList<Axon> neuron_connections = new ArrayList<Axon>();
	WorldConnection connection = null;
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
}
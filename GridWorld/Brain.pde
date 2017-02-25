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
    Memory memory_1;
    Memory memory_2;
    
    int special_inputs_count = 4;
    
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
        
        int num_initial_workers = 7;
        for (int i = 0; i < num_initial_workers; i++) {
            worker_neurons.put(neuron_id_count, new Neuron(neuron_id_count));
            neuron_id_count++;    
        }
        
        constant_neuron = new Neuron(-2);
        random_neuron = new Neuron(-2);
        
        for (int i = 0; i < 4; i++) {
            add_new_input();   
        }
        for (int i = 0; i < num_initial_workers; i++) {
            add_new_connection_from_any_input();   
        }
        for (int i = 0; i < 10; i++) {    // TODO : How many 'basic' neurons should be added?
            bisect_any_connection();   
        }
        for (int i = 0; i < 10; i++) {
            add_new_connection_from_middle_neuron_to_middle_neuron_or_output_neuron();
        }
    }
    int brain_size() {
        return (world_inputs.size()) + (worker_neurons.size());   
    }
    float brain_size_multiplier() {
        float counter = 0;
        counter += (world_inputs.size());
        counter += (worker_neurons.size());
        
        // 30 neurons is a lot?
        float result = counter / 45.0f;
        if (result < 1.0f) {
            return 1.0f;
        } else {
            return result;
        }
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
        int choice = ((int)random(0,200));
        
        if (choice <= 0) {
            bisect_any_connection();
        } else if (choice <= 1) {
            add_new_input();
        } else if (choice <= 2) {
            remove_world_input();
        } else if (choice <= 25) {
            add_any_new_connection();
        } else if (choice <= 200) {
            mutate_any_axon();
        }        
        creature.mutate_color();
    }
    void __remove_any_connection() {
        
    }
    void __remove_pointless_neurons() {
        /*
        
        */
    }
    void remove_world_input() {
        
        if (world_inputs.size() == 0) return;
        
        int choice = ((int)random(0, world_inputs.size()));
        Input input = world_inputs.get(choice);
        for (Axon axon : input.neuron_connections) {
            Neuron target = get_middle_or_end_neuron_from_id(axon.target_id);
            target.static_connections_count--;
        }
        world_inputs.remove(choice);
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
        memory_1 = source.memory_1.deep_copy();
        memory_2 = source.memory_2.deep_copy();
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
        int choice = ((int)random(0, special_inputs_count));
        ArrayList<Axon> axons = new ArrayList<Axon>();
        assert(choice >= 0 && choice < special_inputs_count);
        if (choice == 0) {
            axons = random_neuron.neuron_connections;
        } else if (choice == 1) {
            axons = constant_neuron.neuron_connections;
        } else if (choice == 2) {
            axons = memory_1.input_neuron.neuron_connections;
        } else if (choice == 3) {
            axons = memory_2.input_neuron.neuron_connections;
        }
        if (axons.size() == 0) return;
        Axon worker = get_random_axon_from_axons(axons);
        assert(worker != null);
        worker.weight += random(-0.1f, 0.1f);
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
        //if (has_connection(source.neuron_id, target.neuron_id)) return;        
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
        
        Neuron worker = null;
        if (choice == 0) {
            worker = random_neuron;
        } else if (choice == 1) {
            worker = constant_neuron;
        } else if (choice == 2) {
            worker = memory_1.input_neuron;
        } else if (choice == 3) {
            worker = memory_2.input_neuron;
        }
        assert(worker != null);
        
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
        Neuron source = null;
        int _choice = ((int)random(0, special_inputs_count));
        if (_choice == 0) {
            source = constant_neuron;   
        } else if (_choice == 1) {
            source = random_neuron;
        } else if (_choice == 2) {
            source = memory_1.input_neuron;
        } else if (_choice == 3) {
            source = memory_2.input_neuron;
        }
        assert(source != null);
        
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
        new_axon.weight = random(-1f,1f);
        target.static_connections_count++;
        
        selection.neuron_connections.add(new_axon);
    }
    void add_new_input() {
        
        assert(worker_neurons.size() > 0);
        
        ArrayList<ArrayList<WorldConnection>> currents = new ArrayList<ArrayList<WorldConnection>>();
        currents.add(new ArrayList<WorldConnection>());
        currents.add(new ArrayList<WorldConnection>());
        currents.add(new ArrayList<WorldConnection>());
        
        int left_x = 0, 
            right_x = 0, 
            bot_y = 0, 
            top_y = 0;
        for (Input input : world_inputs) {
            
            int channel = input.channel;
            
            WorldConnection current = input.connection;
            assert(!currents.get(channel).contains(current));
            currents.get(channel).add(current);
            
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
            int new_channel = ((int)random(0,3));
            WorldConnection new_connection = new WorldConnection(new_x, new_y);
            if (! (currents.get(new_channel).contains(new_connection)) ) {
                
                Input new_input = new Input();                
                new_input.connection = new_connection;
                new_input.channel = new_channel;
                new_input.creature_or_tile = ((int)random(0,2));
                
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
    float evaluate_position(Input input) {
        WorldConnection connection = input.connection;
        Tile current = creature.tile;
        int current_index = current.worldIndex;
        
        int current_x = current_index - (current_index / Settings.NUM_TILES);
        int current_y = (current_index / Settings.NUM_TILES);
        
        int target_x = current_x + connection.x;
        int target_y = current_y + connection.y;
        
        if ( (target_x < 0) || (target_x > Settings.NUM_TILES-1) ) {
            return 0;
        }
        if ( (target_y < 0) || (target_y > Settings.NUM_TILES-1) ) {
            return 0;   
        }
        
        int target_index = (target_x) + (target_y * Settings.NUM_TILES);
        //return random(-1f,1f);
        if (input.creature_or_tile == 0) {
            return creature.species.world
                    .tiles.get(target_index).get_tile_evaluation_by_channel(input.channel);
        } else {
            return creature.species.world
                    .tiles.get(target_index).get_tile_evaluation_by_channel_of_creature(input.channel);
        }        
    }  
    void process() {
        
         assert(creature != null);
         assert(random_neuron != null);
         assert(constant_neuron != null);
         
         assert(memory_1 != null);
         assert(memory_1.input_neuron != null);
         assert(memory_1.output_neuron != null);
         
         assert(memory_2 != null);
         assert(memory_2.input_neuron != null);
         assert(memory_2.output_neuron != null);
         
         assert(output_neurons.size() == 5);
         assert(process_results.size() == 5);
         
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
             send_input(input, evaluation);
         }         
         
         random_neuron.current_data = random(-1f,1f);
         axon_iteration(random_neuron.neuron_connections, random_neuron.current_data);
         
         constant_neuron.current_data = 1;
         axon_iteration(constant_neuron.neuron_connections, constant_neuron.current_data);
         
         axon_iteration(memory_1.input_neuron.neuron_connections, memory_1.input_neuron.current_data);
         axon_iteration(memory_2.input_neuron.neuron_connections, memory_2.input_neuron.current_data);
         
         //println("-----------");
         for (Map.Entry me : output_neurons.entrySet()) {
             
             Neuron target = ((Neuron)me.getValue());
             float resulting_data = target.current_data;
             resulting_data = negsig(resulting_data);
             
             //println("(" + target.current_data + ") ---> (" + resulting_data + ")");
             
             int result_index = target.neuron_id;
             assert(result_index >= 0 && result_index < process_results.size());
             process_results.set(result_index, resulting_data);    // TODO : Clamp current_data?
             
         }
         //println();
         //print(worker_neurons.size() + ",");
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
        assert(output_neurons.size() == 5);
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
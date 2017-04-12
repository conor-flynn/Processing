import java.util.Map;

class Brain {
  
    Creature creature;
    ArrayList<Float> process_results = new ArrayList<Float>();
    
    ArrayList<Input> world_inputs = new ArrayList<Input>();
    
    HashMap<Integer, Neuron> special_neurons = new HashMap<Integer, Neuron>();
    HashMap<Integer, Neuron> worker_neurons = new HashMap<Integer, Neuron>();
    HashMap<Integer, Neuron> output_neurons = new HashMap<Integer, Neuron>();
    
    boolean timer_1_direction = true;
    boolean timer_2_direction = true;
    
    int memory_1_input_index = 3;
    int memory_1_output_index = 4;
    
    int memory_2_input_index = 5;
    int memory_2_output_index = 6;
    
    int general_special_neuron_start_index = 7;
    
    int readable_outputs = 3;
    
    float[] tile_type = new float[2];
    float[] food_type = new float[2];
    float[] inherited_values = new float[4];
    
    int num_axons = 0;
    
    float additional_mutate_rate = 0;
    
    Brain(Creature creature) {
        this.creature = creature;
        
        additional_mutate_rate = Settings.CREATURE_MUTATION_RATE_ADDITIONAL_MUTATION_RATE;
        
        int neuron_id_count = 0;
        
        tile_type = new float[2];
        tile_type[0] = 1;//random(0,1);
        tile_type[1] = 1;//random(0,1);
        food_type = new float[2];
        food_type[0] = 0;//random(0,1);
        food_type[1] = 0;//random(0,1);
        for (int i = 0; i < 4; i++) {
            inherited_values[i] = random(-1,1);
        }                 
        
        // Output setup
        {
            
            output_neurons.put(neuron_id_count, new Neuron(neuron_id_count));
            neuron_id_count++;
            process_results.add(0f);
            
            output_neurons.put(neuron_id_count, new Neuron(neuron_id_count));
            neuron_id_count++;
            process_results.add(0f);
            
            output_neurons.put(neuron_id_count, new Neuron(neuron_id_count));
            neuron_id_count++;
            process_results.add(0f);
            
            //output_neurons.put(neuron_id_count, new Neuron(neuron_id_count));
            //neuron_id_count++;
            //process_results.add(0f);
            
            assert(neuron_id_count == readable_outputs);
            
            assert(neuron_id_count == 3); 
            /*
            int memory_1_input_index = 3;
            int memory_1_output_index = 4;
            */
            special_neurons.put(neuron_id_count, new Neuron(neuron_id_count++));    // input
            output_neurons.put(neuron_id_count, new Neuron(neuron_id_count++));     // output
            
            assert(neuron_id_count == 5);
            /*
            int memory_2_input_index = 5;
            int memory_2_output_index = 6;            
            */
            special_neurons.put(neuron_id_count, new Neuron(neuron_id_count++));    // input
            output_neurons.put(neuron_id_count, new Neuron(neuron_id_count++));     // output
        }
        
        assert(neuron_id_count == (1+1+1 +2 +2));    //4 + 4 = 8
        assert(neuron_id_count == general_special_neuron_start_index);
        //int general_special_neuron_start_index = 8;
        special_neurons.put(neuron_id_count, new Neuron(neuron_id_count++));//1
        special_neurons.put(neuron_id_count, new Neuron(neuron_id_count++));//2
        special_neurons.put(neuron_id_count, new Neuron(neuron_id_count++));//3
        special_neurons.put(neuron_id_count, new Neuron(neuron_id_count++));//4
        special_neurons.put(neuron_id_count, new Neuron(neuron_id_count++));//5
        special_neurons.put(neuron_id_count, new Neuron(neuron_id_count++));//6
        special_neurons.put(neuron_id_count, new Neuron(neuron_id_count++));//7
        special_neurons.put(neuron_id_count, new Neuron(neuron_id_count++));//8
        special_neurons.put(neuron_id_count, new Neuron(neuron_id_count++));//9
        special_neurons.put(neuron_id_count, new Neuron(neuron_id_count++));//10
        special_neurons.put(neuron_id_count, new Neuron(neuron_id_count++));//11
        
        assert(neuron_id_count == (1+1+1  +2+2   +11));
        
        int num_initial_workers = 0;
        for (int i = 0; i < num_initial_workers; i++) {
            int id = getNextNeuronID();
            worker_neurons.put(id, new Neuron(id));
        }
        
        for (int i = 0; i < floor(random(40,60)); i++) {
            Input ii = add_new_input();
            assert(ii != null);
            add_new_connection_from_world_input(ii);
            add_new_connection_from_world_input(ii);
        }
        for (int i = 0; i < floor(random(0,20)); i++) {
            add_new_connection_from_special_input();
            //add_new_connection_from_middle_neuron_to_middle_neuron_or_output_neuron();
        }
        //add_new_connection_from_special_input(special_neurons.get(general_special_neuron_start_index+4));
        //add_new_connection_from_special_input(special_neurons.get(general_special_neuron_start_index+4));
        
        for (int i = 0; i < 0; i++) {
            
            bisect_any_connection();
            add_new_input();
            add_new_input();
            add_new_input();
            add_new_connection_from_world_input();
            add_new_connection_from_world_input();
            add_any_new_connection();
            add_any_new_connection();
            add_any_new_connection();
            add_any_new_connection();
            add_any_new_connection();
        }
    }
    void deeboog() {
        println("=============================================");
        println("World inputs:");
        for (Input input : world_inputs) {
            println(input.neuron_id);   
        }
        println("Special neurons:");
        for (Map.Entry me : special_neurons.entrySet()) {
            println(((Neuron)me.getValue()).neuron_id);
        }
        println("Worker neurons:");
        for (Map.Entry me : worker_neurons.entrySet()) {
            println(((Neuron)me.getValue()).neuron_id);
        }
        println("Output neurons:");
        for (Map.Entry me : output_neurons.entrySet()) {
            println(((Neuron)me.getValue()).neuron_id);
        }
    }
    void add_any_new_connection() {
        
        int choice =  (world_inputs.size()) 
                    + (special_neurons.size()) 
                    + (worker_neurons.size()) 
                    + (output_neurons.size());
                    
        int index = ((int)random(0, choice));
        if (choice < (world_inputs.size() + special_neurons.size())) {
            add_new_connection_from_any_input();
        } else {
            add_new_connection_from_middle_neuron_to_middle_neuron_or_output_neuron();
        }
    }
    int brain_size() {
        assert(num_axons >= 0);
        return (world_inputs.size() + worker_neurons.size()) + num_axons;
    }
    int adjusted_brain_size() {
        int v = brain_size();
        if (v < Settings.CREATURE_BRAIN_SIZE_IGNORE) {
            return 0;
        } else {
            return (v - Settings.CREATURE_BRAIN_SIZE_IGNORE);
        }
    }
    void mutate_count(int x) {
        while (x > 0) {
            mutate();
            x--;
        }
    }
    void mutate() {
        
        creature.mutate_color(Settings.CREATURE_COLOR_MUTATION_AMOUNT);
        
        //additional_mutate_rate += random(-0.01, +0.01);
        if (fifty()) {
            additional_mutate_rate *= 1.05;
        } else {
            additional_mutate_rate *= 0.95;
        }
        if (additional_mutate_rate < 0) additional_mutate_rate = 0;
        
        if (random(1) > (additional_mutate_rate + Settings.CREATURE_MUTATION_RATE_BASE)) return;
        
        int x = floor(random(0, 36));
        if (x < 1) {
            bisect_any_connection();
            //if (random(1) < 0.1) remove_random_middle_neuron();
            return;
        }
        if (x < 2) {
            add_new_connection_from_world_input(add_new_input());
            //if (random(1) < 0.01) remove_world_input();
            return;
        }
        if ( x < 8 ) {
            add_any_new_connection();
            //if (random(1) < 0.01) remove_random_axon();
            return;
        }
        if ( x < 35 ) {
            mutate_any_axon();
            return;
        }
        if (x < 36) {
            for (int i = 0; i < 2; i++) {
                
                tile_type[i] += random(-0.05, +0.05);
                if (tile_type[i] < 0) tile_type[i] = 0;
                if (tile_type[i] > 1) tile_type[i] = 1;
                
                food_type[i] += random(-0.05, +0.05);
                if (food_type[i] < 0) food_type[i] = 0;
                if (food_type[i] > 1) food_type[i] = 1;
            }
            return;
        }
        return;
           /*     
        if ( x < 80) {
            
        }
        */
    }
    void remove_random_axon_from_special_inputs() {
        Neuron source = get_random_special_neuron();
        if (source.neuron_connections.size() == 0) return;
        
        int index = ((int)random(0, source.neuron_connections.size()));
        Axon axon = source.neuron_connections.get(index);
        
        Neuron target = get_middle_or_end_neuron_from_id(axon.target_id);
        if (axon.enabled)
            assert(--target.static_connections_count >= 0);
        source.neuron_connections.remove(index);
        num_axons--;
    }
    void remove_random_axon_from_world_inputs() {
        Input source = get_random_world_input();
        if (source == null) return;
        if (source.neuron_connections.size() == 0) return;
        int index = ((int)random(0, source.neuron_connections.size()));
        Axon axon = source.neuron_connections.get(index);
        
        Neuron target = get_middle_or_end_neuron_from_id(axon.target_id);
        if (axon.enabled)
            assert(--target.static_connections_count >= 0);
        source.neuron_connections.remove(index);
        num_axons--;
    }
    void remove_random_axon_from_random_middle_neuron() {
        Neuron source = get_random_worker_neuron();
        if (source == null) return;
        if (source.neuron_connections.size() == 0) return;
        
        int index = ((int)random(0, source.neuron_connections.size()));
        Axon axon = source.neuron_connections.get(index);
        
        Neuron target = get_middle_or_end_neuron_from_id(axon.target_id);
        if (axon.enabled)
            assert(--target.static_connections_count >= 0);
        source.neuron_connections.remove(index);
        num_axons--;
    }
    void remove_random_axon() {
        int choice = (special_neurons.size()) + (world_inputs.size()) + (worker_neurons.size());
        
        if (choice < special_neurons.size()) {
            remove_random_axon_from_special_inputs();  
            return;
        }
        choice -= special_neurons.size();
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
        
        for (Map.Entry me : special_neurons.entrySet()) {
            Neuron source = (Neuron)me.getValue();
            remove_connections_from_special_input_to_neuron(source, target);
        }  
    }
    void remove_connections_from_special_input_to_neuron(Neuron source, Neuron target) {
        for (int i = 0; i < source.neuron_connections.size(); i++) {
            if (source.neuron_connections.get(i).target_id == target.neuron_id) {
                if (source.neuron_connections.get(i).enabled)
                    assert(--target.static_connections_count >= 0);
                source.neuron_connections.remove(i);
                i--;
                num_axons--;
            }
        }
    }
    void remove_connections_from_world_inputs_to_neuron(Neuron target) {
        for (Input input : world_inputs) {
            for (int i = 0; i < input.neuron_connections.size(); i++) {
                if (input.neuron_connections.get(i).target_id == target.neuron_id) {
                    if (input.neuron_connections.get(i).enabled)
                        assert(--target.static_connections_count >= 0);
                    input.neuron_connections.remove(i);
                    i--;
                    num_axons--;
                }
            }
        }
    }
    void remove_connections_from_middle_neurons_to_middle_neuron(Neuron target) {
        for (Map.Entry me : worker_neurons.entrySet()) {
            Neuron source = ((Neuron)me.getValue());
            if (source.neuron_id == target.neuron_id) continue;
            for (int i = 0; i < source.neuron_connections.size(); i++) {
                if (source.neuron_connections.get(i).target_id == target.neuron_id) {
                    if (source.neuron_connections.get(i).enabled)
                        assert(--target.static_connections_count >= 0);
                    source.neuron_connections.remove(i);
                    i--;
                    num_axons--;
                }
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
            if (axon.enabled)
                assert(--target.static_connections_count >= 0);
            num_axons--;
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
            if (axon.enabled)
                assert(--target.static_connections_count >= 0);
            num_axons--;
        }
        world_inputs.remove(choice);
    }
    boolean fifty() {
        int ran = floor(random(0,2));
        return (ran == 0);
    }
    void add_world_input(Input a) {
        Input new_input = new Input(a.neuron_id);
        new_input.channel = a.channel;
        new_input.connection = a.connection.deep_copy();
        
        for (Axon axon : a.neuron_connections) {
            
            int ss = axon.source_id;    // input
            int tt = axon.target_id;    // worker, output
            new_input.neuron_connections.add(axon.deep_copy());
            num_axons++;
            Neuron worker = try_get_middle_or_end_neuron_from_id(tt);
            if (worker == null) {
                // It's a worker neuron
                worker = new Neuron(tt);
                if (axon.enabled) worker.static_connections_count++;
                worker_neurons.put(worker.neuron_id, worker);
            } else {
                if (axon.enabled) worker.static_connections_count++;
            }
        }
        world_inputs.add(new_input);
        //available_connections.get(new_input.channel).remove(new_input.connection);
    }
    void add_matched_input_neurons(Input a, Input b) {
        assert(a.neuron_id == b.neuron_id);
        
        Input new_input = new Input(a.neuron_id);
        new_input.channel = a.channel;
        new_input.connection = a.connection.deep_copy();
        
        ArrayList<Axon> only_b_axons = new ArrayList<Axon>();
        for (Axon axon : b.neuron_connections) only_b_axons.add(axon);
        
        for (Axon axon : a.neuron_connections) {
            Axon other = get_equivalent_axon(only_b_axons, axon);
            if (other != null) {
                if (fifty()) add_axon_and_dependents(new_input, axon);
                else         add_axon_and_dependents(new_input, other);
                only_b_axons.remove(other);
            } else {
                if (fifty()) add_axon_and_dependents(new_input, axon);
            }
        }
        for (Axon other : only_b_axons) {
            if (fifty()) add_axon_and_dependents(new_input, other);
        }
        world_inputs.add(new_input);
        //available_connections.get(new_input.channel).remove(new_input.connection);
    }
    void add_axon_and_dependents(Input source, Axon guy) {
        assert(guy != null);
        source.neuron_connections.add(guy.deep_copy());
        num_axons++;
        Neuron target = try_get_middle_or_end_neuron_from_id(guy.target_id);
        if (target == null) {
            Neuron worker = new Neuron(guy.target_id);
            if (guy.enabled) worker.static_connections_count++;
            worker_neurons.put(worker.neuron_id, worker);
        } else {
            if (guy.enabled) target.static_connections_count++;
        }
    }
    void add_axon_and_dependents(Neuron source, Axon guy) {
        assert(guy != null);
        source.neuron_connections.add(guy.deep_copy());
        num_axons++;
        Neuron target = try_get_middle_or_end_neuron_from_id(guy.target_id);
        if (target == null) {
            Neuron worker = new Neuron(guy.target_id);
            if (guy.enabled) worker.static_connections_count++;
            worker_neurons.put(worker.neuron_id, worker);
        } else {
            if (guy.enabled) target.static_connections_count++;
        }
    }
    Axon get_equivalent_axon(ArrayList<Axon> axons, Axon guy) {
        for (Axon axon : axons) {
            if (axon.equals(guy)) return axon;
        }
        return null;
    }
    Input get_equivalent_input(ArrayList<Input> inputs, Input guy) {
        for (Input i : inputs) {
            if (i.equals(guy)) return i;
        }
        return null;
    }
    void add_matched_worker_neurons(Neuron a, Neuron b) {
        // the neuron_id's match and are from both parents.
        assert(a.neuron_id == b.neuron_id);
        Neuron worker = worker_neurons.get(a.neuron_id);
        boolean add_it = false;
        if (worker == null) {
            worker = new Neuron(a.neuron_id);
            add_it = true;
        }
        ArrayList<Axon> only_b_axons = new ArrayList<Axon>();
        for (Axon axon : b.neuron_connections) only_b_axons.add(axon);
        
        for (Axon axon : a.neuron_connections) {
            Axon other = get_equivalent_axon(only_b_axons, axon);
            if (other != null) {
                if (fifty()) add_axon_and_dependents(worker, axon);
                else         add_axon_and_dependents(worker, other);
                only_b_axons.remove(axon);
            }
            if (fifty()) add_axon_and_dependents(worker, axon);
        }
        for (Axon axon : only_b_axons) {
            if (fifty()) add_axon_and_dependents(worker, axon);
        }
        if (add_it) {
            worker_neurons.put(worker.neuron_id, worker);
        }
    }
    void maybe_add_mismatched_worker_neuron(Neuron a) {
        // this neuron is only from one parent
        if (fifty()) {
            Neuron worker = worker_neurons.get(a.neuron_id);
            boolean add_it = false;
            if (worker == null) {
                worker = new Neuron(a.neuron_id);
                add_it = true;
            }
            for (Axon axon : a.neuron_connections) {
                add_axon_and_dependents(worker, axon);
            }
            if (add_it) worker_neurons.put(worker.neuron_id, worker);
        }
    }
    void add_matched_special_neurons(Neuron a, Neuron b) {
        assert(a.neuron_id == b.neuron_id);
        Neuron special_neuron = new Neuron(a.neuron_id);
        ArrayList<Axon> only_b_axons = new ArrayList<Axon>();
        for (Axon axon : b.neuron_connections) only_b_axons.add(axon);
        for (Axon axon : a.neuron_connections) {
            Axon other = get_equivalent_axon(only_b_axons, axon);
            if (other != null) {
                if (fifty()) add_axon_and_dependents(special_neuron, axon);
                else         add_axon_and_dependents(special_neuron, other);
                only_b_axons.remove(other);
            } else {
                if (fifty()) add_axon_and_dependents(special_neuron, axon);
            }
        }
        for (Axon other : only_b_axons) {
            if (fifty()) add_axon_and_dependents(special_neuron, other);
        }
        special_neurons.put(special_neuron.neuron_id, special_neuron);
    }
    void add_matched_output_neurons(Neuron a, Neuron b) {
        assert(a.neuron_id == b.neuron_id);
        
        Neuron output_neuron = output_neurons.get(a.neuron_id);
        if (output_neuron == null) {
            output_neuron = new Neuron(a.neuron_id);
            output_neurons.put(output_neuron.neuron_id, output_neuron);
        }
    }
    Brain(Brain a, Brain b, Creature creature) {
        this.creature = creature;
        this.additional_mutate_rate = (fifty() ? a.additional_mutate_rate : b.additional_mutate_rate);
        //setup_available_connections();
        for (int i = 0; i < 4; i++) {
            inherited_values[i] = ((fifty()) ? a.inherited_values[i] : b.inherited_values[i]);
            if (fifty()&&fifty()) inherited_values[i] = random(-1,1);
        }
        for (Float f : a.process_results) process_results.add(0f);
        // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        for (Map.Entry me : a.output_neurons.entrySet()) {
            Neuron aa = (Neuron)me.getValue();
            Neuron bb = b.output_neurons.get((Integer)me.getKey());
            add_matched_output_neurons(aa,bb);
        }
        // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        ArrayList<Input> only_b_inputs = new ArrayList<Input>();
        for (Input inp : b.world_inputs) only_b_inputs.add(inp);
        for (Input input : a.world_inputs) {
            Input other = get_equivalent_input(only_b_inputs, input);
            if (other != null) {
                add_matched_input_neurons(input, other);
                only_b_inputs.remove(other);
            } else {
                if (fifty()) add_world_input(input);
            }
        }
        for (Input other : only_b_inputs) {
            if (fifty()) add_world_input(other);
        }
        // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        ArrayList<Neuron> only_a_workers = new ArrayList<Neuron>();
        ArrayList<Neuron> only_b_workers = new ArrayList<Neuron>();
        for (Map.Entry me : b.worker_neurons.entrySet()) {
            only_b_workers.add((Neuron)me.getValue());
        }
        for (Map.Entry me : a.worker_neurons.entrySet()) {
            boolean found = false;
            Neuron aa = (Neuron)me.getValue();
            for (Map.Entry other : b.worker_neurons.entrySet()) {
                Neuron bb = (Neuron)other.getValue();
                if (aa.neuron_id == bb.neuron_id) {
                    add_matched_worker_neurons(aa,bb);
                    only_b_workers.remove(bb);
                    found = true;
                    break;
                }
            }
            if (!found) {
                maybe_add_mismatched_worker_neuron(aa);   
            }
        }
        for (Neuron bb : only_b_workers) maybe_add_mismatched_worker_neuron(bb);
        // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        for (Map.Entry me : a.special_neurons.entrySet()) {
            Neuron aa = (Neuron)me.getValue();
            int index = (Integer)me.getKey();
            Neuron bb = b.special_neurons.get(index);
            add_matched_special_neurons(aa,bb);
        }
        // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        for (int i = 0; i < 2; i++) {
            if (fifty()) {
                tile_type[i] = a.tile_type[i];
            } else {
                tile_type[i] = b.tile_type[i];
            }
            if (fifty()) {
                food_type[i] = a.food_type[i];
            } else {
                food_type[i] = b.food_type[i];
            }
        }
        // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    }
    Brain(Brain source, Creature creature) {
        this.creature = creature;
        this.additional_mutate_rate = source.additional_mutate_rate;
        for (int i = 0; i < 4; i++) {
            if (fifty()&&fifty()) {
                inherited_values[i] = random(-1,1);
            } else {
                inherited_values[i] = source.inherited_values[i];
            }
        }
        for (Float f : source.process_results) process_results.add(0f);
        for (Input inp : source.world_inputs) world_inputs.add(inp.deep_copy());
        for (Map.Entry me : source.worker_neurons.entrySet()) {
            Neuron neuron = ((Neuron)me.getValue());
            worker_neurons.put(neuron.neuron_id, neuron.deep_copy());
        }
        for (Map.Entry me : source.special_neurons.entrySet()) {
            Neuron neuron = (Neuron)me.getValue();
            special_neurons.put(neuron.neuron_id, neuron.deep_copy());
        }
        for (Map.Entry me : source.output_neurons.entrySet()) {
            Neuron neuron = ((Neuron)me.getValue());
            output_neurons.put(neuron.neuron_id, neuron.deep_copy());
        }
        /*
        for (int i = 0; i <= 2; i++) {
            available_connections.put(i, new ArrayList<WorldConnection>());
        }
        for (Map.Entry me : available_connections.entrySet()) {
            int channel = ((Integer)me.getKey());
            ArrayList<WorldConnection> connections = ((ArrayList<WorldConnection>)me.getValue());
            for (WorldConnection guy : connections) {
                available_connections.get(channel).add(guy);   
            }
        }
        */
        for (int i = 0; i < 2; i++) {
            tile_type[i] = source.tile_type[i];
            food_type[i] = source.food_type[i];
        }
        this.num_axons = source.num_axons;
    }
    void mutate_any_axon() {
        // Axons aren't weighted evenly
        int index = (world_inputs.size()) + (worker_neurons.size()) + (special_neurons.size());
        int choice = ((int)random(0, index));
        
        if (choice < special_neurons.size()) {
            mutate_special_input_axon();
            return;
        }
        choice -= special_neurons.size();
        
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
        mutate_axon(worker);
    }
    void mutate_input_axon() {
        
        assert(world_inputs.size() > 0);
        Input source = get_random_world_input();
        assert(source != null);
        if (source.neuron_connections.size() == 0) return;
        
        Axon worker = get_random_axon_from_input(source);
        mutate_axon(worker);    
    }
    void mutate_worker_neuron_axon() {
        if (worker_neurons.size() == 0) return;
        Neuron source = get_random_worker_neuron();
        if (source == null) return;
        
        if (source.neuron_connections.size() == 0) return;
        
        Axon worker = get_random_axon_from_neuron(source);
        mutate_axon(worker); 
    }
    void mutate_axon(Axon axon) {
        assert(axon != null);
        axon.weight += random(-Settings.AXON_MUTATION_AMOUNT, +Settings.AXON_MUTATION_AMOUNT);
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
    void form_connection(Neuron source, Neuron target) {
        assert(output_neurons.get(source.neuron_id) == null);
        if (source.neuron_id == target.neuron_id) {
            return;  
        }
        for (Axon axon : source.neuron_connections) {
            if (axon.target_id == target.neuron_id) return;
        }
        // Assumes there is no connection already
        Axon new_axon = new Axon();
        
        new_axon.gene_id = getNextGeneID();
        
        new_axon.source_id = source.neuron_id;
        new_axon.target_id = target.neuron_id;
        new_axon.weight = random(-Settings.AXON_INITIAL_AMOUNT, +Settings.AXON_INITIAL_AMOUNT);
        source.neuron_connections.add(new_axon);
        target.static_connections_count++;
        num_axons++;
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
    void bisect_axon(ArrayList<Axon> source_connections, Axon original_axon) {
        assert(original_axon != null);
        
        
        Neuron end_neuron = get_middle_or_end_neuron_from_id(original_axon.target_id);
        Neuron middle_neuron = new Neuron(getNextNeuronID());
        
        Axon replacement = new Axon();
        replacement.source_id = original_axon.source_id;
        replacement.target_id = middle_neuron.neuron_id;
        replacement.weight = original_axon.weight;
        replacement.enabled = original_axon.enabled;
        source_connections.add(replacement);
        
        Axon empty_axon = new Axon();
        empty_axon.source_id = middle_neuron.neuron_id;
        empty_axon.target_id = end_neuron.neuron_id;
        empty_axon.weight = 1;
        empty_axon.enabled = original_axon.enabled;
        
        original_axon.target_id = middle_neuron.neuron_id;
        
        middle_neuron.neuron_connections.add(empty_axon);
        if (original_axon.enabled) 
            middle_neuron.static_connections_count++;
        
        worker_neurons.put(middle_neuron.neuron_id, middle_neuron);
        
        original_axon.enabled = false;
        num_axons++;
        num_axons++;
    }
    void bisect_special_input_connection() {
        Neuron worker = get_random_special_neuron();
        
        if (worker.neuron_connections.size() == 0) return;
        
        Axon thing = get_random_axon_from_neuron(worker);
        assert(thing != null);
        bisect_axon(worker.neuron_connections, thing);
    }
    void bisect_any_connection() {
        
        int size = (world_inputs.size()) + (worker_neurons.size()) + (special_neurons.size());
        int random = ((int)random(0, size));
        
        if (random < special_neurons.size()) {
            bisect_special_input_connection();
            return;
        }
        random -= special_neurons.size();
        
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
        
        bisect_axon(source.neuron_connections, thing);
    }
    void bisect_worker_neuron_connection() {
        Neuron source_neuron = get_random_worker_neuron();
        if (source_neuron == null) return;
        if (source_neuron.neuron_connections.size() == 0) return;
        Axon original_axon = get_random_axon_from_neuron(source_neuron);
        assert(original_axon != null);
        
        bisect_axon(source_neuron.neuron_connections, original_axon);
    }
    void add_new_connection_from_any_input() {
        int choice_size = world_inputs.size() + special_neurons.size();
        int choice = ((int)random(0, choice_size));
        if (choice < world_inputs.size()) {
            add_new_connection_from_world_input();
        } else {
            add_new_connection_from_special_input();
        }
    }
    void add_new_connection_from_special_input(Neuron source) {
        Neuron target = get_random_worker_neuron_or_output_neuron();
        assert(target != null);
        form_connection(source, target);
    }
    void add_new_connection_from_special_input() {
        Neuron source = get_random_special_neuron();        
        add_new_connection_from_special_input(source);
    }
    void add_new_connection_from_world_input(Input selection) {
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
        new_axon.gene_id = getNextGeneID();
        new_axon.source_id = selection.neuron_id;
        new_axon.target_id = target.neuron_id;
        new_axon.weight = random(-Settings.AXON_INITIAL_AMOUNT, +Settings.AXON_INITIAL_AMOUNT);
        target.static_connections_count++;
        
        selection.neuron_connections.add(new_axon);
        num_axons++;
    }
    void add_new_connection_from_world_input() {
        assert(world_inputs.size() > 0);
        
        Input selection = get_random_world_input();       
        add_new_connection_from_world_input(selection);
    }
    boolean check_duplication_world_connection(WorldConnection worker, int channel) {
        for (Input input : world_inputs) {
            if (input.channel == channel && input.connection.equals(worker)) return true;
        }
        return false;
    }
    Input add_new_input() {
        if (world_inputs.size() == 0) {
            Input new_input = new Input(getNextNeuronID());
            new_input.connection = new WorldConnection(0,-1);
            new_input.channel = floor(random(0,3));
            world_inputs.add(new_input);
            return new_input;
        }
        while (true) {
            Input source = get_random_world_input();
            WorldConnection connection = source.connection.deep_copy();
            int x = floor(random(-1,2));    // [-1  0  +1]
            int y = -floor(random(0,2));    //  [ 0 +1]
            connection.set_x(connection.get_x() + x);
            connection.set_y(connection.get_y() + y);
            int channel = -1;
            if (random(1) < 0.33) {
                if (source.channel == 0) {
                    channel = (fifty() ? 1 : 2);
                } else if (source.channel == 1) {
                    channel = (fifty() ? 0 : 2);
                } else if (source.channel == 2) {
                    channel = (fifty() ? 1 : 2);
                }
            } else {
                channel = source.channel;
            }
            if (!check_duplication_world_connection(connection, channel)) {
                Input new_input = new Input(getNextNeuronID());
                new_input.connection = connection;
                new_input.channel = channel;
                world_inputs.add(new_input);
                return new_input;
            }
            assert(source != null);
        }
        /*
        int new_channel = ((int)random(0,3));    // [0, 2]
        ArrayList<WorldConnection> choices = available_connections.get(new_channel);
        if (choices.size() == 0) return null;
        else {
            int index = ((int)random(0, choices.size()));
            WorldConnection spot = choices.get(index);
            choices.remove(index);
            
            Input new_input = new Input(getNextNeuronID());
            new_input.connection = spot;
            new_input.channel = new_channel;
            world_inputs.add(new_input);
            return new_input;
        }
        */
    }
    float evaluate_position(Input input, int direction) {
        WorldConnection connection = input.connection;
        assert(connection.get_length() > 0);
        Tile current = creature.tile;
        
        int current_x = current.get_x_index();
        int current_y = current.get_y_index();
        
        assert(direction >= 0 && direction <= 3);
        int rot_x = get_rotated_x(connection.x, connection.y, direction);
        int rot_y = get_rotated_y(connection.x, connection.y, direction);
        
        int target_x = current_x + rot_x;
        int target_y = current_y + rot_y;             
        
        if ( (target_x < 0) || (target_x > Settings.NUM_TILES-1) ) {
            return -1.0f;
        }
        if ( (target_y < 0) || (target_y > Settings.NUM_TILES-1) ) {
            return -1.0f;   
        }
        
        int target_index = (target_x) + (target_y * Settings.NUM_TILES);
        return (creature.species.world.tiles.get(target_index).get_color_by_channel(input.channel)
                / connection.get_length());
    }
    void propagateSpecialInputs() {
        for (Map.Entry me : special_neurons.entrySet()) {
            Neuron neuron = (Neuron)me.getValue();
            int id = neuron.neuron_id;
            
            assert(id >= 3 && id <= 18);
            
            int begin = general_special_neuron_start_index;
            
            if (id == memory_1_input_index || id == memory_2_input_index) {
                propagate(neuron);    // Value loaded from beforehand
            } else if (id == begin) {
                propagate(neuron, 1);
            } else if (id == begin+1) {
                propagate(neuron, inherited_values[0]);
            } else if (id == begin+2) {
                //propagate(neuron, inherited_values[1]);
                propagate(neuron, (creature.frames_since_last_food / Settings.CREATURE_STARVATION_TIMER));
            } else if (id == (begin+3)) {
                //propagate(neuron, inherited_values[2]);
                float val = (creature.get_energy_spent_asexually_reproducing() / Settings.CREATURE_MAX_FOOD);
                propagate(neuron, val);
            } else if (id == (begin+4)) {
                propagate(neuron, (creature.life / Settings.CREATURE_MAX_FOOD));
            } else if (id == (begin+5)) {
                propagate(neuron, ((float)this.creature.age) / (float)Settings.CREATURE_DEATH_AGE);
            } else if (id == (begin+6)) {
                propagate(neuron, 
                            ((float)creature.asexual_reproductive_count) / 
                            ((float)Settings.CREATURE_ASEXUAL_REPRODUCTIVE_LIMIT));
            } else if (id == (begin+7)) {
                propagate(neuron,
                            ((float)creature.sexual_reproductive_count) /
                            ((float)Settings.CREATURE_SEXUAL_REPRODUCTIVE_LIMIT));
            } else if (id == (begin+8)) {
                float val = creature.direction / 4.0f;
                propagate(neuron, val);
            } else if (id == (begin+9)) {
                float xx = (creature.tile.get_x_index() / ((float)Settings.NUM_TILES));
                propagate(neuron, xx);
            } else if (id == (begin+10)) {
                float yy = (creature.tile.get_y_index() / ((float)Settings.NUM_TILES));
                propagate(neuron, yy);
            } else {
                println("Failed to propagate special neuron with id : " + id);
                assert(false);
            }
        }
    }
    void process() {
        
         assert(creature != null);
         
         assert(special_neurons.size() == 13);
         assert(output_neurons.size() == 5);
         assert(process_results.size() == 3);
         
         for (Map.Entry me : worker_neurons.entrySet()) {
             Neuron target = ((Neuron)me.getValue());
             target.dynamic_connections_count = 0;
             target.current_data = 0;
         }
         // Memories propagated during 'propagateSpecialInputs()'
         special_neurons.get(memory_1_input_index).current_data = output_neurons.get(memory_1_output_index).current_data;
         special_neurons.get(memory_2_input_index).current_data = output_neurons.get(memory_2_output_index).current_data;
         for (Map.Entry me : output_neurons.entrySet()) {
             Neuron target = ((Neuron)me.getValue());
             target.dynamic_connections_count = 0;
             target.current_data = 0;
             assert(target.neuron_connections.size() == 0);
         }
         
         for (Input input : world_inputs) {
             float evaluation = evaluate_position(input, creature.direction);
             assert(evaluation >= -1 && evaluation <= 1);
             send_input(input, evaluation);
         }         
         propagateSpecialInputs();
         int index = 0;
         for (Map.Entry me : output_neurons.entrySet()) {
             
             Neuron target = ((Neuron)me.getValue());
             if (target.neuron_id > readable_outputs) continue;    // Only certain outputs are readable
             
             float resulting_data = target.current_data;
             resulting_data = negsig(resulting_data);
             
             //boolean greater = (resulting_data > Settings.CREATURE_MINIMUM_ACTION_THRESHOLD);
             //if (greater) print(greater);
             
             process_results.set(index, resulting_data);    // TODO : Clamp current_data?
             index++;
         }
    }
    boolean push_data_to_internal(Neuron neuron, float data) { //<>// //<>// //<>//
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
            if (!axon.enabled) continue;
            float data = current_data;    // TODO : should we clamp this data with sig function?
            data = negsig(data);
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
    void propagate(Neuron source, float value) {
        assert(source != null);
        axon_iteration(source.neuron_connections, value);
    }
    void propagate(Neuron source) {
        assert(source != null);
        axon_iteration(source.neuron_connections, source.current_data);
    }
    void propagate(int neuron_id) {
        
        Neuron source = worker_neurons.get(neuron_id);
        assert(source != null);
        axon_iteration(source.neuron_connections, source.current_data);        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    int getNextNeuronID() {
        return creature.species.world.getNextNeuronID();   
    }
    int getNextGeneID() {
        return creature.species.world.getNextGeneID();   
    }
    Neuron get_random_special_neuron() {
        Neuron source = null;
        
        int choice = ((int)random(0, special_neurons.size()));
        for (Map.Entry me : special_neurons.entrySet()) {
            if (choice == 0) {
                return (Neuron)me.getValue();
            }
            choice--;
        }
        assert(false);
        return null;
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
    Neuron try_get_middle_or_end_neuron_from_id(int neuron_id) {
        Neuron result = worker_neurons.get(neuron_id);
        if (result != null) return result;
        result = output_neurons.get(neuron_id);
        return result;
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
    String printout_brain(boolean print_to_console) {
        String result = "";
        result += "------------------------\n";
        result += "Species size : " + creature.species.creatures.size() + "\n";
        result += "------------------------\n";
        result += "World Inputs\n";
        for (Input input : world_inputs) {
            result += "\t" + input.get_print() + "\n";
            for (Axon axon : input.neuron_connections) {
                result += "\t\t" + axon.get_print() + "\n";
            }
        }
        result += "Special Inputs\n";
        for (Map.Entry me : special_neurons.entrySet()) {
            result += "\t" + ((Neuron)me.getValue()).get_print() + "\n";
            for (Axon axon : ((Neuron)me.getValue()).neuron_connections) {
                result += "\t\t" + axon.get_print() + "\n";
            }
        }
        result += "Worker Neuorns\n";
        for (Map.Entry me : worker_neurons.entrySet()) {
            result += "\t" + ((Neuron)me.getValue()).get_print() + "\n";
            for (Axon axon : ((Neuron)me.getValue()).neuron_connections) {
                result += "\t\t" + axon.get_print() + "\n";
            }
        }
        result += "------------------------\n";
        if (print_to_console) {
            println(result);
        }
        return result;
    }
}
class Neuron {
    int neuron_id;
    float current_data;
    int static_connections_count;            // The total number of connections into a neuron
    int dynamic_connections_count;           // The frame-number of connections into a neuron
    ArrayList<Axon> neuron_connections;
    
    String get_print() {
        return ("[" + neuron_id + "]");
    }
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
class Axon {
    
    int gene_id = -1;
    
    int source_id = -1;
    int target_id = -1;
    float weight = 0;
    boolean enabled = true;
    String get_print() {
        return ("[" + source_id + "-->" + target_id + "], (" + weight + ", " + enabled + ")");
    }
    Axon deep_copy() {
        
        Axon new_axon = new Axon();
        
        new_axon.gene_id = gene_id;
        
        new_axon.source_id = source_id;
        new_axon.target_id = target_id;
        new_axon.weight = weight;
        new_axon.enabled = enabled;
        
        return new_axon;
    }
    @Override
    public boolean equals(Object other) {
        if (other == this) return true;
        if (!(other instanceof Axon)) return false;
        Axon casted = (Axon) other;
        return 
            (
            (this.source_id == casted.source_id) && 
            (this.target_id == casted.target_id) &&
            (this.gene_id == casted.gene_id)
            );
    }
}
class Input {
    int channel = -1;
    int neuron_id;
    ArrayList<Axon> neuron_connections = new ArrayList<Axon>();
	WorldConnection connection = null;
    String get_print() {
        return ("[" + neuron_id + "(" + channel + ")]");
    }
    Input(int neuron_id) {
        this.neuron_id = neuron_id;
    }
    Input deep_copy() {
        Input new_input = new Input(neuron_id);
        for (Axon axon : neuron_connections) {
            new_input.neuron_connections.add(axon.deep_copy());
        }
        new_input.connection = connection.deep_copy();
        new_input.channel = channel;
        return new_input;
    }
    @Override boolean equals(Object other) {
        if (other == this) return true;
        if (!(other instanceof Input)) return false;
        Input casted = (Input)other;
        return ((channel == casted.channel) && (connection.equals(casted.connection)));
    }
}
class WorldConnection {
    private int x;
    private int y;
    private float length;
    WorldConnection(int x, int y) {
        this.x = x;
        this.y = y;
        calc_length();
    }
    int get_x(){ return x; }
    int get_y(){ return y; }
    void set_x(int x) {
        this.x = x;
        calc_length();
    }
    void set_y(int y) {
        this.y = y;
        calc_length();
    }
    private void calc_length() {
        length = pow((x*x)+(y*y), 0.5f);
    }
    float get_length() { return length; }        
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
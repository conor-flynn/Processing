import java.util.Map;

class Brain {
  
    Creature creature;
    ArrayList<Float> process_results = new ArrayList<Float>();
    ArrayList<Input> world_inputs = new ArrayList<Input>();
    HashMap<Integer, Neuron> worker_neurons = new HashMap<Integer, Neuron>();
    HashMap<Integer, Neuron> output_neurons = new HashMap<Integer, Neuron>();
    Neuron constant_neuron;
    Neuron random_neuron;
    
    Brain(Creature creature) {
        this.creature = creature;
        
        // Output setup
        {
            output_neurons.put(0, new Neuron(0));
            output_neurons.put(1, new Neuron(1));
            output_neurons.put(2, new Neuron(2));
            process_results.add(0f);
            process_results.add(0f);
            process_results.add(0f);
        }
        
        worker_neurons.put(3, new Neuron(3));
        worker_neurons.put(4, new Neuron(4));
        worker_neurons.put(5, new Neuron(5));
        
        constant_neuron = new Neuron(6);
        random_neuron = new Neuron(7);
        
        // Connect middle-neurons to output-neurons
        {
            connect(3, 0);
            connect(3, 1);
            connect(3, 2);
            
            connect(4, 0);
            connect(4, 1);
            connect(4, 2);
            
            connect(5, 0);
            connect(5, 1);
            connect(5, 2);
        }
        
        // Connect constant to middle-neurons
        {
            connect(constant_neuron, 3);
            connect(constant_neuron, 4);
            connect(constant_neuron, 5);
        }
        
        // Connect random to middle-neurons
        {
            connect(random_neuron, 3);
            connect(random_neuron, 4);
            connect(random_neuron, 5);
        }
        
        for (int i = 0; i < 9; i++) {
            add_new_input();   
        }
        for (Input input : world_inputs) {
            WorldConnection connection = input.connection;
            println("(" + connection.x + " , " + connection.y + ")");
        }
        
        /*
        ArrayList<WorldConnection> base_connections = new ArrayList<WorldConnection>();
        {
            base_connections.add(new WorldConnection(-1,  0));
            base_connections.add(new WorldConnection(+1,  0));
            
            base_connections.add(new WorldConnection( 0, +1));
            base_connections.add(new WorldConnection( 0, -1));
            
            base_connections.add(new WorldConnection(-1, -1));
            base_connections.add(new WorldConnection(+1, +1));
            
            base_connections.add(new WorldConnection(-1, +1));
            base_connections.add(new WorldConnection(+1, -1));
            
            base_connections.add(new WorldConnection(0, 0));
        }
        
        for (WorldConnection connection : base_connections) {
            
            Input input = new Input();
            
            int offset_a = ((int) random(0,3));    // [0,2]
            int offset_b = 3;    // First index of worker_neurons
            int neuron_id = offset_a + offset_b;
            
            Neuron target = worker_neurons.get(neuron_id);
            assert(target != null);
            target.static_connections_count++;
            
            input.neuron_id = neuron_id;
            input.connection = connection;
            world_inputs.add(input);
        }
        */
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
    void connect(Neuron source, int target_id) {
        Neuron target = worker_neurons.get(target_id);
        if (target == null) {
            target = output_neurons.get(target_id);
            assert(target != null);
        }
        
        Axon axon = new Axon();
        axon.source_id = source.neuron_id;
        axon.target_id = target_id;
        axon.weight = random(-1f,1f);    // TODO : Does random(-1,1) return an int? Should it be random(-1.0, 1.0)?
        
        source.neuron_connections.add(axon);
        target.static_connections_count++;
    }
    void connect(int source_id, int target_id) {
        Neuron source = worker_neurons.get(source_id);
        assert(source != null);
        
        Neuron target = worker_neurons.get(target_id);
        if (target == null) {
            target = output_neurons.get(target_id);
            assert(target != null);
        }
        
        Axon axon = new Axon();
        axon.source_id = source_id;
        axon.target_id = target_id;
        axon.weight = random(-1f,1f);    // TODO : Does random(-1,1) return an int? Should it be random(-1.0, 1.0)?
        
        
        source.neuron_connections.add(axon);  
        target.static_connections_count++;        
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
         assert(random_neuron    .neuron_connections != null && random_neuron    .neuron_connections.size() > 0);
         assert(constant_neuron  .neuron_connections != null && constant_neuron  .neuron_connections.size() > 0);
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
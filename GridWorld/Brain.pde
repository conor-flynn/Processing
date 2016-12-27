import java.util.Map;

class Brain {
  
    ArrayList<WorldInputNeuron> input_neurons = new ArrayList<WorldInputNeuron>();
    ArrayList<AdditionalInputNeuron> additional_input_neurons = new ArrayList<AdditionalInputNeuron>();
    ArrayList<ProcessNeuron> neurons = new ArrayList<ProcessNeuron>();
    ArrayList<OutputMemoryNeuron> output_memory_neurons = new ArrayList<OutputMemoryNeuron>();
    ArrayList<BaseNeuron> aggregate = new ArrayList<BaseNeuron>();
    Creature creature;
  
    Brain(Creature creature, ArrayList<WorldConnection> inputs, int num_memories, int num_outputs) {
        this.creature = creature;
        for (WorldConnection connection : inputs) {
            buildInput(connection); 
        }
        for (int i = 0; i < 2; i++) {
            buildAdditionalInput(i); 
        }
        for (int i = 0; i < num_memories; i++) {
            buildMemory(); 
        }
        for (int i = 0; i < num_outputs; i++) {
            buildOutput(); 
        }
    }
    
    void buildInput(WorldConnection connection) {
        WorldInputNeuron neuron = new WorldInputNeuron();
        neuron.connection = connection;
        
        input_neurons.add(neuron);
        aggregate.add(neuron);
    }
    void buildAdditionalInput(int index) {
        AdditionalInputNeuron neuron = new AdditionalInputNeuron();
        neuron.input_index = index;
        
        additional_input_neurons.add(neuron);
        aggregate.add(neuron);
    }
    void buildMemory() {
        InputMemoryNeuron input = new InputMemoryNeuron();
        OutputMemoryNeuron output = new OutputMemoryNeuron();
        output.input = input;
        
        neurons.add(input);
        neurons.add(output);
        output_memory_neurons.add(output);
        aggregate.add(input);
        aggregate.add(output);
    }
    void buildOutput() {
        OutputNeuron output = new OutputNeuron();
        
        neurons.add(output);
        aggregate.add(output);
    }
    void process() {
        // Reload memory
        for (OutputMemoryNeuron neuron : output_memory_neurons) {
            neuron.input.hold = neuron.hold;
            neuron.hold = 0;
        }
        // Send off all standard inputs
        for (WorldInputNeuron neuron : input_neurons) {
            neuron.hold = loadFromWorld(neuron.connection);
            send(neuron);
        }
        // Send of all additional inputs
        for (AdditionalInputNeuron neuron : additional_input_neurons) {
            switch (neuron.input_index) {
                case 0:
                    neuron.hold = 1;
                    break;
                case 1:
                    neuron.hold = random(2)-1;
                    break;
                default:
                    println("Illegal input_index for additional_input_neurons");
                    break;
            }
            send(neuron);
        }
        for (OutputMemoryNeuron neuron : output_memory_neurons) {
            send(neuron.input); 
        }
    }
    void send(BaseNeuron neuron) {
        float value = neuron.hold;
        
        if (!(neuron instanceof OutputMemoryNeuron)) {
            neuron.hold = 0;
        }
        if (neuron instanceof ProcessNeuron) {
            ((ProcessNeuron) neuron).current_dependencies = 0; 
        }
        
        for (BrainConnection connection : neuron.links) {
            if (!connection.enabled) continue;
            float send_value = value * connection.weight;
            connection.target.hold += send_value;
            connection.target.current_dependencies++;
            if (connection.target.current_dependencies == connection.target.total_dependencies) {
                send(connection.target); 
            }
        }
    }
    float loadFromWorld(WorldConnection connection) {
        int index = creature.tile.worldIndex;
        index += (connection.x + Settings.NUM_TILES * connection.y);
        if (index < 0 || index >= (Settings.NUM_TILES * Settings.NUM_TILES)) { 
            return -1;
        } else {
            return creature.species.world.tiles.get(index).getEvaluation(); 
        }        
    }
    void mutate() {
        changeConnection();
    }
    void enableConnection() {
      
    }
    void disableConnection() {
      
    }
    void addConnection() {
        int index = (int)Math.floor(random(aggregate.size()));
        BaseNeuron source = aggregate.get(index);
    }
    void removeConnection() {
      
    }
    void changeConnection() {
        int index = (int)Math.floor(random(aggregate.size()));
        BaseNeuron source = aggregate.get(index);
        
        if (source.links.size() == 0) {
            return; 
        } else {
            index = (int)Math.floor(random(source.links.size()));
            BrainConnection connection = source.links.get(index);
            connection.weight += (random(0.24) - 0.12);
        }
    }
    void addInput() {
        int low_x = 0, low_y = 0, high_x = 0, high_y = 0;
        for (WorldInputNeuron neuron : input_neurons) {
            int x = neuron.connection.x;
            int y = neuron.connection.y;
            
            if (x < low_x) low_x = x;
            if (x > high_x) high_x = x;
            if (y < low_y) low_y = y;
            if (y > high_y) high_y = y;
        }
        int x_range = high_x - low_x;
        int y_range = high_y - low_y;
        
        x_range += 2;
        y_range += 2;
        
        while(true) {
             int new_x = (int)(random(x_range) - low_x - 1);
             int new_y = (int)(random(y_range) - low_y - 1);
             
             boolean foundSimilar = false;
             for (WorldInputNeuron neuron : input_neurons) {
                 if (neuron.connection.x == new_x && neuron.connection.y == new_y) {
                     foundSimilar = true;
                     break;
                 }
             }
             if (foundSimilar) {
                 continue; 
             } else {
                 buildInput(new WorldConnection(new_x, new_y));
             }
        }
    }
    void removeInput() {
      
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

class WorldConnection {
    int x, y = 0;
    WorldConnection(int x, int y) {
        this.x = x;
        this.y = y;
    }
}
class BrainConnection {
    ProcessNeuron target = new ProcessNeuron();
    float weight = 0.0;
    boolean enabled = true;
}

class BaseNeuron {
    ArrayList<BrainConnection> links = new ArrayList<BrainConnection>();
    float hold = 0.0;
}
class ProcessNeuron extends BaseNeuron {
    int total_dependencies;
    int current_dependencies;
}
class WorldInputNeuron extends BaseNeuron {
    WorldConnection connection;
}
class AdditionalInputNeuron extends BaseNeuron {
    int input_index = -1; 
}
class InputMemoryNeuron extends ProcessNeuron {

}
class OutputMemoryNeuron extends ProcessNeuron {
    InputMemoryNeuron input;
}
class OutputNeuron extends ProcessNeuron {

}
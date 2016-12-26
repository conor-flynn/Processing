import java.util.Map;

class Brain {
  
    ArrayList<WorldInputNeuron> input_neurons = new ArrayList<WorldInputNeuron>();
    ArrayList<AdditionalInputNeuron> additional_input_neurons = new ArrayList<AdditionalInputNeuron>();
    ArrayList<ProcessNeuron> neurons = new ArrayList<ProcessNeuron>();
    ArrayList<OutputMemoryNeuron> output_memory_neurons = new ArrayList<OutputMemoryNeuron>();
    Creature creature;
  
    Brain(Creature creature, ArrayList<WorldConnection> inputs, int num_additional_inputs, int num_memories, int num_outputs) {
        this.creature = creature;
        for (WorldConnection connection : inputs) {
            buildInput(connection); 
        }
        for (int i = 0; i < num_additional_inputs; i++) {
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
    }
    void buildAdditionalInput(int index) {
        AdditionalInputNeuron neuron = new AdditionalInputNeuron();
        neuron.input_index = index;
        
        additional_input_neurons.add(neuron);
    }
    void buildMemory() {
        InputMemoryNeuron input = new InputMemoryNeuron();
        OutputMemoryNeuron output = new OutputMemoryNeuron();
        output.input = input;
        
        neurons.add(input);
        neurons.add(output);
        output_memory_neurons.add(output);
    }
    void buildOutput() {
        OutputNeuron output = new OutputNeuron();
        
        neurons.add(output);
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
import java.util.Map;

class Brain {
  
    Creature creature;
  
    Brain(Creature creature, ArrayList<WorldConnection> inputs, int num_memories, int num_outputs) {
        this.creature = creature;
        
    }
    Brain(Brain source) {
         
    }
    
    void buildInput(WorldConnection connection) {
        
    }
    void buildAdditionalInput(int index) {
        
    }
    void buildMemory() {
        
    }
    void buildOutput() {
        
    }
    ArrayList<Float> process() {
        ArrayList<Float> results = new ArrayList<Float>();
        return results;
    }
    void send(BaseNeuron neuron) {
        
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
    boolean invalidConnection(BaseNeuron source, BaseNeuron target) {
        if (source == target) return true;
        if (target instanceof WorldInputNeuron) return true;
        if (target instanceof InputMemoryNeuron) return true;
        if (target instanceof AdditionalInputNeuron) return true;
        
        for (BrainConnection connection : target.links) {
            if (invalidConnection(source, connection.target)) {
                return true; 
            }
        }
        return false;
    }
    void mutate() {
        
    }
    void enableConnection() {
        
    }
    void disableConnection() {
        
    }
    void addConnection() {
        
    }
    void removeConnection() {
        
    }
    void changeConnection() {
        
    }
    void addInput() {
        
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



class Neuron {
    int index;
    float value;
    int total_connections;
    int current_connections;
}
class Physiology {
    ArrayList<Neuron> neurons;
}
class Geniology {
    HashMap<Integer, HashMap<Integer, Float>> genes; 
}
class WorldInput {
    HashMap<Integer, WorldConnection> links;
}
class OtherInput {
    HashMap<Integer, Integer> other_links; 
}
class Memory {
    HashMap<Integer, Integer> memories; 
}
class WorldOutput {
    ArrayList<Integer> outputs; 
}
void addInput(WorldConnection connection) {
    int neuron_id = buildNeuron();
    links.put(neuron_id, connection);
}
void addMemory() {
    int first = buildNeuron();
    int second = buildNeuron();
    memories.put(first, second);
}
void addOutput() {
    int index = buildNeuron();
    outputs.add(index);
}
void addConnection() {
    while (true) {
         int first = (int)(random(neurons.size()));
         int second = (int)(random(neurons.size()));
         
         if (invalidConnection(first, second)) {
             continue; 
         } else {
              genes.get(first).put(second, random(0.24) - 0.12);
              return;
         }         
    }
}
boolean invalidConnection(int first, int second) {
  
    if (first == second) return true;
    if (links.contains(second)) return true;
    if (memories.contains(second) && memories.get(second) == first) return true;
    if (other_links.contains(second)) return true;
    
    HashMap<Integer, Float> connections = genes.get(first);
    for (Map.Entry me : connections.entrySet()) {
        if (invalidConnection(first, (Integer)me.getValue())) {
            return true;
        }
    }
    return false;
}
int buildNeuron() {
    Neuron neuron = new Neuron();
    int index = neurons.size();
    neurons.put(index, neuron);
    return index;
}
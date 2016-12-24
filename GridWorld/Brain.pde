import java.util.Map;

class BrainInput {
    int x, y; 
    
    public BrainInput(int x, int y) {
        this.x = x;
        this.y = y;
    }
    public boolean equals(Object o) {
        if (o instanceof BrainInput) {
            BrainInput target = (BrainInput)o;
            return (x == target.x && y == target.y);
        }
        return false;
    }
    BrainInput getCopy() {
        BrainInput result = new BrainInput(x,y);
        return result;
    }
}

class Brain {
  
    ArrayList<BrainInput> brain_inputs;
  
    HashMap<Integer, HashMap<Integer, Float>> genes;
    HashMap<Integer, Float> neurons;
    HashMap<Integer, Integer> signals_sent;
    HashMap<Integer, ArrayList<Integer>> in_coming;  // For a source NodeID, what comes into it
    HashMap<Integer, ArrayList<Integer>> out_going;  // For a source NodeID, what does it connect to
    ArrayList<Integer> output_neurons;
    
    int num_original_inputs, num_additional_inputs, num_memory, num_outputs;
    
    public void __check() {
      
        println("-----------------");
        println(brain_inputs.size());
        println(genes.size());
        println(signals_sent.size());
        println(in_coming.size());
        println(out_going.size());
        println(output_neurons.size());
        println("-----------------");
    }
  
    public Brain(ArrayList<BrainInput> default_inputs, int _num_memory, int _num_outputs) {
      
        this.num_inputs = default_inputs.size();
        this.num_outputs = _num_outputs;
        this.num_memory = _num_memory;
      
        brain_inputs = new ArrayList<BrainInput>();
        for (BrainInput target : default_inputs) {
            brain_inputs.add(target.getCopy()); 
        }
        int num_neurons = num_inputs + num_outputs;
        neurons = new HashMap<Integer, Float>();
        signals_sent = new HashMap<Integer, Integer>();
        in_coming = new HashMap<Integer, ArrayList<Integer>>();
        out_going = new HashMap<Integer, ArrayList<Integer>>();
        for (int i = 0; i < num_neurons; i++) {
            neurons.put(i, 0.0);
            signals_sent.put(i, 0);
            in_coming.put(i, new ArrayList<Integer>());
            out_going.put(i, new ArrayList<Integer>());
        }
        genes = new HashMap<Integer, HashMap<Integer, Float>>();
        for (int i = 0; i < num_inputs; i++) {
            genes.put(i, new HashMap<Integer, Float>());
            for (int j = num_inputs; j < num_neurons; j++) {
                out_going.get(i).add(j); 
                genes.get(i).put(j, getRandomInitialWeight());
            }
        }   
        output_neurons = new ArrayList<Integer>();
        for (int i = num_inputs; i < num_neurons; i++) {
            output_neurons.add(i); 
        }
        
        //__check();
    }
    
    public Brain(Brain source) {
      
        this.num_inputs = source.num_inputs;
        this.num_memory = source.num_memory;
        this.num_outputs = source.num_outputs;
        
        brain_inputs = new ArrayList<BrainInput>();
        for (BrainInput target : source.brain_inputs) {
            brain_inputs.add(target.getCopy()); 
        }
        genes = new HashMap<Integer, HashMap<Integer, Float>>();
        for (Map.Entry me : source.genes.entrySet()) {
            Integer neuronID = (Integer)me.getKey();
            genes.put(neuronID, new HashMap<Integer, Float>());
            
            HashMap<Integer, Float> connections = (HashMap<Integer,Float>)me.getValue();
            for (Map.Entry other : connections.entrySet()) {
                Integer otherID = (Integer)other.getKey();
                Float otherValue = (Float)other.getValue();
                genes.get(neuronID).put(otherID, otherValue);
            }
        }
        neurons = new HashMap<Integer, Float>();
        for (Map.Entry me : source.neurons.entrySet()) {
            Integer neuronID = (Integer)me.getKey();
            Float neuronValue = (Float)me.getValue();
            neurons.put(neuronID, neuronValue);
        }
        signals_sent = new HashMap<Integer, Integer>();
        for (Map.Entry me : source.signals_sent.entrySet()) {
            Integer neuronID = (Integer)me.getKey();
            signals_sent.put(neuronID, 0);
        }
        in_coming = new HashMap<Integer, ArrayList<Integer>>();
        for (Map.Entry me : source.in_coming.entrySet()) {
            Integer neuronID = (Integer)me.getKey();
            ArrayList<Integer> links = (ArrayList<Integer>)me.getValue();
            in_coming.put(neuronID, new ArrayList<Integer>());
            for (Integer i : links) {
                 in_coming.get(neuronID).add(i);
            }
        }
        out_going = new HashMap<Integer, ArrayList<Integer>>();
        for (Map.Entry me : source.out_going.entrySet()) {
            Integer neuronID = (Integer)me.getKey();
            ArrayList<Integer> links = (ArrayList<Integer>)me.getValue();
            out_going.put(neuronID, new ArrayList<Integer>());
            for (Integer i : links) {
                out_going.get(neuronID).add(i); 
            }
        }
        output_neurons = new ArrayList<Integer>();
        for (Integer i : source.output_neurons) {
            output_neurons.add(i); 
        }
        
        //__check();
    }
    
    float getRandomInitialWeight() {
        return (random(2) - 1); 
    }
  
    ArrayList<Float> process(ArrayList<Float> inputs) {
        for (int i = 0; i < neurons.size(); i++) {
            if (i < (num_inputs + num_memory)) {
                neurons.put(i, inputs.get(i)); 
            } else {
                neurons.put(i, 0.0); 
            }
            signals_sent.put(i, 0);
        }
        for (int i = 0; i < (num_inputs + num_memory); i++) {
            send(i);
        }
        ArrayList<Float> outputs = new ArrayList<Float>();
        for (Integer output_neuron : output_neurons) {
            outputs.add(neurons.get(output_neuron));
        }
        return outputs;
    }
    void send(Integer source) {
      
        float value = neurons.get(source);
        ArrayList<Integer> targets = out_going.get(source);
        HashMap<Integer, Float> target_weights = genes.get(source);
        
        for (Integer target : targets) {
            float weight = target_weights.get(target);
            float send_value = (value * weight);
            neurons.put(target, neurons.get(target) + send_value);
            
            signals_sent.put(target, signals_sent.get(target)+1);
            if (signals_sent.get(target) == in_coming.get(target).size()) {
                send(target); 
            }
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
    void mutate() {
         Integer num_outputs = output_neurons.size();
         Integer num_inputs = neurons.size() - num_outputs;
         
         
         Object[] gene_choices = genes.keySet().toArray();
         
         Integer gene_index_choice = int(random(gene_choices.length));
         
         Integer gene = (Integer)gene_choices[gene_index_choice];
         Object[] choices = genes.get(gene).keySet().toArray();
         Integer choice_index = int(random(choices.length));
         
         Integer choice = (Integer)choices[choice_index];
         
         Float value = genes.get(gene).get(choice);
         value += (random(0.2) - 0.1);
         genes.get(gene).put(choice, value);
    }
}
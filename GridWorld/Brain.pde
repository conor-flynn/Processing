class Brain {
  
    ArrayList<ArrayList<Float>> neurons = new ArrayList<ArrayList<Float>>();
    ArrayList<ArrayList<ArrayList<Float>>> axons = new ArrayList<ArrayList<ArrayList<Float>>>();
       
    public Brain(ArrayList<Integer> dimensions) { 
      
        if (dimensions == null) return;
        
        for (int layer = 0; layer < dimensions.size(); layer++) {
          
            int numNeurons = dimensions.get(layer);
            
            ArrayList<Float> neuronLayer = new ArrayList<Float>(numNeurons);
            while (neuronLayer.size() < numNeurons) neuronLayer.add(0.0);
            neurons.add(neuronLayer);
            
            if (layer+1 < dimensions.size()) {
              
                ArrayList<ArrayList<Float>> axons2 = new ArrayList<ArrayList<Float>>();
                
                int nextNumNeurons = dimensions.get(layer+1);
                
                for (int neuron = 0; neuron < numNeurons; neuron++) {
                  
                    ArrayList<Float> axons3 = new ArrayList<Float>();                    
                    for (int gene = 0; gene < nextNumNeurons; gene++) {
                        axons3.add(random(0.1)-0.05);
                    }
                    axons2.add(axons3);
                    
                }
                axons.add(axons2);
            }
        }
        
    }
    
    void copyBrain(Brain other) {
      
        for (int layer = 0; layer < other.neurons.size(); layer++) {
          
            int numNeurons = other.neurons.get(layer).size();
            ArrayList<Float> neuronLayer = new ArrayList<Float>(numNeurons);
            while (neuronLayer.size() < numNeurons) neuronLayer.add(0.0);
            
            neurons.add(neuronLayer);
            
            if (layer+1 < other.neurons.size()) {
                int nextNumNeurons = other.neurons.get(layer+1).size();
                ArrayList<ArrayList<Float>> axons2 = new ArrayList<ArrayList<Float>>();
                for (int neuron = 0; neuron < numNeurons; neuron++) {
                    ArrayList<Float> axons3 = new ArrayList<Float>();
                    for (int gene = 0; gene < nextNumNeurons; gene++) {
                        axons3.add(other.axons.get(layer).get(neuron).get(gene)); 
                    }
                    axons2.add(axons3);
                }
                axons.add(axons2);
            }            
        }
    }
    
    void mutate() {
        int layer = (int)random(axons.size());
        int neuron = (int)random(axons.get(layer).size());
        int gene = (int)random(axons.get(layer).get(neuron).size());
        float delta = random(0.1) - 0.05;
        float current = axons.get(layer).get(neuron).get(gene);
        axons.get(layer).get(neuron).set(gene, current+delta);
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
    
    void process(ArrayList<Float> inputs) {
        for (int i = 0; i < inputs.size(); i++) {
            neurons.get(0).set(i, inputs.get(i)); 
        }
        for (int layer = 1; layer < neurons.size(); layer++) {
            for (int neuron = 0; neuron < neurons.get(layer).size(); neuron++) {
                neurons.get(layer).set(neuron, 0.0); 
            }
        }
        
        // Inputs need to already be negsig'd        
        for (int layer = 0; layer < neurons.size()-1; layer++) {
            for (int neuron = 0; neuron < neurons.get(layer).size(); neuron++) {
                float currentValue = neurons.get(layer).get(neuron);
                for (int gene = 0; gene < axons.get(layer).get(neuron).size(); gene++) {
                    float geneWeight = axons.get(layer).get(neuron).get(gene);
                    float targetNeuronValue = neurons.get(layer+1).get(gene);
                    float targetNewValue = (currentValue * geneWeight) + targetNeuronValue;
                    
                    neurons.get(layer+1).set(gene, targetNewValue);                    
                }
            }
            for (int neuron = 0; neuron < neurons.get(layer+1).size(); neuron++) {
                float newValue = negsig(neurons.get(layer+1).get(neuron));
                neurons.get(layer+1).set(neuron, newValue);
            }
        }
    }
}
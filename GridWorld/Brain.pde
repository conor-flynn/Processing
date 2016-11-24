class Brain {
  
    ArrayList<float[]> inputPlus;
    float[] hiddenVals;
    ArrayList<float[]> hiddenPlus;
    float[] outputVals;
    
    int numInputs = 21;
    int numHidden = 16;
    int numOutputs = 4;
      // 0: north
      // 1: south
      // 2: east
      // 3: west
      // 4: consume food
      // 5: reproduce
   
    public Brain() {
        
        inputPlus = new ArrayList<float[]>();
        hiddenVals = new float[numHidden];        
        hiddenPlus = new ArrayList<float[]>();
        outputVals = new float[numOutputs];
        
        for (int i = 0; i < numInputs; i++) {
            float[] data = new float[numHidden];
            for (int j = 0; j < numHidden; j++) {
                data[j] = (random(0.1)-0.05);
            }
            inputPlus.add(data);
        }
        for (int i = 0; i < numHidden; i++) {
            float[] data = new float[numOutputs];
            for (int j = 0; j < numOutputs; j++) {
                data[j] = (random(0.1)-0.05);
            }
            hiddenPlus.add(data);
        }
    }
    
    void copyBrain(Brain other) {
        for (int i = 0; i < inputPlus.size(); i++) {
            float[] target = other.inputPlus.get(i);
            for (int j = 0; j < target.length; j++) {
                inputPlus.get(i)[j] = target[j];
            }
        }
        for (int i = 0; i < hiddenPlus.size(); i++) {
            float[] target = other.hiddenPlus.get(i);
            for (int j = 0; j < target.length; j++) {
                hiddenPlus.get(i)[j] = target[j];
            }
        }
    }
    
    void mutate() {
        if (random(1) > 0.5) {
            //inputPlus
            int choice1 = (int)random(inputPlus.size());
            int choice2 = (int)random(inputPlus.get(choice1).length);
            inputPlus.get(choice1)[choice2] += (random(0.1)-0.05);
        } else {
            //hiddenPlus
            int choice1 = (int)random(hiddenPlus.size());
            int choice2 = (int)random(hiddenPlus.get(choice1).length);
            hiddenPlus.get(choice1)[choice2] += (random(0.1)-0.05);
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
    
    void process(ArrayList<Float> inputs) {        
        
        for (int i = 0; i < numHidden; i++) {
            hiddenVals[i] = 0;
        }
        for (int i = 0; i < numOutputs; i++) {
            outputVals[i] = 0;
        }
        for (int i = 0; i < inputs.size(); i++) {
            for (int j = 0; j < numHidden; j++) {
                float val = inputs.get(i);
                float[] links = inputPlus.get(i);
                for (int k = 0; k < links.length; k++) {
                    float result = links[k] * val;
                    hiddenVals[k] += result;
                }
            }
        }
        for (int i = 0; i < hiddenVals.length; i++) {
          
            hiddenVals[i] = negsig(hiddenVals[i]);
            float val = hiddenVals[i];            
            for (int j = 0; j < numOutputs; j++) {
                outputVals[j] += val * hiddenPlus.get(i)[j];
            }
        }
        for (int i = 0; i < outputVals.length; i++) {
            outputVals[i] = negsig(outputVals[i]);
        }
    }
}
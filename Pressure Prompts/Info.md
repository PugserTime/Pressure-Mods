If you want the prompt to display a quantity like `x2` or a price like `$10`, you need to provide a **Model** that holds the necessary attributes.  

### **How to Set It Up**  
In the prompt configuration, include:  
```luau
Model = TheModelHoldingThePrompt
```
This model should have attributes for the values you want to display:  

- **`Copies` Attribute** → Sets the quantity shown (e.g., `30` will display as `x30`).  
- **`Price` Attribute** → Sets the price (e.g., `100` will display as `$100`).  

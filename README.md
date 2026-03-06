# SuperNova-Work


This repository is dedicated to the simulation work working regarding the SuperNova neutrinos. 

This work highlights different core colapse models and different juyter notebooks to analyze said models. 


This Python script processes and visualizes neutrino flux data from the Garching supernova simulations. It reads time-bin mappings from garching_pinched_info_key.dat and corresponding alpha, energy, and luminosity values from garching_pinched_info.dat, matching them based on their first-column IDs. The script then organizes and filters the data, ensuring proper alignment before plotting time-dependent trends for different neutrino species (ν_e, ν̅_e, ν_x). The visualization includes logarithmic scaling, core bounce reference, and distinct line styles for clarity. This approach streamlines data processing by eliminating filename-based ID extraction and directly leveraging structured data matching.

Running the code will yield this kind of graph:

![image](https://github.com/user-attachments/assets/f24cdb6d-b035-43fa-a6e7-ada74eea1ef7)


With the axis matching to the original DUNE Paper: https://arxiv.org/pdf/2008.06647. The vertical line at 0.02s signifies the core bounce.

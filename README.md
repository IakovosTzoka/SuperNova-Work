# SuperNova-Work


This repository is dedicated to the simulation work working regarding the SuperNova neutrinos. 

It contains the complete simulation package, where photon propagation happens using both Geant4 and Opticks (If Opticks is installed)

1) To start the simulation under the output repository access the SNEWPY_JSON_Root_File_Generation Jupyter Notebook.

2) Run the script using which ever model you're interested in, currently this script is setup to run Nakazato and Bollig models.
   The script will generat two files, a JSON file used as a config file for Marley and a root file with a TH2D of the chosen model and oscillation profile. (Energy vs Time vs Flux)

   ![alt text](image.png)
3) Under macros directory, open the Template_Supernova_Neutrino macro file. There change the appropriate naming conventions, 
   for the JSON config file, the TH2D file path, output name and path and finally the beam on for the number of instances or events you want to run. 
4) Now to run the actual siulation, create the directory *mkdir buid* and *cd build* 

5) Then run *cmake ..* 

6) Followed by make to build the simulation

7) Finally run *cd ..* the build directory and run * ./sim.sh*


This Python script processes and visualizes neutrino flux data from the Garching supernova simulations. It reads time-bin mappings from garching_pinched_info_key.dat and corresponding alpha, energy, and luminosity values from garching_pinched_info.dat, matching them based on their first-column IDs. The script then organizes and filters the data, ensuring proper alignment before plotting time-dependent trends for different neutrino species (ν_e, ν̅_e, ν_x). The visualization includes logarithmic scaling, core bounce reference, and distinct line styles for clarity. This approach streamlines data processing by eliminating filename-based ID extraction and directly leveraging structured data matching.

Running the code will yield this kind of graph:

![image](https://github.com/user-attachments/assets/f24cdb6d-b035-43fa-a6e7-ada74eea1ef7)


With the axis matching to the original DUNE Paper: https://arxiv.org/pdf/2008.06647. The vertical line at 0.02s signifies the core bounce.

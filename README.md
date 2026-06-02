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

## Addendum: Semi-Analytical ROOT Output Mode

For large event samples, the full ROOT output can be larger than needed for the QPix semi-analytical workflow. A runtime flag was added to trim the `event_tree` while still saving the Geant4 optical photon tree.

Add this command to the macro before `/run/initialize`:

```text
/inputs/semi_analytical_output true
```

When this flag is `true`, `event_tree` only writes the branches needed by the semi-analytical method:

```text
run
hit_start_x
hit_end_x
hit_start_y
hit_end_y
hit_start_z
hit_end_z
hit_start_t
hit_end_t
hit_energy_deposit
hit_length
```

The Geant4 optical photon tree is still written as `G4_Photons` with:

```text
event_id
photon_hit_x
photon_hit_y
photon_hit_z
photon_hit_t
photon_hit_wavelength
```

The `metadata` tree is also still written because it is small and records detector dimensions/configuration. If `/inputs/semi_analytical_output true` is not set, the simulation keeps the normal full ROOT output.

Example macro fragment:

```text
/inputs/generator MARLEY
/inputs/particle_type MARLEY
/inputs/MARLEY_json ../cfg/marley_config.js
/inputs/output_file ../output/MARLEY_slim.root
/inputs/semi_analytical_output true

/run/initialize
/run/beamOn 1000
```

Current Mac/Apple Silicon build usage:

```bash
cd $HOME/Programs/Library/SuperNova-Work
cmake -S . -B build -DWith_Opticks=OFF -DWITH_GEANT4_UIVIS=OFF
cmake --build build --parallel 1
cd macros
../build/app/G4_QPIX test.mac
```

Notes:

- `With_Opticks=OFF` is required on this Mac setup because Opticks requires CUDA.
- `WITH_GEANT4_UIVIS=OFF` builds the batch-mode executable without the Geant4 UI/visualization dependencies.
- `cmake --build build --parallel 1` only limits compile jobs. Runtime is single-threaded because the app uses the serial Geant4 run manager.
- The semi-analytical flag was added as a runtime macro command in `ConfigManager`, and `AnalysisManager` uses it when booking ROOT branches.

Implementation details for the flag:

- `src/ConfigManager.h:52` adds `GetSemiAnalyticalOutput()`.
- `src/ConfigManager.h:92` adds `SetSemiAnalyticalOutput(...)`.
- `src/ConfigManager.h:148` adds the private `semiAnalyticalOutput_` member.
- `src/ConfigManager.cpp:49` initializes the flag to `false` by default.
- `src/ConfigManager.cpp:69` copies the flag into worker/thread-local config instances.
- `src/ConfigManager.cpp:121` registers the macro command `/inputs/semi_analytical_output`.
- `src/ConfigManager.cpp:178` prints the flag in the configuration dump.
- `src/AnalysisManager.cpp:94` reads the flag when booking the ROOT trees.
- `src/AnalysisManager.cpp:100` starts the `if (!semiAnalyticalOutput)` block that keeps the full-output-only branches out of slim mode.
- `src/AnalysisManager.cpp:173-182` always books the semi-analytical hit branches, so they are present in both full and slim output modes.
- `src/AnalysisManager.cpp:184` continues into the optical photon tree booking, so `G4_Photons` is still saved in slim mode.

## Addendum: macOS Install Notes Through SuperNova

This addendum is adapted from `README_QPIX_MAC_INSTALL.md` through the Q-Pix Geant4/SuperNova build section, stopping before `Q_PIX_RTD`. It is intended for running `SuperNova-Work` on macOS/Apple Silicon without Opticks.

Important version note: the GitHub/Linux installation path is set up around Geant4 11.1.1. That newer Geant4 stack is the path to keep in mind if Opticks support is added later, because Opticks requires CUDA and is not usable on Apple Silicon. The macOS setup below uses Geant4 10.7.4 as the local batch-mode, non-Opticks build that works on this machine.

### 1. Create The Workspace

```sh
cd
mkdir -p Programs/Library
cd Programs/Library
```

Use `$HOME/Programs/Library` as the Mac replacement for the Linux `$HOME/Programs` workspace.

### 2. Base Dependencies

On Ubuntu the install uses `apt`. On macOS, install the equivalent build tools with Homebrew:

```sh
brew install cmake gcc gfortran gawk git autoconf automake libtool
brew install boost gsl libxml2 log4cpp pcre qt@5 tbb xerces-c nlohmann-json wget
brew install root
```

If Homebrew already has a package installed, leave it alone. Do not build a second copy unless a special version is required.

### 3. LHAPDF5

Use the same LHAPDF 5 tarball, but keep the install under the Mac workspace:

```sh
cd $HOME/Programs/Library
tar -xvzf $HOME/Downloads/lhapdf-5.9.1.tar.gz
cd lhapdf-5.9.1
```

Mac-specific change:

```sh
export FCFLAGS="-std=legacy"
```

Configure against a local prefix:

```sh
./configure --disable-pyext --disable-octave --prefix=$HOME/Library/TMP
make
make install
```

If the prefix has old root-owned files, fix ownership before installing:

```sh
sudo chown -R "$(whoami)" $HOME/Library/TMP
```

### 4. PYTHIA6

Use the PYTHIA 6.428 source file and place it in the Mac workspace:

```sh
cd $HOME/Programs/Library
mkdir -p pythia6
cd pythia6
```

Create `pythia6428.f` from the downloaded file.

Then build it through GENIE's helper script. On macOS the script needed this patch first:

```diff
- gcc -o fsplit fsplit.c
+ gcc -std=gnu89 -o fsplit fsplit.c
```

Then run:

```sh
cd $HOME/Programs/Library/GENIE/Generator/src/scripts/build/ext
source ./build_pythia6.sh clean
```

The expected result is:

```sh
$HOME/Programs/Library/pythia6/v6_428/lib/libPythia6.dylib
```

### 5. ROOT

On this Mac, Homebrew ROOT was used instead of a separate source build tree.

Use this path in the rest of the notes:

```sh
/opt/homebrew/Cellar/root/6.38.00
```

That means this Linux line:

```sh
export ROOTSYS=$HOME/Programs/root_build/
```

becomes:

```sh
export ROOTSYS=/opt/homebrew/Cellar/root/6.38.00
```

The usual ROOT setup still applies:

```sh
source $ROOTSYS/bin/thisroot.sh
```

Because ROOT 6.38 no longer ships the old `TPythia6` support GENIE expects, a small compatibility library from ROOT 6.26 `montecarlo/pythia6` was built here:

```sh
$HOME/Programs/Library/root-egpythia6-compat/install
```

### 6. GENIE

Clone GENIE into the Mac workspace:

```sh
cd $HOME/Programs/Library
mkdir -p GENIE
cd GENIE
git clone --branch R-3_02_00 https://github.com/GENIE-MC/Generator.git
```

Mac-specific files that needed changes:

```txt
GENIE/Generator/configure
GENIE/Generator/src/make/Make.include
GENIE/Generator/src/Physics/HadronTransport/INukeNucleonCorr.cxx
```

The important substitutions are:

```txt
- use Homebrew ROOT instead of a local ROOT source build
- link against $HOME/Programs/Library/root-egpythia6-compat/install
- keep the build serial; do not use make -j8 for GENIE
```

The configure line that worked on this Mac was:

```sh
cd $HOME/Programs/Library/GENIE/Generator
./configure \
  --enable-lhapdf5 \
  --enable-fnal \
  --enable-nucleon-decay \
  --enable-atmo \
  --enable-test \
  --enable-gfortran \
  --with-compiler=clang \
  --with-pythia6-lib=$HOME/Programs/Library/pythia6/v6_428/lib \
  --with-lhapdf5-inc=$HOME/Library/TMP/include \
  --with-lhapdf5-lib=$HOME/Library/TMP/lib \
  --with-log4cpp-inc=/opt/homebrew/opt/log4cpp/include \
  --with-log4cpp-lib=/opt/homebrew/opt/log4cpp/lib \
  --with-libxml2-inc=/opt/homebrew/opt/libxml2/include/libxml2 \
  --with-libxml2-lib=/opt/homebrew/opt/libxml2/lib \
  --with-gfortran-lib=/opt/homebrew/opt/gcc/lib/gcc/current
make
```

Verification:

```sh
gmkspl --help
```

If it prints usage text and exits with a usage error, GENIE is alive.

### 7. Geant4 10.7.4

The Linux notes use `apt`. On macOS, use Homebrew Qt and X11 dependencies instead:

```sh
brew install qt@5 xerces-c libxml2
```

Download and unpack Geant4:

```sh
cd $HOME/Programs/Library
wget https://gitlab.cern.ch/geant4/geant4/-/archive/v10.7.4/geant4-v10.7.4.tar.gz
tar -xzvf geant4-v10.7.4.tar.gz
```

Configure:

```sh
cd $HOME/Programs/Library/geant4-v10.7.4
mkdir geant4.10.7.4-build geant4.10.7.4-install
cmake -S . -B geant4.10.7.4-build \
  -DCMAKE_INSTALL_PREFIX=$HOME/Programs/Library/geant4-v10.7.4/geant4.10.7.4-install \
  -DCMAKE_PREFIX_PATH=/opt/homebrew/opt/qt@5 \
  -DGEANT4_INSTALL_DATA=ON \
  -DGEANT4_USE_GDML=ON \
  -DGEANT4_USE_QT=ON \
  -DGEANT4_USE_RAYTRACER_X11=ON \
  -DGEANT4_USE_OPENGL_X11=ON \
  -DGEANT4_BUILD_MULTITHREADED=ON \
  -DGEANT4_USE_SYSTEM_ZLIB=ON
```

Patch needed for the current compiler:

```diff
- ,m_branch(a_from.m_barnch)
+ ,m_branch(a_from.m_branch)
```

File:

```txt
geant4-v10.7.4/source/analysis/g4tools/include/tools/wroot/columns.icc
```

Build and install:

```sh
cmake --build $HOME/Programs/Library/geant4-v10.7.4/geant4.10.7.4-build --target install -j8
```

Geant4 on this Mac needs one extra fix before SuperNova can configure:

```sh
mv $HOME/Programs/Library/geant4-v10.7.4/geant4.10.7.4-install/lib/Geant4-10.7.4/Geant4PackageCache.cmake \
   $HOME/Programs/Library/geant4-v10.7.4/geant4.10.7.4-install/lib/Geant4-10.7.4/Geant4PackageCache.cmake.disabled
```

Geant4 10.7.4 also needs two source edits in `SuperNova-Work` that are not required on newer Geant4 releases:

- In `src/RunAction.cpp`, replace `G4StrUtil::to_lower(...)` with standard C++ lowercase conversion.
- In `src/OpticalMaterialProperties.cpp`, remove the trailing `true` argument from `AddProperty(...)` and `AddConstProperty(...)` calls, because the 10.7.4 `G4MaterialPropertiesTable` signatures do not accept it.

Verification:

```sh
cd $HOME/Programs/Library/geant4-v10.7.4/geant4.10.7.4-install/bin
source ./geant4.sh
geant4-config --version
```

Expected:

```txt
10.7.4
```

### 8. MARLEY

Clone and build:

```sh
cd $HOME/Programs/Library
git clone https://github.com/MARLEY-MC/marley.git
cd marley
make -C build all
```

Mac-specific change to `setup_marley.sh`:

```sh
# For building against MARLEY
export CPLUS_INCLUDE_PATH=${CPLUS_INCLUDE_PATH}:${THIS_DIRECTORY}/include
export LIBRARY_PATH=${LIBRARY_PATH}:${THIS_DIRECTORY}/build
```

That is enough to make the Mac build and ROOT integration work.

### 9. SuperNova-Work

Clone or enter this repository:

```sh
cd $HOME/Programs/Library
git clone https://github.com/IakovosTzoka/SuperNova-Work.git
cd SuperNova-Work
```

For the Mac/Apple Silicon, non-Opticks build, configure with Opticks and UI/VIS disabled:

```sh
cmake -S . -B build \
  -DWith_Opticks=OFF \
  -DWITH_GEANT4_UIVIS=OFF
```

Build:

```sh
cmake --build build --parallel 1
```

Run a MARLEY test macro:

```sh
cd macros
../build/app/G4_QPIX test.mac
```

Expected output:

```txt
$HOME/Programs/Library/SuperNova-Work/output/MARLEY.root
```

Check it with:

```sh
rootls $HOME/Programs/Library/SuperNova-Work/output/MARLEY.root
```

Expected keys include:

```txt
event_tree  G4_Photons  metadata
```

For smaller ROOT files compatible with the semi-analytical workflow, add this macro command before `/run/initialize`:

```text
/inputs/semi_analytical_output true
```

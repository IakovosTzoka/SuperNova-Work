#!/bin/bash

# Source setup
source /home/iakovos-qpix/Programs/Library/marley/setup_marley.sh || exit 1
cd /home/iakovos-qpix/Programs/Library/MarleyTest/macros || exit 1

TEMPLATE=Radiogenic_Ar42_background.mac

# Define Isotopes from your table: [Label]="A Z Events"
declare -A ISOTOPES=(
    ["Po210"]="210 84 5"
    ["Co60"]="60 27 41"
    ["K40"]="40 19 1000"
    ["Ar39"]="39 18 1000"
    ["Ar42"]="42 18 64"
    ["K42"]="42 19 64"
    ["Rn222"]="222 86 1000"
    ["Pb214"]="214 82 1000"
    ["Bi214"]="214 83 1000"
    ["Kr85"]="85 36 1000"
    ["Rn219"]="219 86 1000"
    ["Rn220"]="220 86 1000"
)

for NAME in "${!ISOTOPES[@]}"; do
    VALS=(${ISOTOPES[$NAME]})
    A=${VALS[0]}
    Z=${VALS[1]}
    NEVENTS=${VALS[2]}

    LABEL="${NAME}"
    WORK_MACRO="run_${LABEL}.mac"
    cp "$TEMPLATE" "$WORK_MACRO"

    # 1. Update output path (matches your absolute path structure)
    sed -i "s|/inputs/output_file .*|/inputs/output_file /media/iakovos-qpix/aSeVertical/SuperNova\ Simulation/ROOT\ Files/SuperNova_Backgrounds/radiogenic_${LABEL}.root|" "$WORK_MACRO"


    # 3. Set the specific Nucleus Limits
    sed -i "s|/process/had/rdm/nucleusLimits .*|/process/had/rdm/nucleusLimits ${A} ${A} ${Z} ${Z}|" "$WORK_MACRO"

    # 4. Update the generator command (e.g., N_Ar42_Decays -> N_Kr85_Decays)
    sed -i "s|/supernova/N_Ar42_Decays|/supernova/N_${NAME}_Decays|" "$WORK_MACRO"

    # 5. Set the number of events
    sed -i "s|/run/beamOn .*|/run/beamOn ${NEVENTS}|" "$WORK_MACRO"

    echo "=== Starting Run: $LABEL (A=$A, Z=$Z, Events=$NEVENTS) ==="
    ../build/app/G4_QPIX "$WORK_MACRO"

    if [ $? -ne 0 ]; then
        echo "ERROR: Run failed for $LABEL. If it says 'Command Not Found'"
        exit 1
    fi
done

echo "All background runs submitted."

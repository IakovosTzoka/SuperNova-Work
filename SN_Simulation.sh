#!/bin/bash

source /home/iakovos-qpix/Programs/Library/marley/setup_marley.sh || { echo "Failed to source MARLEY! Exiting..."; exit 1; }

cd /home/iakovos-qpix/Programs/Library/MarleyTest/macros || exit 1

TEMPLATE=Template_Supernova_Neutrino.mac

# --- Models and their ROOT data files ---
declare -A ROOT_FILES=(
    ["Nakazato"]="supernova_data_Nakazato.root"
    ["Bollig"]="supernova_data_Bollig.root"
)

# --- Oscillation schemes ---
OSCILLATIONS=("No_Oscillations" "Normal_Hierarchy" "Inverted_Hierarchy")

for MODEL in Nakazato Bollig; do
    ROOT_FILE="${ROOT_FILES[$MODEL]}"

    for OSC in "${OSCILLATIONS[@]}"; do

        LABEL="${MODEL}_${OSC}"
        WORK_MACRO=run_${LABEL}.mac
        cp "$TEMPLATE" "$WORK_MACRO"

        # Patch the four lines that change per run
        sed -i "s|/inputs/MARLEY_json .*|/inputs/MARLEY_json ../cfg/config_${MODEL}_${OSC}.js|"       "$WORK_MACRO"
        sed -i "s|/inputs/input_file .*|/inputs/input_file ${ROOT_FILE}|"                              "$WORK_MACRO"
        sed -i "s|/supernova/timing/th2_name .*|/supernova/timing/th2_name h2d_${MODEL}_${OSC// /_}|" "$WORK_MACRO"
        sed -i "s|/inputs/output_file .*|/inputs/output_file /media/iakovos-qpix/aSeVertical/SuperNova Simulation/ROOT Files/${LABEL}_1000_events.root|"    "$WORK_MACRO"

        echo "=== Running: $LABEL ==="
        ../build/app/G4_QPIX "$WORK_MACRO"

        if [ $? -ne 0 ]; then
            echo "ERROR: Run failed for $LABEL — stopping."
            exit 1
        fi

        echo "=== Done: ../output/${LABEL}_1000_events.root ==="
    done
done

echo "All runs complete."

# SuperNova-Work


This repository is dedicated to the simulation work working regarding the SuperNova neutrinos. 

This work highlights different core colapse models and different juyter notebooks to analyze said models. 


This Python script processes and visualizes neutrino flux data from the Garching supernova simulations. It reads time-bin mappings from garching_pinched_info_key.dat and corresponding alpha, energy, and luminosity values from garching_pinched_info.dat, matching them based on their first-column IDs. The script then organizes and filters the data, ensuring proper alignment before plotting time-dependent trends for different neutrino species (ν_e, ν̅_e, ν_x). The visualization includes logarithmic scaling, core bounce reference, and distinct line styles for clarity. This approach streamlines data processing by eliminating filename-based ID extraction and directly leveraging structured data matching.

Running the code will yield this kind of graph:

![image](https://github.com/user-attachments/assets/f24cdb6d-b035-43fa-a6e7-ada74eea1ef7)


With the axis matching to the original DUNE Paper: https://arxiv.org/pdf/2008.06647. The vertical line at 0.02s signifies the core bounce.

*****Further Development of the SuperNovae Work*******

This script loads two core-collapse supernova (CCSN) model families (Nakazato 2013 and Bollig 2016) using snewpy, computes electron-neutrino (ν_e) time-dependent spectra under several flavor-transformation scenarios, saves simple time-series CSVs (luminosity, mean energy, pinching parameter), and produces plots:
	•	luminosity, mean energy, and pinch parameter vs time
	•	2-D heatmaps (time × energy) of the differential spectrum \frac{d^2N}{dE\,dt} (units #/s/MeV) for each model & oscillation scenario
	•	time-integrated spectra (counts vs energy) computed by integrating the differential spectrum over time

You can also optionally save time-integrated spectra for use with external event generators (e.g., MARLEY).

Requirements

Install these Python packages (conda/pip):
	•	Python 3.8+
	•	numpy, matplotlib, pandas
	•	astropy (for units)
	•	snewpy (SuperNova Early Warning Project models)
	•	scipy (for gamma if needed in other code)


```
conda create -n snspec python=3.10 numpy matplotlib pandas astropy scipy -c conda-forge
conda activate snspec
pip install snewpy
```

Files produced

For each model (Nakazato, Bollig) the script writes:
	•	Nakazato_nu_e_timeseries.csv and Bollig_nu_e_timeseries.csv — columns: time_s, luminosity_erg_per_s, mean_energy_MeV, alpha

And shows plots:
	•	3 small subplots for luminosity / meanE / pinch vs time
	•	heatmap of dN/dEdt (time × energy) for each oscillation case
	•	time-integrated counts vs energy (step histogram)
  
<img width="797" height="265" alt="Screenshot 2025-11-11 at 12 39 11 PM" src="https://github.com/user-attachments/assets/2e63f796-0816-45be-86da-b70089ae9e5b" />

<img width="561" height="388" alt="Screenshot 2025-11-11 at 12 55 13 PM" src="https://github.com/user-attachments/assets/d050081a-9b43-412d-b32a-753e0f8f78ae" />

<img width="563" height="386" alt="Screenshot 2025-11-11 at 12 56 46 PM" src="https://github.com/user-attachments/assets/ba4f439c-f262-4e18-a3df-7a0f074328b9" />


<img width="570" height="383" alt="Screenshot 2025-11-11 at 12 56 25 PM" src="https://github.com/user-attachments/assets/17e0d37d-73f3-4058-97f8-7f37a133ed11" />

<img width="590" height="383" alt="Screenshot 2025-11-11 at 12 57 05 PM" src="https://github.com/user-attachments/assets/d5db0d20-ed9e-4c20-b1c1-645dcc6438fb" />

1) Imports & model initialization

```
import astropy.units as u
import numpy as np
import matplotlib.pyplot as plt
from snewpy.models.ccsn import Nakazato_2013, Bollig_2016
from snewpy.neutrino import Flavor, MassHierarchy
from snewpy.flavor_transformation import NoTransformation, AdiabaticMSW
import pandas as pd
```

I) astropy.units used for clear units (MeV, s, solar mass, etc.).

II) snewpy provides CCSN time series: model.time (array of times), model.luminosity[flavor] (L(t) in erg/s), model.meanE[flavor] (mean energy MeV), model.pinch[flavor] (pinch parameter α).

III) Flavor transformations: NoTransformation() (no oscillations), AdiabaticMSW implements adiabatic matter effects for specified mass hierarchy.

2) Load models & define transforms

```
nakazato = Nakazato_2013(progenitor_mass=20*u.solMass, revival_time=100*u.ms, metallicity=0.004, eos='shen')
bollig = Bollig_2016(progenitor_mass=27*u.solMass)
models = {"Nakazato": nakazato, "Bollig": bollig}
transforms = {
    "No Oscillations": NoTransformation(),
    "Normal Hierarchy": AdiabaticMSW(mh=MassHierarchy.NORMAL),
    "Inverted Hierarchy": AdiabaticMSW(mh=MassHierarchy.INVERTED)
}
```
3) Energy binning

```
E_bins = np.linspace(0, 100, 200) * u.MeV
E_centers = (E_bins[:-1] + E_bins[1:]) / 2
```
I) E_bins are bin edges from 0 → 100 MeV with 200 points (so 199 bins).

II) E_centers are the midpoints: used for plotting if spectra are binned.


4) Time-series CSV save & basic diagnostic plots

```
times = model.time.to_value(u.s)
df = pd.DataFrame({
    "time_s": times,
    "luminosity_erg_per_s": model.luminosity[flavor].to_value(u.erg/u.s),
    "mean_energy_MeV": model.meanE[flavor].to_value(u.MeV),
    "alpha": model.pinch[flavor]
})
df.to_csv(filename, index=False)
```

	•	Saves numerical arrays to CSV for external use. Units explicitly stored.

Then three subplots:
	•	Luminosity vs time: L(t) in erg/s
	•	Mean energy vs time: <E>(t) in MeV
	•	Pinch parameter α(t)

plt.tight_layout() used to avoid overlap.


5) Spectra per transformation & heatmap

For each transform:

```
spectra = model.get_transformed_spectra(model.time, E_bins, transform)
spec_nue = spectra[flavor].to_value(1/(u.s * u.MeV))  # time × energy
plt.pcolormesh(times, E_bins.to_value(u.MeV), spec_nue.T, shading='auto')

```

I) model.get_transformed_spectra(time_array, E_bins, transform) returns a structure spectra indexed by flavor. The data are binned in energy between E_bins edges, and for each time step. Units are typically number per second per MeV (#/s/MeV).

II) spec_nue shape: (n_time, n_energy_bins) or (n_time, n_energy_centers) depending on snewpy behavior — typically time × energy (binned). The code transposes for plotting because pcolormesh expects Z shape (len(Y)-1, len(X)-1) depending on inputs — still, check shapes on your data.

III) Interpretation: the heatmap color shows instantaneous differential emission rate \frac{d^2N}{dE\,dt}(E,t). Integrating this over energy gives \frac{dN}{dt} (events/s — the lightcurve); integrating over time gives N(E) (total counts per energy bin).


6) Time-integration (counts vs energy)

```
counts = np.trapz(spec_nue, x=times, axis=0)  # shape: (n_E,)
E_centers = (E_bins[:-1] + E_bins[1:]) / 2
counts = counts[:-1]   # <--- this was in your code (see bug note)
plt.step(E_centers.to_value(u.MeV), counts, where='mid')

```

I) np.trapz(spec_nue, x=times, axis=0) integrates the differential rate over the time axis to produce counts per energy bin: N(E) = \int \frac{d^2N}{dE\,dt}\,dt. Units: #/MeV (total counts in each energy bin divided by bin width, if spec_nue is per MeV already).

II) Important: do not arbitrarily slice counts = counts[:-1] unless shapes force it — that was a bug we fixed below. Always ensure counts.shape == len(E_centers).


Units & math summary
	•	L(t) — luminosity in erg/s
	•	meanE(t) — mean energy in MeV
	•	pinch α(t) — dimensionless, determines spectral shape
	•	spec_nue[t_idx, e_idx] — differential flux at time t and energy bin e in units #/s/MeV
	•	Time integration:
N(E_j) = \int_{t_{\min}}^{t_{\max}} \frac{d^2N}{dE\,dt}(E_j, t)\, dt
implemented with np.trapz(spec_nue, x=times, axis=0)
	•	Energy integration (to get lightcurve):
\frac{dN}{dt}(t_i) = \int \frac{d^2N}{dE\,dt}(E, t_i)\, dE
implemented with np.trapz(spec_nue, x=E_edges, axis=1) (be careful to integrate with correct axis & edges)


For more questions please reach out!

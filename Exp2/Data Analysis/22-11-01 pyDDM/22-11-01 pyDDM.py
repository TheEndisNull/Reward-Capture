# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""

from pyddm import Sample
import pandas
with open("roitman_rts.csv", "r") as f:
    df_rt = pandas.read_csv(f)

#print(df_rt)

#df_rt = df_rt[df_rt["monkey"] == 1]
#print(df_rt)

df_rt = df_rt[df_rt["rt"] > .1] # Remove trials less than 100ms
df_rt = df_rt[df_rt["rt"] < 1.65] # Remove trials greater than 1650ms

roitman_sample = Sample.from_pandas_dataframe(df_rt, rt_column_name="rt", correct_column_name="correct")



import pyddm as ddm
class DriftCoherence(ddm.models.Drift):
    name = "Drift depends linearly on coherence"
    required_parameters = ["driftcoh"] # <-- Parameters we want to include in the model
    required_conditions = ["coh"] # <-- Task parameters ("conditions"). Should be the same name as in the sample.
    
    # We must always define the get_drift function, which is used to compute the instantaneous value of drift.
    def get_drift(self, conditions, **kwargs):
        return self.driftcoh * conditions['coh']



from pyddm import Model, Fittable
from pyddm.functions import fit_adjust_model, display_model
from pyddm.models import NoiseConstant, BoundConstant, OverlayChain, OverlayNonDecision, OverlayPoissonMixture
model_rs = Model(name='Roitman data, drift varies with coherence',
                 drift=DriftCoherence(driftcoh=Fittable(minval=0, maxval=20)),
                 noise=NoiseConstant(noise=1),
                 bound=BoundConstant(B=Fittable(minval=.1, maxval=1.5)),
                 overlay=OverlayChain(overlays=[OverlayNonDecision(nondectime=Fittable(minval=0, maxval=.4)),
                                                OverlayPoissonMixture(pmixturecoef=.02,
                                                                      rate=1)]),
                 dx=.001, dt=.01, T_dur=2)

fit_model_rs = fit_adjust_model(sample=roitman_sample, model=model_rs, verbose=False)

display_model(fit_model_rs)

import pyddm.plot
import matplotlib.pyplot as plt
pyddm.plot.plot_fit_diagnostics(model=fit_model_rs, sample=roitman_sample)
plt.savefig("roitman-fit.png")
plt.show()


pyddm.plot.model_gui(model=fit_model_rs, sample=roitman_sample)

# -*- coding: utf-8 -*-
"""
Created on Tue Nov  1 16:53:10 2022

@author: Jonathan
"""


from pyddm import Sample
import pandas
with open("HDDM_data_2.csv", "r") as f:
    df_rt = pandas.read_csv(f)
    
print(df_rt)
#df_rt = df_rt[df_rt["subj_idx"] == 0]
#print(df_rt)    
    
df_rt = df_rt[df_rt["rt"] > .1] # Remove trials less than 100ms
df_rt = df_rt[df_rt["rt"] < 5] # Remove trials greater than 1650ms

    
roitman_sample = Sample.from_pandas_dataframe(df_rt, rt_column_name="rt", correct_column_name="correct")

from pyddm import Drift
class DriftCoherenceRewBias(Drift):
    name = "Drift depends linearly on coherence, with a reward bias"
    required_parameters = ["driftRwd", "driftMatch"] # <-- Parameters we want to include in the model
    required_conditions = ["rwdType", "colMatch"] # <-- Task parameters ("conditions"). Should be the same name as in the sample.
    
    # We must always define the get_drift function, which is used to compute the instantaneous value of drift.
    def get_drift(self, conditions, **kwargs):
        rew_bias = self.driftMatch * conditions['colMatch']
        return self.driftRwd * conditions['rwdType'] + rew_bias

from pyddm import Model, Fittable
from pyddm.plot import model_gui
from pyddm.functions import fit_adjust_model, display_model
from pyddm.models import NoiseConstant, BoundConstant, OverlayChain, OverlayNonDecision, OverlayPoissonMixture
model_rs = Model(drift=DriftCoherenceRewBias(
                        driftRwd=Fittable(minval=0, maxval=1),
                        driftMatch=Fittable(minval=0, maxval=1)),
              dx=.01, dt=.01)

fit_model_rs = fit_adjust_model(sample=roitman_sample, model=model_rs, verbose=False)


display_model(fit_model_rs, conditions={"rwdType": [0, 1, 2], "colMatch": [0, 1]})

#model_gui(fit_model_rs, conditions={"rwdType": [0, 1, 2], "colMatch": [0, 1]})
#fit_model_rs = fit_adjust_model(sample=roitman_sample, model=model_rs, verbose=False)

#display_model(fit_model_rs)
    
#import pyddm.plot
#import matplotlib.pyplot as plt
#pyddm.plot.plot_fit_diagnostics(model=fit_model_rs, sample=roitman_sample)
#plt.savefig("roitman-fit.png")
#plt.show()



    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
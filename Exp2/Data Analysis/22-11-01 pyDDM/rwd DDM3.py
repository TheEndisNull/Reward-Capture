# -*- coding: utf-8 -*-
"""
Created on Tue Nov  1 20:48:27 2022

@author: Jonathan
"""

from pyddm import Bound, BoundCollapsingExponential
from pyddm import Bound
import matplotlib.pyplot as plt
import pyddm.plot
from pyddm.plot import model_gui
from pyddm.models import NoiseConstant, BoundConstant, OverlayChain, OverlayNonDecision, OverlayPoissonMixture
from pyddm.functions import fit_adjust_model, display_model
from pyddm import Model, Fittable
import pyddm as ddm
from pyddm import Sample
import pandas
with open("HDDM_data_2.csv", "r") as f:
    df_rt = pandas.read_csv(f)

print(df_rt)

df_sample = Sample.from_pandas_dataframe(
    df_rt, rt_column_name="rt", correct_column_name="correct")
# Model to fit drift rate


class DriftReward(ddm.model.Drift):
    name = "Drift Depends on reward condition"
    required_parameters = ["driftRwd", "driftPos"]
    required_conditions = ["rwdType", "colMatch"]

    def get_drift(self, conditions, **kwargs):
        position = self.driftPos * conditions["colMatch"]
        return self.driftRwd * conditions["rwdType"] + position


class BoundReward(ddm.model.Bound):
    name = "Boundary Depends on Reward Condition"
    required_parameters = ["driftRwd", "driftPos"]
    required_conditions = ["rwdType", "colMatch"]

    def get_bound(self, conditions, **kwargs):
        position = self.driftPos * conditions["colMatch"]
        return self.driftRwd * conditions["rwdType"] + position


# Model to apply parameters to data
model_df = Model(name="My data. Drift varies with reward",
                 drift=DriftReward(
                     driftRwd=Fittable(minval=0, maxval=20),
                     driftPos=Fittable(minval=0, maxval=20)),
                 overlay=OverlayChain(overlays=[OverlayNonDecision(nondectime=Fittable(minval=0, maxval=.4)),
                                                OverlayPoissonMixture(pmixturecoef=.02,
                                                                      rate=1)]),
                 dx=.01, dt=.01, T_dur=2.5
                 )

fit_model_rs = fit_adjust_model(
    sample=df_sample, model=model_df, verbose=False)
# seems to cause some errors, change pyddm.plot with another variable
display_model(fit_model_rs)
#
pyddm.plot.plot_fit_diagnostics(model=fit_model_rs, sample=df_sample)
# plt.savefig("roitman-fit.png")
plt.show()
#
pyddm.plot.model_gui(model=fit_model_rs, sample=df_sample)

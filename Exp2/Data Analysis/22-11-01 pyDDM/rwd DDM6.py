# -*- coding: utf-8 -*-
"""
Created on Tue Nov  1 20:48:27 2022

@author: Jonathan
"""

from pyddm import InitialCondition
import numpy as np
import matplotlib.pyplot as plt
import pyddm.plot
from pyddm.plot import model_gui
from pyddm.models import NoiseConstant, BoundConstant, OverlayChain, OverlayNonDecision, OverlayPoissonMixture
from pyddm.functions import fit_adjust_model, display_model
from pyddm.models import LossRobustBIC

from pyddm import Model, Fittable
import pyddm as ddm
from pyddm import Sample
import pandas
with open("HDDM_data4.csv", "r") as f:
    df_rt = pandas.read_csv(f)
df_rt = df_rt[df_rt["subID"] == 0]

print(df_rt)
df_sample = Sample.from_pandas_dataframe(
    df_rt, rt_column_name="rt", correct_column_name="correct")


class DriftReward(ddm.model.Drift):
    name = "Drift Depends on reward condition"
    required_parameters = ["driftRwd", "driftPos"]
    required_conditions = ["rwdType", "colMatch"]

    def get_drift(self, conditions, **kwargs):
        position = self.driftPos * conditions["colMatch"]
        return self.driftRwd * conditions["rwdType"] * position


class BoundCustom(ddm.model.Bound):
    name = "Boundary Depends on Reward Condition"
    required_parameters = ["boundRwd", "boundPos"]
    required_conditions = ["rwdType", "colMatch"]

    def get_bound(self, conditions, **kwargs):
        position = self.boundPos * conditions["colMatch"]
        return self.boundRwd * conditions["rwdType"] + position + .1


class ICPointSideBias(InitialCondition):
    name = "A starting point with a left or right bias."
    required_parameters = ["old_new"]
    required_conditions = ["tgtPos"]

    def get_IC(self, x, dx, conditions):
        start = -np.round(self.old_new/dx)
        # Positive bias for left choices, negative for right choices
        if not conditions['tgtPos']:
            start = -start
        shift_i = int(start + (len(x)-1)/2)
        assert shift_i >= 0 and shift_i < len(x), "Invalid initial conditions"
        pdf = np.zeros(len(x))
        pdf[shift_i] = 1.  # Initial condition at x=self.old_new.
        return pdf


# Model to apply parameters to data
model_df = Model(name="My data. Drift varies with reward",
                 drift=DriftReward(
                     driftRwd=Fittable(minval=-5, maxval=5),
                     driftPos=Fittable(minval=-5, maxval=5)),
                 #bound=BoundConstant(B=Fittable(minval=0, maxval=1.5)),
                 IC=ICPointSideBias(old_new=Fittable(minval=-1, maxval=1)),
                 #bound=BoundConstant(B=Fittable(minval=-4, maxval=4)),
                 # bound=BoundCustom(
                 #    boundRwd=Fittable(minval=0, maxval=20),
                 #    boundPos=Fittable(minval=0, maxval=20)),
                 overlay=OverlayChain(overlays=[OverlayNonDecision(nondectime=Fittable(minval=0, maxval=.4)),
                                                OverlayPoissonMixture(pmixturecoef=.02,
                                                                      rate=1)]),
                 dx=.01, dt=.01, T_dur=2.5)

fit_model_rs = fit_adjust_model(
    sample=df_sample, model=model_df, lossfunction=LossRobustBIC, verbose=False)
# seems to cause some errors, change pyddm.plot with another variable
display_model(fit_model_rs)
#
pyddm.plot.plot_fit_diagnostics(model=fit_model_rs, sample=df_sample)
# plt.savefig("roitman-fit.png")
plt.show()
##
pyddm.plot.model_gui(model=fit_model_rs, conditions={"rwdType": [
                     1, 2], "colMatch": [1, 2], "tgtPos": [0, 1]}, sample=df_sample)

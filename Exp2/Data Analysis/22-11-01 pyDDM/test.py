from pyddm import Bound, BoundCollapsingExponential
import matplotlib.pyplot as plt
import pyddm.plot
from pyddm.plot import model_gui
from pyddm.models import NoiseConstant, BoundConstant, OverlayChain, OverlayNonDecision, OverlayPoissonMixture
from pyddm.functions import fit_adjust_model, display_model
from pyddm import Model, Fittable
import pyddm as ddm
from pyddm import Sample
import pandas


class DriftReward(ddm.model.Drift):
    name = "Drift Depends on reward condition"
    required_parameters = ["driftRwd", "driftPos"]
    required_conditions = ["rwdType", "colMatch"]

    def get_drift(self, conditions, **kwargs):
        position = self.driftPos * conditions["colMatch"]
        return self.driftRwd * conditions["rwdType"] + position


class BoundReward(ddm.model.Bound):
    name = "Boundary Depends on Reward Condition"
    required_parameters = ["boundRwd"]
    required_conditions = ["rwdType"]
    def get_bound(self, conditions, **kwargs):
        return self.boundRwd * conditions["rwdType"]


model = Model(name="My data. Drift varies with reward",
              drift=DriftReward(
                  driftRwd=Fittable(minval=0, maxval=20),
                  driftPos=Fittable(minval=0, maxval=20)),
              bound=BoundReward(boundRwd=Fittable(minval=0, maxval=1.5)),
              dx=.01, dt=.01)
model_gui(model, conditions={"rwdType": [1,2,3], "colMatch": [1,2,3]})

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


import numpy as np
from pyddm import InitialCondition
class ICPointSideBias(InitialCondition):
    name = "A starting point with a left or right bias."
    required_parameters = ["old_new"]
    required_conditions = ["tgtPos"]
    def get_IC(self, x, dx, conditions):
        start = np.round(self.old_new/dx)
        # Positive bias for left choices, negative for right choices
        if not conditions['tgtPos']:
            start = -start
        shift_i = int(start + (len(x)-1)/2)
        assert shift_i >= 0 and shift_i < len(x), "Invalid initial conditions"
        pdf = np.zeros(len(x))
        pdf[shift_i] = 1. # Initial condition at x=self.old_new.
        return pdf


from pyddm import Model, Fittable
from pyddm.plot import model_gui
model = Model(IC=ICPointSideBias(old_new=Fittable(minval=0, maxval=1)),
              dx=.01, dt=.01)
model_gui(model, conditions={"tgtPos": [0, 1]})
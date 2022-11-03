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


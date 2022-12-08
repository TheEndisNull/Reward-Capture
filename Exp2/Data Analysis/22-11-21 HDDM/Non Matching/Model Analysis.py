# -*- coding: utf-8 -*-
"""
Created on Wed Nov 30 00:40:37 2022

@author: Jonathan
"""

import pandas as pd
import matplotlib.pyplot as plt
from patsy import dmatrix
import hddm

m = hddm.load('Within RwdType Drift Rate: Non-matching target and color')

v_1, v_2 = m.nodes_db.loc[["v_Intercept", "v_C(rwdType, Treatment(1))[T.2]"], 'node']

print("P_v(Win > Neutral) = ", (v_2.trace() > 0).mean())
#Treatment(x)[T.y], Treatment(x)[T.z] to indicate the remaining conditions

#versus having a continuous variable
m.plot_posteriors()
hddm.analyze.plot_posterior_nodes([v_1, v_2])
plt.xlabel('drift-rate')
plt.ylabel('Posterior probability')
plt.title('Group mean posteriors of within-subject drift-rate effects. Target item IS NOT colored')
plt.show()

# -*- coding: utf-8 -*-
"""
Created on Tue Nov 29 21:52:22 2022

@author: Jonathan
"""

import pandas as pd
import matplotlib.pyplot as plt
from patsy import dmatrix
import hddm

m = hddm.load('Within RwdType Drift Rate')

v_1, v_2 = m.nodes_db.loc[["v_Intercept", "v_C(rwdType, Treatment(1))[T.2]"], 'node']
print("P(LL > WL) = ", (0 > v_2.trace()).mean())

"""
v_0, v_1, v_2 = m.nodes_db.loc[["v_Intercept",
                                              "v_C(rwdType, Treatment(0))[T.1]",
                                              "v_C(rwdType, Treatment(0))[T.2]"], 'node']
#Treatment(x)[T.y], Treatment(x)[T.z] to indicate the remaining conditions

#versus having a continuous variable
hddm.analyze.plot_posterior_nodes([v_0, v_1, v_2])
plt.xlabel('drift-rate')
plt.ylabel('Posterior probability')
plt.title('Group mean posteriors of within-subject drift-rate effects.')
plt.show()

m = hddm.load('within drift-rate. All Matching')

v_1, v_2 = m.nodes_db.loc[["v_Intercept","v_C(rwdType, Treatment(1))[T.2]"], 'node']

#Treatment(x)[T.y], Treatment(x)[T.z] to indicate the remaining conditions

#versus having a continuous variable

hddm.analyze.plot_posterior_nodes([v_1, v_2])
plt.xlabel('drift-rate')
plt.ylabel('Posterior probability')
plt.title('Group mean posteriors of within-subject drift-rate effects.')
plt.show()
"""
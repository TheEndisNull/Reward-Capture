# -*- coding: utf-8 -*-
"""
Created on Wed Nov 30 00:40:37 2022

@author: Jonathan
"""

import matplotlib.pyplot as plt
import hddm

data = hddm.load_csv('HDDM HL v N Matching.csv')
data = hddm.utils.flip_errors(data)

fig = plt.figure()
ax = fig.add_subplot(111, xlabel='RT', ylabel='count', title='RT distributions')
for i, subj_data in data.groupby('subj_idx'):
    subj_data.rt.hist(bins=20, histtype='step', ax=ax)
plt.show()

m = hddm.HDDMRegressor(data, "v ~ C(colMatch, Treatment(0))")
#the use of C() indicates a categorical variable that will be dummy coded
#treatment(x) specifies which categorical variable is the "intercept" 
m.sample(2000, burn=20, dbname='traces.db', db='pickle')
m.save('Drift Rate HL v N Matching tgt&col')

v_1, v_2 = m.nodes_db.loc[["v_Intercept", "v_C(colMatch, Treatment(0))[T.2]"], 'node']

#Treatment(x)[T.y], Treatment(x)[T.z] to indicate the remaining conditions
print("P_v(High > Low) = ", (v_2.trace() > 0).mean())
#versus having a continuous variable
m.plot_posteriors()
hddm.analyze.plot_posterior_nodes([v_1, v_2])
plt.xlabel('drift-rate')
plt.ylabel('Posterior probability')
plt.title('Group mean posteriors of within-subject drift-rate effects. Colored items are targets')
plt.show()

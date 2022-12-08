# -*- coding: utf-8 -*-

import pandas as pd
import matplotlib.pyplot as plt
from patsy import dmatrix
import hddm

data = hddm.load_csv('./HDDM Matching.csv')
data = hddm.utils.flip_errors(data)

fig = plt.figure()
ax = fig.add_subplot(111, xlabel='RT', ylabel='count', title='RT distributions')
for i, subj_data in data.groupby('subj_idx'):
    subj_data.rt.hist(bins=20, histtype='step', ax=ax)
plt.show()
#print(dmatrix("C(rwdType)", data.head(10)))

m = hddm.HDDMRegressor(data, "v ~ C(rwdType, Treatment(0))")
#the use of C() indicates a categorical variable that will be dummy coded
#treatment(x) specifies which categorical variable is the "intercept" 
m.sample(10, burn=2, dbname='traces.db', db='pickle')
#NEED SEPERATE TRACES FOR EACH MODEL
m.save('Within RwdType Drift Rate: Matching target and color')

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

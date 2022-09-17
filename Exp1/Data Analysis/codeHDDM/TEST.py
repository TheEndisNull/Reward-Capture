import pandas as pd
import matplotlib.pyplot as plt

import hddm
data = hddm.load_csv('cavanagh_theta_nn.csv')

data = hddm.utils.flip_errors(data)

#from patsy import dmatrix
#print(dmatrix("C(stim, Treatment('WL'))", data.head(10)))
#
#m_within_subj = hddm.HDDMRegressor(data, "v ~ C(stim, Treatment('WL'))")
#
#m_within_subj.sample(1000, burn=10)
#
#v_WL, v_LL, v_WW = m_within_subj.nodes_db.ix[["v_Intercept",
#                                              "v_C(stim, Treatment('WL'))[T.LL]",
#                                              "v_C(stim, Treatment('WL'))[T.WW]"], 'node']
#hddm.analyze.plot_posterior_nodes([v_WL, v_LL, v_WW])
#plt.xlabel('drift-rate')
#plt.ylabel('Posterior probability')
#plt.title('Group mean posteriors of within-subject drift-rate effects.')
#plt.savefig('hddm_demo_fig_07.pdf')

# fig = plt.figure()
# ax = fig.add_subplot(111, xlabel='RT', ylabel='count', title='RT distributions')
# for i, subj_data in data.groupby('subj_idx'):
#     subj_data.rt.hist(bins=20, histtype='step', ax=ax)
# plt.savefig('hddm_demo_fig_00.pdf')
# m = hddm.HDDM(data)
# m.find_starting_values()
# m.sample(2000, burn=20)
# stats = m.gen_stats()
# print([stats.index.isin(['a', 'a_std', 'a_subj.0', 'a_subj.1', 'a_subj.2' ,'a_subj.3'])])
# print(stats)
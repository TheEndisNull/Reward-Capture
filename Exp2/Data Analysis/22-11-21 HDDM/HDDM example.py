# -*- coding: utf-8 -*-
"""
Created on Mon Nov 21 13:08:03 2022

@author: Jonathan
"""
import pandas as pd
import matplotlib.pyplot as plt
from patsy import dmatrix
import hddm

data = hddm.load_csv('./cavanagh_theta_nn.csv')
data = hddm.utils.flip_errors(data)

fig = plt.figure()
ax = fig.add_subplot(111, xlabel='RT', ylabel='count', title='RT distributions')
for i, subj_data in data.groupby('subj_idx'):
    subj_data.rt.hist(bins=20, histtype='step', ax=ax)
#plt.show()

m_stim = hddm.HDDM(data, depends_on={'v': 'stim'})
m_stim.find_starting_values()
m_stim.sample(20, burn=1)
m_stim.plot_posteriors()
m_stim.plot_posterior_predictive(figsize=(14, 10))

v_WW, v_LL, v_WL = m_stim.nodes_db.node[['v(WW)', 'v(LL)', 'v(WL)']]
hddm.analyze.plot_posterior_nodes([v_WW, v_LL, v_WL])
plt.xlabel('drift-rate')
plt.ylabel('Posterior probability')
plt.title('Posterior of drift-rate group means')
plt.show()

#m_stim = hddm.HDDM(data, depends_on={'v': 'stim'})
#m_stim.find_starting_values()
#m_stim.sample(10, burn=2)
#v_WW, v_LL, v_WL = m_stim.nodes_db.node[['v(WW)', 'v(LL)', 'v(WL)']]
#hddm.analyze.plot_posterior_nodes([v_WW, v_LL, v_WL])
#plt.xlabel('drift-rate')
#plt.ylabel('Posterior probability')
#plt.title('Posterior of drift-rate group means')
#plt.show() 
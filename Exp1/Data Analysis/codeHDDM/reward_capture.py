


import pandas as pd
import matplotlib.pyplot as plt
import hddm

# Load data from csv file into a NumPy structured array
data = hddm.load_csv('reward_capture.csv')

data = hddm.utils.flip_errors(data)
print(data.head(20))
fig = plt.figure()
ax = fig.add_subplot(111, xlabel='RT', ylabel='count', title='RT distributions')
for i, subj_data in data.groupby('subject'):
    subj_data.rt.hist(bins=20, histtype='step', ax=ax)
plt.savefig('rc.pdf')

m = hddm.HDDM(data)
# start drawing 7000 samples and discarding 5000 as burn-in
m.sample(2000, burn=20)
stats = m.gen_stats()
print(stats[stats.index.isin(['a', 'a_std', 'a_subj.0', 'a_subj.1'])])
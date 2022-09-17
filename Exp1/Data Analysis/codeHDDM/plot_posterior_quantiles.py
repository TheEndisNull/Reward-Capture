#!/usr/bin/python
import hddm
import pylab as pl

m = hddm.utils.create_test_model(samples=1000, burn=500, subjs=12, size=200)
m.plot_posterior_quantiles()

pl.show()

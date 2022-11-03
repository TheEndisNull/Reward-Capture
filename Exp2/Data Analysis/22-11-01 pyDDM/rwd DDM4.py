# -*- coding: utf-8 -*-
"""
Created on Tue Nov  1 20:48:27 2022

@author: Jonathan
"""

if __name__ == '__main__':
    from pyddm import set_N_cpus
    set_N_cpus(6)
    from rwd_DDM4importTest import DriftReward, BoundReward
    import pandas
    from pyddm import Sample
    import pyddm as ddm
    from pyddm import Model, Fittable
    from pyddm.functions import fit_adjust_model, display_model
    from pyddm.models import NoiseConstant, BoundConstant, OverlayChain, OverlayNonDecision, OverlayPoissonMixture
    from pyddm.plot import model_gui
    import pyddm.plot
    import matplotlib.pyplot as plt


    from pyddm import Bound, BoundCollapsingExponential
    from pyddm import Bound

    with open("HDDM_data_2.csv", "r") as f:
        df_rt = pandas.read_csv(f)

    print(df_rt)

    df_sample = Sample.from_pandas_dataframe(
        df_rt, rt_column_name="rt", correct_column_name="correct")
    # Model to fit drift rate


    # Model to apply parameters to data
    model_df = Model(name="My data. Drift varies with reward",
                     drift=DriftReward(
                         driftRwd=Fittable(minval=0, maxval=20),
                         driftPos=Fittable(minval=0, maxval=20)),
                     overlay=OverlayChain(overlays=[OverlayNonDecision(nondectime=Fittable(minval=0, maxval=.4)),
                                                    OverlayPoissonMixture(pmixturecoef=.02,
                                                                          rate=1)]),
                     dx=.01, dt=.01, T_dur=2.5
                     )

    fit_model_rs = fit_adjust_model(
        sample=df_sample, model=model_df, verbose=False)
    # seems to cause some errors, change pyddm.plot with another variable
    display_model(fit_model_rs)
    #
    pyddm.plot.plot_fit_diagnostics(model=fit_model_rs, sample=df_sample)
    # plt.savefig("roitman-fit.png")
    plt.show()
    #
    pyddm.plot.model_gui(model=fit_model_rs, sample=df_sample)

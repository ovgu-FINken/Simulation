import plotly.plotly as py
import plotly.graph_objs as go
import plotly.figure_factory as FF
from os.path import expanduser

import numpy as np
import pandas as pd
home = expanduser("~")
df = pd.read_csv('straight-y.csv')

sample_data_table = FF.create_table(df.head())
py.iplot(sample_data_table, filename='sample-data-table')

trace = go.Scatter(x = df['AAPL_x'], y = df['AAPL_y'],
                  name='Share Prices (in USD)')
layout = go.Layout(title='Apple Share Prices over time (2014)',
                   plot_bgcolor='rgb(230, 230,230)', 
                   showlegend=True)
fig = go.Figure(data=[trace], layout=layout)

py.iplot(fig, filename='apple-stock-prices')
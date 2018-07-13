#!/bin/bash

virtualenv --python=python2.7 vEnv
source vEnv/bin/activate
pip install numpy-quaternion
pip install ipykernel
pip install matplotlib
python -m ipykernel install --user --name testenv --display-name "Python2.7 Finken Sim Analysis"

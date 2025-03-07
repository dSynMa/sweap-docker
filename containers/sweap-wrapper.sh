#!/bin/bash

sweap() (
cd /sweap
PYTHONPATH=/sweap/src python3 main.py $@
)

sweap $@

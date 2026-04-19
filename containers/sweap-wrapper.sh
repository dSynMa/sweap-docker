#!/bin/bash

sweap() (
cd /sweap
PYTHONPATH=/sweap/src python3 src/main.py $@
)

sweap $@

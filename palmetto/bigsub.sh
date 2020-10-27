#!/bin/bash
qsub -I -l select=1:ncpus=8:mem=120gb:ngpus=1:gpu_model=p100,walltime=32:00:00


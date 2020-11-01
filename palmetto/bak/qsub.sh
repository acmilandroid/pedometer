#!/bin/bash
qsub -I -l select=1:ncpus=8:mem=100gb:ngpus=1:gpu_model=p100,walltime=8:00:00


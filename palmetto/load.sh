#!/bin/bash
module load cuda/10.2.89-gcc/8.3.1 cudnn/8.0.0.180-10.2-linux-x64-gcc/8.3.1 anaconda3/2019.10-gcc/8.3.1
CONDA_BASE=$(conda info --base)
source $CONDA_BASE/etc/profile.d/conda.sh
source activate tf_env

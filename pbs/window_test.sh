#/bin/bash
#PBS -N basill_window_test
#PBS -l select=1:ncpus=16:mem=125gb:ngpus=1:gpu_model=p100
#PBS -l walltime=72:00:00
#PBS -e /home/basill/pedometer/pbs/job_output
#PBS -o /home/basill/pedometer/pbs/job_output

module load cuda/10.2.89-gcc/8.3.1 cudnn/8.0.0.180-10.2-linux-x64-gcc/8.3.1 anaconda3/2019.10-gcc/8.3.1

source activate tf_env
cd
cd pedometer/window_test/

./window_test.sh ../PedometerData/ 60 90 15 1

#!/bin/sh

DRUN="sudo docker run -it --network=host --device=/dev/kfd --device=/dev/dri --ipc=host --shm-size 32G --group-add video --cap-add=SYS_PTRACE --security-opt seccomp=unconfined -v $HOME/dockerx:/workspace"

$DRUN --name rocblas_tuning2 tensile:rocm3.5

#!/bin/sh

set -ex

DEVICE=${1:-0}
OUT=${2:-res.txt}
CMD=src/rocBLAS/build/release/clients/staging/rocblas-bench

# pinclock
#/opt/rocm/bin/rocm-smi -d $DEVICE --setsclk 8

#$CMD -f gemm -r s --transposeA N --transposeB T -m 4096 -n 4096 -k 4096 --lda 4096 --ldb 4096 --ldc 4096 --device $DEVICE | tail -1 | awk -F "," '{print $(NF-1), $NF}' >> $OUT
$CMD -f gemm -r s --transposeA N --transposeB T -m 4096 -n 4096 -k 4096 --lda 4096 --ldb 4096 --ldc 4096 --device $DEVICE > $OUT

echo "done."
echo "output: $OUT"



#!/bin/sh

set -ex

DEVICE=${1:-0}
OUT=${2:-res.txt}
CMD=src/rocBLAS/build/release/clients/staging/rocblas-bench

# pinclock
/opt/rocm/bin/rocm-smi -d $DEVICE --setsclk 8

$CMD -f gemm_strided_batched -r h --transposeA N --transposeB T -m 64 -n 128 -k 128 --lda 64 --stride_a 8192 --ldb 128 --stride_b 16384 --ldc 64 --stride_c 8192 --batch 1024 --device $DEVICE | tail -1 | awk -F "," '{print $(NF-1), $NF}' > $OUT

$CMD -f gemm_strided_batched -r h --transposeA T --transposeB N -m 128 -n 128 -k 64 --lda 64 --stride_a 8192 --ldb 64 --stride_b 8192 --ldc 128 --stride_c 16384 --batch 1024 --device $DEVICE | tail -1 | awk -F "," '{print $(NF-1), $NF}' >> $OUT

$CMD -f gemm_strided_batched -r h --transposeA N --transposeB N -m 64 -n 128 -k 128 --lda 64 --stride_a 8192 --ldb 128 --stride_b 16384 --ldc 64 --stride_c 8192 --batch 1024 --device $DEVICE | tail -1 | awk -F "," '{print $(NF-1), $NF}' >> $OUT

$CMD -f gemm -r h --transposeA N --transposeB T -m 1024 -n 1024 -k 8192 --lda 1024 --ldb 1024 --ldc 1024 --device $DEVICE | tail -1 | awk -F "," '{print $(NF-1), $NF}' >> $OUT

$CMD -f gemm -r h --transposeA T --transposeB N -m 1024 -n 8192 -k 4096 --lda 4096 --ldb 4096 --ldc 1024 --device $DEVICE | tail -1 | awk -F "," '{print $(NF-1), $NF}' >> $OUT

$CMD -f gemm_strided_batched -r s --transposeA N --transposeB T -m 64 -n 128 -k 128 --lda 64 --stride_a 8192 --ldb 128 --stride_b 16384 --ldc 64 --stride_c 8192 --batch 512 --device $DEVICE | tail -1 | awk -F "," '{print $(NF-1), $NF}' >> $OUT

$CMD -f gemm_strided_batched -r s --transposeA T --transposeB N -m 128 -n 128 -k 64 --lda 64 --stride_a 8192 --ldb 64 --stride_b 8192 --ldc 128 --stride_c 16384 --batch 512 --device $DEVICE | tail -1 | awk -F "," '{print $(NF-1), $NF}' >> $OUT

$CMD -f gemm_strided_batched -r s --transposeA N --transposeB N -m 64 -n 128 -k 128 --lda 64 --stride_a 8192 --ldb 128 --stride_b 16384 --ldc 64 --stride_c 8192 --batch 512 --device $DEVICE | tail -1 | awk -F "," '{print $(NF-1), $NF}' >> $OUT

$CMD -f gemm -r s --transposeA N --transposeB T -m 1024 -n 1024 -k 4096 --lda 1024 --ldb 1024 --ldc 1024 --device $DEVICE | tail -1 | awk -F "," '{print $(NF-1), $NF}' >> $OUT

echo "done."
echo "output: $OUT"



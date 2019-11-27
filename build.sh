#!/bin/sh

set -ex

istart=$(date +%s)

TENSILE_DIR=src/Tensile
DEVICE=${1:-0}
OUT_DIR=${2:-out}
CONF_DIR=$OUT_DIR/configs
BUILD_DIR=$OUT_DIR/build

rm -rf ${OUT_DIR}
mkdir -p $CONF_DIR
mkdir -p $BUILD_DIR

# download tensile
if [ ! -d "$TENSILE_DIR" ]; then
	git clone -b msra-tuning http://gitlab1.amd.com/antc/Tensile.git $TENSILE_DIR
fi

# copy & setup configs
CONFIGS=`find $TENSILE_DIR/msra_tuning_config -name config.yaml`

for o in $CONFIGS
do
	DIR_PATH=${o%/*}
	SUBDIR_NAME=${DIR_PATH##*/}
	CONF=$CONF_DIR/${SUBDIR_NAME}_config.yaml
	cp $o $CONF -v
	sed -i "s/^\(  Device:\).*/\1 $DEVICE/g" $CONF
	sed -i "s/^\(  PinClocks:\).*/\1 False/g" $CONF
done

# pinclock
/opt/rocm/bin/rocm-smi -d $DEVICE --setsclk 5

# tensile training
CONFIGS=`ls $CONF_DIR/*.yaml`

for o in $CONFIGS
do
	_PATH=${o%_*}
	OUT_PATH=$BUILD_DIR/${_PATH##*/}
	$TENSILE_DIR/Tensile/bin/Tensile $o $OUT_PATH
done

# merge logic
ROCBLAS_DIR=src/rocBLAS
MERGE_TOOL=$TENSILE_DIR/Tensile/Utilities/merge_rocblas_yaml_files.py
ARCHIVE_DIR=$ROCBLAS_DIR/library/src/blas3/Tensile/Logic/archive
ASM_FULL_DIR=$ROCBLAS_DIR/library/src/blas3/Tensile/Logic/asm_full
WORK_DIR=$BUILD_DIR/workdir
BASE_DIR=$WORK_DIR/base
NEW_DIR=$WORK_DIR/new
MERGED_DIR=$WORK_DIR/merged
mkdir -p $BASE_DIR
mkdir -p $NEW_DIR
mkdir -p $MERGED_DIR

if [ ! -d "$ROCBLAS_DIR" ]; then
	git clone https://github.com/ROCmSoftwarePlatform/rocBLAS.git $ROCBLAS_DIR
fi

YAMLS=`find $BUILD_DIR/*/3_LibraryLogic -name *.yaml`

for o in $YAMLS
do
	FILE_NAME=${o##*/}
	BASE_FILE=$ARCHIVE_DIR/$FILE_NAME
	if [ ! -f "$BASE_FILE" ]; then
		BASE_FILE=$ASM_FULL_DIR/$FILE_NAME
	fi
	cp $o $NEW_DIR -v
	cp $BASE_FILE $BASE_DIR -v
done

python3 $MERGE_TOOL $BASE_DIR $NEW_DIR $MERGED_DIR

# massage logic
MASSAGE_TOOL=$ROCBLAS_DIR/library/src/blas3/Tensile/Logic/archive/massage.py
MASSAGED_DIR=$WORK_DIR/massaged
mkdir -p $MASSAGED_DIR

python3 $MASSAGE_TOOL $MERGED_DIR $MASSAGED_DIR

# build rocBLAS
cd $ROCBLAS_DIR && ./install.sh -dc && cd -

iend=$(date +%s)

echo ""
echo ""
echo "Build done."
echo "The total time: $(( iend - istart )) seconds."


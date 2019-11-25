#!/bin/sh

set -ex

TENSILE_DIR=src/Tensile
OUT_DIR=${1:-out}
CONF_DIR=$OUT_DIR/configs
BUILD_DIR=$OUT_DIR/build
DEVICE=0

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

# tensile training
CONFIGS=`ls $CONF_DIR/*.yaml`

for o in $CONFIGS
do
	_PATH=${o%_*}
	OUT_PATH=$BUILD_DIR/${_PATH##*/}
	$TENSILE_DIR/Tensile/bin/Tensile $o $OUT_PATH
done

exit 0

# merge logic
ROCBLAS_DIR=src/rocBLAS
ARCHIVE_DIR=$ROCBLAS_DIR/library/src/blas3/Tensile/Logic/archive
ASM_FULL_DIR=$ROCBLAS_DIR/library/src/blas3/Tensile/Logic/asm_full
WORK_DIR=$BUILD_DIR/workdir
BASE_DIR=$WORK_DIR/base
NEW_DIR=$WORK_DIR/new
MERGED_DIR=$WORK_DIR/merged
MASSAGED_DIR=$WORK_DIR/massaged
mkdir -p $BASE_DIR
mkdir -p $NEW_DIR
mkdir -p $MERGED_DIR
mkdir -p $MASSAGED_DIR

if [ ! -d "$ROCBLAS_DIR" ]; then
	git clone https://github.com/ROCmSoftwarePlatform/rocBLAS.git $ROCBLAS_DIR
fi

YAMLS=`find $BUILD_DIR/*/3_LibraryLogic -name *.yaml`

for o in $YAMLS
do
	FILE_NAME=${o##*/}
	BASE_FILE=`find $ARCHIVE_DIR -name $FILE_NAME`
	if [ "$BASE_FILE" -eq "" ]; then
		BASE_FILE=`find $ASM_FULL_DIR -name $FILE_NAME`
	fi
	cp $o $NEW_DIR -v
	cp $BASE_FILE $BASE_DIR -v
done









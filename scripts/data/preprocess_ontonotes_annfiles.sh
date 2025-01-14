#!/usr/bin/env bash 


# author: xiaoy li 
# description:
# generate annotated CONLL-2012 coreference resolution datasets from the official released OntoNotes 5.0 dataset.  
# 
######################################
# NOTICE:
######################################
# the scripts only work with python 2.
# if you want to run with python 3, please refer to https://github.com/huggingface/neuralcoref/blob/master/neuralcoref/train/training.md#get-the-data
# Thanks to their amazing job ! 
# 
# Reference: 
# https://github.com/huggingface/neuralcoref/blob/master/neuralcoref/train/training.md#get-the-data
# https://github.com/mandarjoshi90/coref
# 


path_to_ontonotes_directory=$1
path_to_save_processed_data_directory=$2
language=$3


dlx() {
  cp $1/$2 $path_to_save_processed_data_directory 
  tar -xvzf $path_to_save_processed_data_directory/$2 -C $path_to_save_processed_data_directory
  rm $path_to_save_processed_data_directory/$2
}


conll_url=conll2012
dlx $conll_url conll-2012-train.v4.tar.gz
dlx $conll_url conll-2012-development.v4.tar.gz
dlx $conll_url/test conll-2012-test-key.tar.gz
dlx $conll_url/test conll-2012-test-official.v9.tar.gz

find . -type d -name "arabic" -exec rm -rf "{}" \;
find . -type d -name "chinese" -exec rm -rf "{}" \;

dlx $conll_url conll-2012-scripts.v3.tar.gz
dlx $conll_url reference-coreference-scorers.v8.01.tar.gz

virtualenv -p python2 sloppyenv
source sloppyenv/bin/activate

bash $path_to_save_processed_data_directory/conll-2012/v3/scripts/skeleton2conll.sh -D $path_to_ontonotes_directory/data/files/data $path_to_save_processed_data_directory/conll-2012

function compile_partition() {
    rm -f $2.$5.$3$4
    cat $path_to_save_processed_data_directory/conll-2012/$3/data/$1/data/$5/annotations/*/*/*/*.$3$4 >> $path_to_save_processed_data_directory/$2.$5.$3$4
}

function compile_language() {
    compile_partition development dev v4 _gold_conll $1
    compile_partition train train v4 _gold_conll $1
    compile_partition test test v4 _gold_conll $1
}

compile_language $language

deactivate
rm -rf sloopyenv


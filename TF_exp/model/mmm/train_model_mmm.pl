#!/usr/bin/perl

## train model

$path1="/state3/hyangl/TF_model/data/train_test/mmm/"; # PARAMETER: change the directory names F,G,H,I
$path2="/state3/hyangl/TF_model/model/mmm/"; # PARAMETER: F,G,H,I
$tf_list="/state3/hyangl/TF_model/data/index/tf_list.txt"; # PARAMETER

system "mkdir ${path2}";

open FILE, "$tf_list" or die;
while ($tf=<FILE>){
    chomp $tf;
    @tmp=glob "/home/gyuanfan/2017/TF/data/raw/ChIPseq/labels/${tf}*"; # collect names of all cell lines for target tf
    open TMP, "$tmp[0]" or die;
    $line=<TMP>;
    chomp $line;
    @list= split "\t", $line;
    shift @list;
    shift @list;
    shift @list;
    close TMP;

    $num_cell=scalar(@list);
    $i=0;
    while($i<$num_cell){
        $train=$list[$i];
        if($i eq $num_cell-1){
            $test=$list[0];
        }else{
            $test=$list[$i+1];
        }
        $i++;

        system "cp ${path1}${tf}/${tf}.${train}.set1 train.dat"; # train on chr set 1 of cell_train
        system "cp ${path1}${tf}/${tf}.${test}.set2 test.dat";   # test on chr set 2 of cell_test
        system "/home/hyangl/software/xgboost/xgboost xgtree.conf";
        @all_config=glob "*model";
        system "cut -f 1 -d ' ' test.dat>test_gs.dat";
        foreach $model (@all_config){
            system "/home/hyangl/software/xgboost/xgboost xgtree.conf task=pred model_in=$model";
            system "python evaluation.py";
            system "mv auc.txt ${model}.auc.txt";
            system "mv auprc.txt ${model}.auprc.txt";
        }
        system "mkdir ${path2}${tf}_${train}_${test}_set1_eva";
        system "mv *model ${path2}${tf}_${train}_${test}_set1_eva/";
        system "mv *auc.txt ${path2}${tf}_${train}_${test}_set1_eva/";
        system "mv *auprc.txt ${path2}${tf}_${train}_${test}_set1_eva/";

        system "cp ${path1}${tf}/${tf}.${train}.set2 train.dat"; # train on chr set 2 of cell_train
        system "cp ${path1}${tf}/${tf}.${test}.set1 test.dat";   # test on chr set 1 of cell_test
        system "/home/hyangl/software/xgboost/xgboost xgtree.conf";
        @all_config=glob "*model";
        system "cut -f 1 -d ' ' test.dat>test_gs.dat";
        foreach $model (@all_config){
            system "/home/hyangl/software/xgboost/xgboost xgtree.conf task=pred model_in=$model";
            system "python evaluation.py";
            system "mv auc.txt ${model}.auc.txt";
            system "mv auprc.txt ${model}.auprc.txt";
        }
        system "mkdir ${path2}${tf}_${train}_${test}_set2_eva";
        system "mv *model ${path2}${tf}_${train}_${test}_set2_eva/";
        system "mv *auc.txt ${path2}${tf}_${train}_${test}_set2_eva/";
        system "mv *auprc.txt ${path2}${tf}_${train}_${test}_set2_eva/";
    }
}


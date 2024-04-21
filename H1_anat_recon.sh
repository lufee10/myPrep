#!/bin/bash

# 本脚本对单个被试的结构MRI进行分割（recon-all）,并将结果转化为AFNI兼容的形式（@SUMA_Make_Spec_FS）。

# 示例如下：($path0是H1_anat_recon.sh的储存路径，$path1/anat是某个被试的结构MRI的储存路径, "sub01"是被试ID)
#         path0/1_anat_recon.sh path1/anat sub01


# ！！！本脚本中使用的CPU数量应当根据机器配置进行更改！！！



cd $1
sub=$2
anat=$sub"_anat.nii.gz"
CPUs=12

recon-all   -all                      \
            -3T                       \
            -sd .                     \
            -subjid $sub              \
            -i $anat                  \
            -parallel                 \
            -openmp $CPUs                

@SUMA_Make_Spec_FS -fs_setup          \
                    -NIFTI            \
                    -sid $sub         \
                    -fspath ./$sub
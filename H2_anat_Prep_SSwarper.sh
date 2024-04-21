#!/bin/bash

# 本脚本对单个被试的结构MRI进行预处理，预处理步骤包括：
#           (1) Correcting B1 field (N4BiasFieldCorrection);
#           (2) Denoising Image (DenoiseImage, ImageMath);
#           (3) Skull Stripping (antsBrainExtraction.sh);
#           (4) Registrating the anatomical image towards template (antsRegistrationSyN.sh);
#           (5) Generating pictures for QC 
#                       (@snapshot_volreg, @djunct_edgy_align_check, @chauffeur_afni, 2dcat).
# 该脚本的参考文献是 ”A triple-network organization for the mouse brain“。
# 该脚本的参考代码来源于https://github.com/grandjeanlab/MouseMRIPrep/blob/master/prep/anat_norm.sh

# 示例如下：($path0是H2_anat_Prep_SSwarper.sh的储存路径，$path1/anat是某个被试的结构MRI的储存路径, "sub01"是被试ID)
#         path0/H2_anat_Prep_SSwarper.sh path1/anat sub01
# 本脚本使用Oasis模版剥头骨（详见$template_withSkull, $pbMap, $Mask），并将结构MRI配准到SSwarper模版（详见$template）。

# ！！！本脚本中$template, $template_withSkull, $pbMap, $Mask的储存路径需要根据实际情况进行更新！！！
# ！！！本脚本中使用的CPU数量应当根据机器配置进行更改！！！



# -----------------------------------Settings------------------------------------------

cd $1
sub=$2
anat=$sub"_anat.nii.gz"
# SSwarper模版。
template="/Users/yiling/Documents/Data/Atlas/SSwarper/template.nii.gz"
# Oasis模版。
template_withSkull="/Users/yiling/Documents/Data/Atlas/Oasis_ANTs/T_template0.nii.gz"
pbMap="/Users/yiling/Documents/Data/Atlas/Oasis_ANTs/T_template0_BrainCerebellumProbabilityMask.nii.gz"
Mask="/Users/yiling/Documents/Data/Atlas/Oasis_ANTs/T_template0_BrainCerebellumRegistrationMask.nii.gz"
# CPUs数量
CPUs=12
# ------------------------------------------------------------------------------------
# (1) Correcting B1 field.
# ::: $anat ---> "N4_"$anat
N4BiasFieldCorrection -d 3 \
                      -i $anat \
                      -o "N4_"$anat


# (2) Denoising Image.
# ::: "N4_"$anat ---> "dn+N4_"$anat ---> "Trunc+dn+N4_"$anat
DenoiseImage -d 3 \
             -i "N4_"$anat \
             -o "dn+N4_"$anat

ImageMath 3 "Trunc+dn+N4_"$anat TruncateImageIntensity "dn+N4_"$anat 0.05 0.999


# (3) Skull Stripping. 
# ::: "Trunc+dn+N4_"$anat ---> <1> "ssBrain+Trunc+dn+N4_"$anat
#                              <2> "ssMask+Trunc+dn+N4_"$anat
#                              <3> "ss+Trunc+dn+N4_BrainExtractionPrior0GenericAffine.mat"

antsBrainExtraction.sh -d 3 -a "Trunc+dn+N4_"$anat -e $template_withSkull -m $pbMap -f $Mask \
                       -o "ss+Trunc+dn+N4_"
# 删除这个中间过程中产生的多余文件夹。
rm -rf "ss+Trunc+dn+N4_"
# 更改文件名称使之更加易懂。
mv "ss+Trunc+dn+N4_BrainExtractionBrain.nii.gz" "ssBrain+Trunc+dn+N4_"$anat
mv "ss+Trunc+dn+N4_BrainExtractionMask.nii.gz" "ssMask+Trunc+dn+N4_"$anat

# (4) Registrating towards template
# ::: "ssBrain+Trunc+dn+N4_"$anat ---> "rega2t_*"
antsRegistrationSyN.sh -d 3 \
                       -f $template \
                       -m "ssBrain+Trunc+dn+N4_"$anat \
                       -o "rega2t_" \
                       -n $CPUs

#  Change the space of "rega2t_Warped.nii.gz" for the convenience of visualization.
3drefit -space TLRC "rega2t_Warped.nii.gz" 


# (4) QC.
# ::: ---> <1> "AM"$sub".jpg", "MA"$sub".jpg"
# :::      <2> "QC_anatQQ".$sub.jpg, "QC_anatSS".$sub.jpg
#     A. @snapshot_volreg
@snapshot_volreg "rega2t_Warped.nii.gz" $template "AM"$sub".jpg"
@snapshot_volreg $template "rega2t_Warped.nii.gz" "MA"$sub".jpg"

#     B. @djunct_edgy_align_check & 2dcat
@djunct_edgy_align_check -ulay "rega2t_Warped.nii.gz" -olay $template \
                         -montx 9 -monty 1 \
                         -box_focus_slices "rega2t_Warped.nii.gz" \
                         -label_mode 1 \
                         -prefix "QC_anatQQ".$sub

lcol=( 0 255 0 )
2dcat -gap 5 -gap_col ${lcol[*]} \
      -nx 1 -ny 3 \
      -prefix "QC_anatQQ".$sub.jpg \
      "QC_anatQQ".*.jpg
#     删除中间过程文件。
rm "QC_anatQQ".$sub."sag".jpg "QC_anatQQ".$sub."cor".jpg "QC_anatQQ".$sub."axi".jpg

#     C. @chauffeur_afni & 2dcat
@chauffeur_afni -ulay "Trunc+dn+N4_"$anat -olay "ssMask+Trunc+dn+N4_"$anat \
                -montx 9 -monty 1 \
                -box_focus_slices "ssMask+Trunc+dn+N4_"$anat \
                -label_mode 1 -label_size 4 \
                -cbar "ROI_i128" -opacity 4 \
                -prefix "QC_anatSS".$sub -save_ftype JPEG

2dcat -gap 5 -gap_col ${lcol[*]} \
      -nx 1 -ny 3 \
      -prefix "QC_anatSS".$sub.jpg \
      "QC_anatSS".$sub.*.jpg
#     删除中间过程文件。
rm "QC_anatSS".$sub."sag".jpg "QC_anatSS".$sub."cor".jpg "QC_anatSS".$sub."axi".jpg      
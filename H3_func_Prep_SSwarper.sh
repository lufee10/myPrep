#!/bin/bash

# 本脚本对单个被试的功能MRI进行预处理，该脚本参考代码来源于Example 11
# https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/programs/afni_proc.py_sphx.html#example-11-resting-state-analysis-now-even-more-modern
# 本脚本的参考文献是：Untangling the relatedness among correlations, Part II: Inter-subject correlation group analysis through linear mixed-effects modeling


# 示例如下：($path0是H3_func_Prep_SSwarper.sh的储存路径，$path1/func是某个被试的功能MRI的储存路径, "sub01"是被试ID)
#         path0/H3_func_Prep_SSwarper.sh path1/func sub01



# ！！！本脚本使用前需要先对结构MRI进行 <1>预处理，剥头骨，配准（H1_anat_Prep_SSwarper.sh, affine_ANTs2AFNI.py）; 
#                                 <2>分割（recon-all）.     ！！！



# -----------------------------------Settings------------------------------------------

cd $1
sub=$2
anat=$sub"_anat.nii.gz"

ss_anat=../anat/"ssBrain+Trunc+dn+N4_"$anat
U_anat=../anat/"Trunc+dn+N4_"$anat
func=$sub"_func.nii.gz"
FSdir=../anat/$sub/SUMA
anatQQ=../anat/rega2t_Warped.nii.gz
aff12=../anat/aff12.1D
# 另存rega2t_1Warp.nii.gz为rega2t_WARP.nii.gz以适应AFNI的需求。
cp ../anat/rega2t_1Warp.nii.gz ../anat/rega2t_WARP.nii.gz
anatQQ_WARP=../anat/rega2t_WARP.nii.gz

# ------------------------------------------------------------------------------------

afni_proc.py -subj_id $sub                                                         \
        -blocks despike tshift align tlrc volreg blur mask scale regress           \
        -radial_correlate_blocks tcat volreg                                       \
        -copy_anat $ss_anat                                                        \
        -anat_has_skull no                                                         \
        -anat_follower anat_w_skull anat $U_anat                                   \
        -anat_follower_ROI aaseg  anat $FSdir/aparc.a2009s+aseg_REN_all.nii.gz     \
        -anat_follower_ROI aeseg  epi  $FSdir/aparc.a2009s+aseg_REN_all.nii.gz     \
        -anat_follower_ROI FSvent epi  $FSdir/fs_ap_latvent.nii.gz                 \
        -anat_follower_ROI FSWe   epi  $FSdir/fs_ap_wm.nii.gz                      \
        -anat_follower_erode FSvent FSWe                                           \
        -dsets $func                                                               \
        -tcat_remove_first_trs 5                                                   \
        -align_opts_aea -cost lpc+ZZ -giant_move -check_flip                       \
        -align_unifize_epi local                                 \
        -tlrc_base MNI152_2009_template_SSW.nii.gz                                                       \
        -tlrc_NL_warp                                                              \
        -tlrc_NL_warped_dsets                                                      \
                $anatQQ                                                            \
                $aff12                                                             \
                $anatQQ_WARP                                                       \
        -volreg_align_to MIN_OUTLIER                                               \
        -volreg_align_e2a                                                          \
        -volreg_tlrc_warp                                                          \
        -volreg_warp_dxyz 3                                                        \
        -blur_size 6.0                                                             \
        -mask_epi_anat yes                                                         \
        -regress_bandpass 0.01 0.1                                                 \
        -regress_ROI_PC FSvent 3                                                   \
        -regress_ROI_PC_per_run FSvent                                             \
        -regress_make_corr_vols aeseg FSvent                                       \
        -regress_anaticor_fast                                                     \
        -regress_anaticor_label FSWe                                               \
        -regress_motion_per_run                                                    \
        -regress_censor_motion 0.2                                                 \
        -regress_censor_outliers 0.05                                              \
        -regress_apply_mot_types demean deriv                                      \
        -regress_est_blur_epits                                                    \
        -regress_est_blur_errts                                                    \
        -regress_run_clustsim no                                                   \
        -html_review_style pythonic                                                \
        -execute



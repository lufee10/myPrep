# myPrep

## Overview

myPrep aims to combine the strengths of open-source MRI processing software—FreeSurfer, ANTs, AFNI, and MRtrix—to build a flexible pipeline for multimodal MRI preprocessing with explicit control over individual processing steps and parameters, and to generate comprehensive quality control (QC) outputs for inspecting preprocessing results.

Building on the pipeline outputs, the project also aims to develop practical data-processing utilities that organize and transform imaging results into formats suitable for downstream mathematical and statistical analyses.

## Current Scripts

The current repository focuses on structural and resting-state functional MRI processing using FreeSurfer, ANTs, and AFNI. Integration of MRtrix and additional downstream utilities is part of the broader project goal.

| File | Purpose |
| --- | --- |
| `H1_anat_recon.sh` | Performs FreeSurfer anatomical reconstruction and segmentation, then prepares AFNI/SUMA-compatible outputs. |
| `H2_anat_Prep_SSwarper.sh` | Performs anatomical bias-field correction, denoising, skull stripping, registration to a template, and visual quality control using ANTs and AFNI. |
| `H3_func_Prep_SSwarper.sh` | Performs functional MRI preprocessing using AFNI, incorporating anatomical processing outputs, motion correction, spatial normalization, smoothing, nuisance regression, temporal filtering, censoring, and quality control. |
| `affine_ANTs2AFNI.py` | Converts an ANTs affine transformation into AFNI-compatible matrix format. |

The scripts require the relevant external software to be installed. Template paths, input paths, and CPU settings should be adjusted to match the local environment before execution.

## References

Zhang, Y., Lv, G., Han, P., Peng, N., Li, L., Gu, J., ... & Shi, X. (2025). Enhanced individual difference of functional brain network induced by volitional eyes closing. *Scientific Reports*, *15*(1), 13037.

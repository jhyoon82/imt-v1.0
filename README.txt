Interacting Multiview Tracker

Ju Hong Yoon, Kuk-Jin Yoon, and Ming-Hsuan Yang




IMPORTANT:
To use this software, please cite the following publication.
 
Interacting Multiview Tracker, PAMI,  2014
Ju Hong Yoon, Kuk-Jin Yoon, and Ming-Hsuan Yang 

or

Visual Tracking via Adaptive Tracker Selection with Multiple Features, ECCV, 2012


        


INSTALLING & RUNNING (MATLAB 64bit)
1.	Unpack imt-v1.0.zip

2.	Start MATLAB and run main_imt_tracking.m. 

3.      Tracking results are saved as "sequence_name_imt.txt". 

4.      Put sequences (from data1.zip and data2.zip) in 'data' folder

Result- CVPR2013 benchmark dataset

1. IMT_cvpr2013benchmark_result.zip

 

This tracker uses the codes from other papers and websites as follows.
==============================================================
[1] mexLasso.mexw64
      - http://spams-devel.gforge.inria.fr/downloads.html

[2] ivt (folder)
     - Incremental Learning for Robust Visual Tracking, IJCV, 2007

[3] hog.m
      - piotr_toolbox_v2.6 from http://vision.ucsd.edu/~pdollar/toolbox/

[4] gly_zmuv.m
      - Robust Visual Tracking using l1 Minimization

==============================================================


NOTE that the tracking results in the PAMI paper were obtained by running the IMT 10 times.

To get constant tracking results, random seed is used in this code.


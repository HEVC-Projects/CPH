# CPH
A large-scale database for CU partition of HEVC (CPH).

For reducing HEVC encoding complexity through deep learning based approach, a large-scale database for CU partition of HEVC (CPH) is established, for both intra- and inter-modes. To the authors' best knowledge, this is the first database on CU partition patterns.

## Database for Intra-mode [1]

It is served for CU Partition of HEVC at Intra-mode: the CPH-Intra database.  First, 2000 images at resolution 4928×3264 are selected from Raw Images Dataset (RAISE) [2]. These 2000 images are randomly divided into training (1700 images), validation (100 images) and test (200 images) sets. Furthermore, each set is equally divided into four subsets: one subset is with original resolution and the other three subsets are down-sampled to be 2880×1920, 1536×1024 and 768×512. As such, this CPH-Intra database contains images at different resolutions. This ensures sufficient and diverse training data for learning to predict CU partition. 

Next, all images are encoded by the HEVC reference software HM 16.5 [3]. Specifically, four QPs {22,27,32,37} are applied for encoding with the configuration file encoder intra main.cfg in the common test conditions. After encoding, the binary labels indicating splitting (=1) and non-splitting (=0) are obtained for all CUs, and each CU with its corresponding binary label is seen as a sample. 

In total, the CPH-Intra database contains 12 sub-databases according to QP and CU size, on account that 4 QPs are applied and CUs with 3 different sizes (64×64, 32×32 and 16×16) are allowed to be split.

To download original images and labels (compressed in 8 files), visit:

https://drive.google.com/open?id=0B-x4IFNM0upjWmllNDdnc182dlU

https://drive.google.com/open?id=0B-x4IFNM0upjVTZHMmpveElGOGM

https://drive.google.com/open?id=0B-x4IFNM0upjLXByNkpIM3lTMTA

https://drive.google.com/open?id=0B-x4IFNM0upjbUxsQW5oeDdZb3M

https://drive.google.com/open?id=0B-x4IFNM0upjYzFQaEhPNEZRaWM

https://drive.google.com/open?id=0B-x4IFNM0upjNzl5SGtqOTB3WG8

https://drive.google.com/open?id=0B-x4IFNM0upjSVh0NEgtRXV0ajQ

https://drive.google.com/open?id=0B-x4IFNM0upjY2JDclFsZEtjdU0

Extract all data above to get 12 YUV files and 8 DAT files. Then execute "extractCUDepthGrndTruthCPHIntra.m" to generate all the training, validation and test samples.

## Database for Inter-mode

We further establish a database for CU Partition of HEVC at Inter-mode: the CPH-Inter database. For establishing the database, 111 raw video sequences were selected, therein consisting of 6 sequences at 1080p (1920×1080) from [4], 18 sequences of Classes A ∼ E from the Joint Collaborative Team on Video Coding (JCT-VC) standard test set [5], and 87 sequences from Xiph.org [6] at different resolutions. As a result, our CPH-Inter database contains video sequences at various resolutions: SIF (352×240), CIF (352×288), NTSC (720×486), 4CIF (704×576), 240p (416×240), 480p (832×480), 720p (1280×720), 1080p, WQXGA (2560×1600) and 4K (4096×2160). Note that the NTSC sequences were cropped to 720×480 by removing the bottom edges of the frames, considering that only resolutions in multiples of 8×8 are supported. Moreover, if the durations of the sequences are longer than 10 seconds, they were clipped to be 10 seconds. In our CPH-Inter database, all the above sequences were divided into non-overlapping training (83 sequences), validation (10 sequences) and test (18 sequences) sets. For the test set, all 18 sequences from the JCT-VC set [5] were selected. 

Similar to the CPH-Intra database, all sequences in our CPH-Inter database were encoded by HM 16.5 [3] with Low Delay P configuration (using encoder_lowdelay_P_main.cfg) at four QPs {22, 27, 32, 37}. Consequently, 12 sub-databases were obtained, corresponding to different QPs and CU sizes. As reported in Table II, a total of 307,831,268 samples were collected for our CPH-Inter database.

To download the BIN files for CPH-Inter database and the corresponding labels (compressed in one file), visit:

https://drive.google.com/open?id=0Bzxdhi861FZadzl3dmdSY2EtUms

## References

If the CPH database is helpful to your research, please cite this paper:

[1] Tianyi Li, Mai Xu and Xin Deng. A Deep Convolutional Neural Network Approach for Complexity Reduction on Intra-mode HEVC. IEEE International Conference on Multimedia and Expo (ICME), 2017.

Other references are listed below:

[2] D.-T. Dang-Nguyen, C. Pasquini, V. Conotter, and G. Boato, RAISE: A Raw Images Dataset for Digital Image Forensics, in: Proceedings of the 6th ACM Multimedia Systems Conference, 2015, pp. 219–224.

[3] JCT-VC, HM Software, [Online]. Available: https://hevc.hhi.fraunhofer.de/svn/svn HEVCSoftware/tags/HM-16.5/, [Accessed 5-Nov.-2016] (2014).

[4] M. Xu, X. Deng, S. Li, Z. Wang, Region-of-interest Based Conversational HEVC Coding with Hierarchical Perception Model of Face, IEEE Journal of Selected Topics in Signal Processing 8 (3) (2014) 475–489.

[5] J.-R. Ohm, G. J. Sullivan, H. Schwarz, T. K. Tan, T. Wiegand, Comparison of the Coding Efficiency of Video Coding Standards Including High Efficiency Video Coding (HEVC), IEEE Transactions on Circuits and Systems for Video Technology 22 (12) (2012) 1669–1684.

[6] Xiph.org, Xiph.org Video Test Media, https://media.xiph.org/video/derf/ (2017).

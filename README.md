# CPH
A large-scale database for CU partition of HEVC (CPH). [1]

For reducing HEVC encoding complexity through deep learning based approach, a large-scale database for CU partition of HEVC (CPH) is established, for both intra- and inter-modes. To the authors' best knowledge, this is the first database on CU partition patterns.

## Database for Intra-mode [2]

It is served for CU Partition of HEVC at Intra-mode: the CPH-Intra database.  First, 2000 images at resolution 4928×3264 are selected from Raw Images Dataset (RAISE) [3]. These 2000 images are randomly divided into training (1700 images), validation (100 images) and test (200 images) sets. Furthermore, each set is equally divided into four subsets: one subset is with original resolution and the other three subsets are down-sampled to be 2880×1920, 1536×1024 and 768×512. As such, this CPH-Intra database contains images at different resolutions. This ensures sufficient and diverse training data for learning to predict CU partition. 

Next, all images are encoded by the HEVC reference software HM 16.5 [4]. Specifically, four QPs {22,27,32,37} are applied for encoding with the configuration file encoder intra main.cfg in the common test conditions. After encoding, the binary labels indicating splitting (=1) and non-splitting (=0) are obtained for all CUs, and each CU with its corresponding binary label is seen as a sample. 

In total, the CPH-Intra database contains 12 sub-databases according to QP and CU size, on account that 4 QPs are applied and CUs with 3 different sizes (64×64, 32×32 and 16×16) are allowed to be split.

To download original images and labels (compressed in 8 files), visit 

Google Drive:

https://drive.google.com/drive/folders/1ftpSoq21vjBHgKJmbhQyQXb0L430gDwK?usp=sharing

or Dropbox:

https://www.dropbox.com/sh/eo5dc3h27t41etl/AAADvFKoc5nYcZw6KO9XNycZa?dl=0

or Baidu Cloud Disk:

https://pan.baidu.com/s/1hszUzeW

From all the sources above, files are identical. Feel free to choose one that is convenient for you. 

Extract all data above to get 12 YUV files and 8 DAT files. Then execute "extractCUDepthGrndTruthCPHIntra.m" to generate all the samples.

## Database for Inter-mode

We further establish a database for CU Partition of HEVC at Inter-mode: the CPH-Inter database. For establishing the database, 111 raw video sequences were selected, therein consisting of 6 sequences at 1080p (1920×1080) from [5], 18 sequences of Classes A ∼ E from the Joint Collaborative Team on Video Coding (JCT-VC) standard test set [6], and 87 sequences from Xiph.org [7] at different resolutions. As a result, our CPH-Inter database contains video sequences at various resolutions: SIF (352×240), CIF (352×288), NTSC (720×486), 4CIF (704×576), 240p (416×240), 480p (832×480), 720p (1280×720), 1080p, WQXGA (2560×1600) and 4K (4096×2160). Note that the NTSC sequences were cropped to 720×480 by removing the bottom edges of the frames, considering that only resolutions in multiples of 8×8 are supported. Moreover, if the durations of the sequences are longer than 10 seconds, they were clipped to be 10 seconds. In our CPH-Inter database, all the above sequences were divided into non-overlapping training (83 sequences), validation (10 sequences) and test (18 sequences) sets. For the test set, all 18 sequences from the JCT-VC set were selected. 

Similar to the CPH-Intra database, all sequences in our CPH-Inter database were encoded by HM 16.5 at four QPs {22, 27, 32, 37}. Now, the data for all three configurations of inter-modes have been open, containing that for the Low Delay P, Low Delay B and Random Access configurations (using encoder\_lowdelay\_P\_main.cfg, encoder\_lowdelay\_main.cfg and encoder\_randomaccess\_main.cfg, respectively).

To download the original YUV files (compressed in 31 files) with corresponding labels (compressed in 1 file), visit

Dropbox:

https://www.dropbox.com/sh/j4vryqwii74djfx/AABTh8aaoypmckOHe5cGJP6ha?dl=0

or Baidu Cloud Disk:

https://pan.baidu.com/s/1i5u2Krb

From both sources above, files are identical. Feel free to choose one that is convenient for you. 

Extract all data above to get 111 YUV files and 888 DAT files. Then execute "extractCUDepthGrndTruthCPHInter.m" to generate all the samples.

## Source Codes

Source codes are available for testing our deep ETH-CNN + ETH-LSTM based approach, at AI and LDP configurations. For more information, please visit: https://github.com/tianyili2017/HEVC-Complexity-Reduction

## References

If the CPH database is helpful to your research, please cite these papers:

[1] M. Xu, T. Li, Z. Wang, X. Deng, R. Yang and Z. Guan, "Reducing Complexity of HEVC: A Deep Learning Approach," in IEEE Transactions on Image Processing, vol. 27, no. 10, pp. 5044-5059, Oct. 2018.

doi: 10.1109/TIP.2018.2847035

keywords: {Complexity theory;Databases;Encoding;Feature extraction;Image coding;Machine learning;Video coding;High efficiency video coding;complexity reduction;convolutional neural network;deep learning;long- and short-term memory network},

URL: http://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=8384310&isnumber=8396881

[2] T. Li, M. Xu and X. Deng, "A deep convolutional neural network approach for complexity reduction on intra-mode HEVC," 2017 IEEE International Conference on Multimedia and Expo (ICME), Hong Kong, Hong Kong, 2017, pp. 1255-1260.

Other references are listed below:

[3] D.-T. Dang-Nguyen, C. Pasquini, V. Conotter, and G. Boato, RAISE: A Raw Images Dataset for Digital Image Forensics, in: Proceedings of the 6th ACM Multimedia Systems Conference, 2015, pp. 219–224.

[4] JCT-VC, HM Software, [Online]. Available: https://hevc.hhi.fraunhofer.de/svn/svn_HEVCSoftware/tags/HM-16.5/, [Accessed 5-Nov.-2016] (2014).

[5] M. Xu, X. Deng, S. Li, Z. Wang, Region-of-interest Based Conversational HEVC Coding with Hierarchical Perception Model of Face, IEEE Journal of Selected Topics in Signal Processing 8 (3) (2014) 475–489.

[6] J.-R. Ohm, G. J. Sullivan, H. Schwarz, T. K. Tan, T. Wiegand, Comparison of the Coding Efficiency of Video Coding Standards Including High Efficiency Video Coding (HEVC), IEEE Transactions on Circuits and Systems for Video Technology 22 (12) (2012) 1669–1684.

[7] Xiph.org, Xiph.org Video Test Media, https://media.xiph.org/video/derf/ (2017).

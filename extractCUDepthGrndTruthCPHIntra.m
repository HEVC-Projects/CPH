function extractCUDepthGrndTruthCPIH
    % This program transfers raw image and label files to samples that are directly available for deep CNNs,
    % in order to establish a large-scale database for CU partition of 
    % intra-mode HEVC (CPIH). 
    
    % All images are stored in 12 YUV files, arranged by resolutions and
    % usages (training, validation and test).
    
    % All labels and other necessary information are stored in 8 DAT files,
    % arranged by QPs (22, 27, 32 and 37). The files begining with
    % "CUDepth_" are binary data representing CU depth, and the ones
    % begining with "CUDepthIndex_" are text messages listing out the 
    % information of all frames in YUV files. 
    
    % Each line in "CUDepthIndex_" file indicates
    % some basic information of each frame, including POC, frame width and
    % frame height, and in the 1st frame (POC 0), QP and YUV file name are
    % also included. Corresponding to each line in "CUDepthIndex_", are a
    % certain number of bytes organized in the file "CUDepth_". Considering
    % that in HEVC frames, the CU depth (0, 1, 2 or 3) in a 16*16 unit is
    % the same, so for a W*H frame, there are floor(H/16) rows and
    % floor(W/16) columns, and the number of bytes needed is
    %         floor(W/16)*floor(H/16).
    % Note that all bytes for a frame are stored in row-major order.
    
    % Below is an example of "CUDepth_" and "CUDepthIndex_".
    % In "CUDepthIndex_AI_CPIH_768_1536_2880_4928_qp32_nf425_25_50.dat",
    % the 1st line is: 
    %         0 768 512  32  IntraTrain_768x512.yuv.
    % It is the 1st frame (POC=0) in "IntraTrain_768x512.yuv", and QP = 32.
    % There are 32 rows and 48 columns, corresponding to 32*48 = 1536 bytes
    % in "CUDepth_AI_CPIH_768_1536_2880_4928_qp32_nf425_25_50.dat",
    % organized as follows.
    
    % [CU depth in Row  1 Column  1]
    % [CU depth in Row  1 Column  2]
    %               .
    %               .
    %               .
    % [CU depth in Row  1 Column 48]
    % [CU depth in Row  2 Column  1] 
    % [CU depth in Row  2 Column  2]
    %               .
    %               .
    %               .
    % [CU depth in Row  2 Column 48]
    %               .
    %               .
    %               . 
    %               .
    %               .
    %               .
    % [CU depth in Row 32 Column  1]
    % [CU depth in Row 32 Column  2]
    %               .
    %               .
    %               .
    % [CU depth in Row 32 Column 48]
    
    % After executing this program, 36 sample files named "CUXXSamples_" 
    % will be generated, arranged by CU sizes, QPs and usages. In each 
    % file, all samples are continuously stored. Each sample takes up
    % (1 + CUWidth * CUWidth) bytes, where the initial byte is the label
    % representing whether the CU is split and the rest CUWidth * CUWidth
    % bytes are the luminance information of the CU in row-major order. All
    % the labels and luminance data are 8-bit unsigned type.
    
    % Below is an example of "CUXXSamples_".
    % There are totally 2446725 samples for 64*64 CUs in the training set.
    % So the file "CU64Samples_AI_CPIH_768_1536_2880_4928_qp22_Train.dat"
    % is orgarized as follows.
    
    % [label of the 1st CU (1 byte)]
    % [luminance infomation of the lst CU (64*64 bytes)]
    % [label of the 2nd CU (1 byte)]
    % [luminance infomation of the 2nd CU (64*64 bytes)]
    %               .
    %               .
    %               .
    % [label of the 2446725th CU (1 byte)]
    % [luminance infomation of the 2446725th CU (64*64 bytes)]
    % Therefore, the file size is (1+64*64)*2446725 = 10024232325 bytes.
    
    filePathInput='';
    filePathExtract='';
    QPList=[22 27 32 37];
    
    for i=1:length(QPList)
        extractCUDepthGrndTruth(...
            filePathInput,['_AI_CPIH_768_1536_2880_4928_qp' num2str(QPList(i)) '_nf425_25_50'],...
            filePathExtract,['_AI_CPIH_768_1536_2880_4928_qp' num2str(QPList(i)) '_Train'],...
            [1 4 7 10]);
        extractCUDepthGrndTruth(...
            filePathInput,['_AI_CPIH_768_1536_2880_4928_qp' num2str(QPList(i)) '_nf425_25_50'],...
            filePathExtract,['_AI_CPIH_768_1536_2880_4928_qp' num2str(QPList(i)) '_Valid'],...
            [2 5 8 11]);
        extractCUDepthGrndTruth(...
            filePathInput,['_AI_CPIH_768_1536_2880_4928_qp' num2str(QPList(i)) '_nf425_25_50'],...
            filePathExtract,['_AI_CPIH_768_1536_2880_4928_qp' num2str(QPList(i)) '_Test'],...
            [3 6 9 12]);
    end
end

function nSamplesMatrix=extractCUDepthGrndTruth(...
    filePathInput,fileSuffixInput,...
    filePathExtract,fileSuffixExtract,...
    seqValidIndex)

    fileNameCUDepthIndex=[filePathInput 'CUDepthIndex' fileSuffixInput '.dat'];
    fileNameCUDepth=[filePathInput 'CUDepth' fileSuffixInput '.dat'];
    fileNameExtract64=[filePathExtract 'CU64Samples' fileSuffixExtract '.dat'];
    fileNameExtract32=[filePathExtract 'CU32Samples' fileSuffixExtract '.dat'];
    fileNameExtract16=[filePathExtract 'CU16Samples' fileSuffixExtract '.dat'];

    fidCUDepthIndex=fopen(fileNameCUDepthIndex);
    fidCUDepth=fopen(fileNameCUDepth);

    fidExtract64=fopen(fileNameExtract64,'w+');
    fidExtract32=fopen(fileNameExtract32,'w+');
    fidExtract16=fopen(fileNameExtract16,'w+');

    nSamplesMatrix=zeros(3,2);
    %[[n64split n64nonsplit]
    % [n32split n32nonsplit]
    % [n16split n16nonsplit]]
    
    nSeq=0;
    nSeqTemp=0;
    info=[];
    widthIn16=[];
    heightIn16=[];
    width=[];
    qp=[];
    isValidSeq=0;
    while ~feof(fidCUDepthIndex)
        tline=fgetl(fidCUDepthIndex);
        nList=sscanf(tline,'%d %d %d');
        nFrame=nList(1);
        if nFrame==0
            nSeq=nSeq+1;
            info{nSeq}=[];
            nListTemp=sscanf(tline,'%d %d %d %d %s');
            qp(nSeq)=nListTemp(4);
            yuvNameList{nSeq}=nListTemp(5:end)';
        end
        width(nSeq)=nList(2);
        height(nSeq)=nList(3);
        widthIn16(nSeq)=fix(width(nSeq)/16);
        heightIn16(nSeq)=fix(height(nSeq)/16);
        infoTemp=fread(fidCUDepth,widthIn16(nSeq)*heightIn16(nSeq),'uint8');
        infoTemp=reshape(infoTemp,widthIn16(nSeq),heightIn16(nSeq))';
        info{nSeq}(:,:,nFrame+1)=infoTemp;
    end

    infoYInCTU=zeros(64,64);
    nTotal=0;
    for k=1:nSeq
        if ismember(k,seqValidIndex)
            fileNameYUV=[filePathInput yuvNameList{k}]
            fidYUV=fopen(fileNameYUV);
            for iFrame=0:size(info{k},3)-1
                disp(['Sequence ' num2str(k) ' : Frame ' num2str(iFrame+1) ' / ' num2str(size(info{k},3))]);
                Y=fread(fidYUV,width(k)*height(k),'uint8');
                UV=fread(fidYUV,width(k)*height(k)/2,'uint8');
                matrixY=reshape(Y,width(k),height(k))';
                
                widthInCTU=floor(size(info{k},2)/4);
                heightInCTU=floor(size(info{k},1)/4);
                for y=1:heightInCTU
                    for x=1:widthInCTU
                        nTotal=nTotal+1;
                        infoYInCTU(:,:)=matrixY((y-1)*64+1:y*64,(x-1)*64+1:x*64);
                        infoCUDepthInCTU=info{k}((y-1)*4+1:y*4,(x-1)*4+1:x*4,iFrame+1);
                        if mean(mean(infoCUDepthInCTU))>0
                            label64=1;
                            nSamplesMatrix(1,1)=nSamplesMatrix(1,1)+1;
                        else
                            label64=0;
                            nSamplesMatrix(1,2)=nSamplesMatrix(1,2)+1;
                        end
                        fwrite(fidExtract64,label64,'uint8');
                        fwrite(fidExtract64,reshape(infoYInCTU(:,:)',1,64*64),'uint8');
                        
                    end
                end
                
                isValid32=0;
                widthIn32=floor(size(info{k},2)/2);
                heightIn32=floor(size(info{k},1)/2);
                for y=1:heightIn32
                    for x=1:widthIn32
                        infoYIn32x32(:,:)=matrixY((y-1)*32+1:y*32,(x-1)*32+1:x*32);
                        infoCUDepthIn32x32=info{k}((y-1)*2+1:y*2,(x-1)*2+1:x*2,iFrame+1);
                        if infoCUDepthIn32x32(1,1)>=2
                            isValid32=1;
                            label32=1;
                            nSamplesMatrix(2,1)=nSamplesMatrix(2,1)+1;
                        elseif infoCUDepthIn32x32(1,1)==1
                            isValid32=1;
                            label32=0;
                            nSamplesMatrix(2,2)=nSamplesMatrix(2,2)+1;
                        end
                        
                        if isValid32>0
                            fwrite(fidExtract32,label32,'uint8');
                            fwrite(fidExtract32,reshape(infoYIn32x32(:,:)',1,32*32),'uint8');
                        end
                    end
                end
                
                isValid16=0;
                widthIn16=size(info{k},2);
                heightIn16=size(info{k},1);
                for y=1:heightIn16
                    for x=1:widthIn16
                        infoYIn16x16(:,:)=matrixY((y-1)*16+1:y*16,(x-1)*16+1:x*16);
                        infoCUDepthIn16x16=info{k}(y,x,iFrame+1);
                        if infoCUDepthIn16x16(1,1)==3
                            isValid16=1;
                            label16=1;
                            nSamplesMatrix(3,1)=nSamplesMatrix(3,1)+1;
                        elseif infoCUDepthIn16x16(1,1)==2
                            isValid16=1;
                            label16=0;
                            nSamplesMatrix(3,2)=nSamplesMatrix(3,2)+1;
                        end
                        if isValid16>0
                            fwrite(fidExtract16,label16,'uint8');
                            fwrite(fidExtract16,reshape(infoYIn16x16(:,:)',1,16*16),'uint8');
                        end
                    end
                end
%                 Uncomment these lines to show CU depth matrix (optional) .
%                 infoShown=imresize(info{k}(:,:,iFrame+1),5,'nearest');
%                 imshow(infoShown,[0 3]);
%                 title(['POC ' num2str(iFrame)]);
%                 pause;
            end

            fclose(fidYUV);
            disp(['Sequence ' num2str(k) ' Completed.']);
        end
    end
    disp([num2str(nTotal) ' CTUs Completed.']);
    nSamplesMatrix
    
    fidLogStat=fopen('LogStat.txt','a+');
    fprintf(fidLogStat,'%10d%10d\r\n%10d%10d\r\n%10d%10d\r\n\r\n',...
        nSamplesMatrix(1,1),nSamplesMatrix(1,2),...
        nSamplesMatrix(2,1),nSamplesMatrix(2,2),...
        nSamplesMatrix(3,1),nSamplesMatrix(3,2));
    fclose('all');
end

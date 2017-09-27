function extractCUDepthGrndTruthCPHInter
    % This program transfers raw video and label files to samples for
    % training, validation and test, establishing a large-scale database 
    % for CU partition of inter-mode HEVC (CPH-Inter). 
    
    % The database contains 111 videos in total.
    % For each video, there are 9 corresponding input files: 
    % 1 YUV file and 8 DAT files. 
    % The YUV file (in 420 format) stores original pixel-wise information of the video.
    % The DAT files store labels and other necessary information, arranged by QPs (22, 27, 32 and 37). 
    % The files ending with "_CUDepth.dat" are binary data representing CU depth, 
    % and the files ending with "" are text messages listing out the 
    % information of all frames in the YUV file. 
    
    % Each line in "_Index.dat" file indicates
    % some basic information of each frame, including POC, frame width, 
    % frame height and QP for the current frame. In the 1st frame (POC 0), YUV file name are
    % also included. Corresponding to each line in "_Index.dat", are a
    % certain number of bytes organized in the file "_CUDepth.dat". Considering
    % that in HEVC frames, the CU depth (0, 1, 2 or 3) in a 16*16 unit is
    % the same, so for a W*H frame, there are floor(H/16) rows and
    % floor(W/16) columns, and the number of bytes needed is
    %         floor(W/16)*floor(H/16).
    % Note that all bytes for a frame are stored in row-major order.
    
    % Below is an example of "_CUDepth.dat" and "_Index.dat".
    % In "Info_20170424_033631_LDP_BasketballDrive_1920x1080_50_qp32_nf500_Index.dat",
    % the 1st line is: 
    %         0 1920 1080 32  BasketballDrive_1920x1080_50.yuv.
    % It is the 1st frame (POC=0) in "IBasketballDrive_1920x1080_50.yuv", and QP = 32.
    % There are 67 rows and 120 columns, corresponding to 67*120 = 8040 bytes
    % in "Info_20170424_033631_LDP_BasketballDrive_1920x1080_50_qp32_nf500_CUDepth.dat",
    % organized as follows.
    
    % [CU depth in Row   1 Column   1]
    % [CU depth in Row   1 Column   2]
    %               .
    %               .
    %               .
    % [CU depth in Row   1 Column 120]
    % [CU depth in Row   2 Column   1] 
    % [CU depth in Row   2 Column   2]
    %               .
    %               .
    %               .
    % [CU depth in Row   2 Column 120]
    %               .
    %               .
    %               . 
    %               .
    %               .
    %               .
    % [CU depth in Row  67 Column   1]
    % [CU depth in Row  67 Column   2]
    %               .
    %               .
    %               .
    % [CU depth in Row  67 Column 120]
     
    % After executing this program, for each video at each QP, 3 sample files ended with "_CUXXSamples.dat" 
    % will be generated, arranged by CU size and QP. In each 
    % file, all samples are continuously stored. Each sample takes up
    % (1 + CUWidth * CUWidth) bytes, where the initial byte is the label
    % representing whether the CU is split and the rest CUWidth * CUWidth
    % bytes are the luminance information of the CU in row-major order. All
    % the labels and luminance data are 8-bit unsigned type.
    
    % Below is an example of "_CUXXSamples.dat".
    % There are totally 240,000 samples for 64*64 CUs in the video "BasketballDrive_1920x1080_50.yuv".
    % So the file "BasketballDrive_1920x1080_50_qp32_CU64Samples.dat"
    % is orgarized as follows.
    
    % [label of the 1st CU (1 byte)]
    % [luminance infomation of the lst CU (64*64 bytes)]
    % [label of the 2nd CU (1 byte)]
    % [luminance infomation of the 2nd CU (64*64 bytes)]
    %               .
    %               .
    %               .
    % [label of the 240,000-th CU (1 byte)]
    % [luminance infomation of the 240,000-th CU (64*64 bytes)]
    % Therefore, the file size is (1+64*64)*240,000 = 983,280,000 bytes.
    
    filePathInput='G:\YUV_All\'; % where all input YUV files and DAT files exist
    filePathExtract='F:\YUV_All_Extract\'; % where to store the extracted samples
    
    % Uncomment some video name(s) in the variable "yuvNameList".
    yuvNameList={...
        'BasketballPass_416x240_50'
        'BlowingBubbles_416x240_50'
        'BQSquare_416x240_60'
        'RaceHorses_416x240_30'
        'BasketballDrill_832x480_50'
        'BQMall_832x480_60'
        'PartyScene_832x480_50'
        'RaceHorses_832x480_30'
        'FourPeople_1280x720_60'
        'Johnny_1280x720_60'
        'KristenAndSara_1280x720_60'
        'BasketballDrive_1920x1080_50'
        'BQTerrace_1920x1080_60'
        'Cactus_1920x1080_50'
        'Kimono_1920x1080_24'
        'ParkScene_1920x1080_24'
        'PeopleOnStreet_2560x1600_30_crop'
        'Traffic_2560x1600_30_crop'
%         'garden_sif'
%         'stefan_sif'
%         'tennis_sif'
%         'tt_sif' 
%         'akiyo_cif'
%         'bowing_cif'
%         'bridge_close_cif'
%         'bridge_far_cif'
%         'bus_cif' 
%         'coastguard_cif'
%         'container_cif'
%         'deadline_cif'
%         'flower_cif'
%         'football_cif'
%         'foreman_cif'
%         'hall_monitor_cif'
%         'highway_cif'
%         'husky_cif'
%         'mad900_cif'
%         'mobile_cif'
%         'mother_daughter_cif'
%         'news_cif'
%         'pamphlet_cif'
%         'paris_cif'
%         'sign_irene_cif'
%         'silent_cif'
%         'students_cif'
%         'tempete_cif'
%         'waterfall_cif'
%         'flower_garden_720x480'
%         'football_720x480'
%         'galleon_720x480'
%         'intros_720x480'
%         'mobile_calendar_720x480'
%         'vtc1nw_720x480'
%         'washdc_720x480'
%         'city_4cif'
%         'crew_4cif'
%         'harbour_4cif'
%         'ice_4cif'
%         'soccer_4cif'
%         'mobcal_ter_720p50'
%         'parkrun_ter_720p50'
%         'shields_ter_720p50'
%         'stockholm_ter_720p5994' 
%         'aspen_1080p'
%         'blue_sky_1080p25'
%         'controlled_burn_1080p'
%         'crowd_run_1080p50'
%         'dinner_1080p30'
%         'ducks_take_off_1080p50'
%         'factory_1080p30'
%         'in_to_tree_1080p50'
%         'life_1080p30'
%         'old_town_cross_1080p50'
%         'park_joy_1080p50'
%         'pedestrian_area_1080p25'
%         'red_kayak_1080p'
%         'riverbed_1080p25'
%         'rush_field_cuts_1080p'
%         'rush_hour_1080p25'
%         'sintel_trailer_2k_1080p24'
%         'snow_mnt_1080p'
%         'speed_bag_1080p'
%         'station2_1080p25'
%         'sunflower_1080p25'
%         'touchdown_pass_1080p'
%         'tractor_1080p25'
%         'west_wind_easy_1080p'
%         'Netflix_Aerial_2048x1080_60fps_420'
%         'Netflix_BarScene_2048x1080_60fps_420'
%         'Netflix_Boat_2048x1080_60fps_420'
%         'Netflix_BoxingPractice_2048x1080_60fps_420'
%         'Netflix_Crosswalk_2048x1080_60fps_420'
%         'Netflix_Dancers_2048x1080_60fps_420'
%         'Netflix_DinnerScene_2048x1080_60fps_420'
%         'Netflix_DrivingPOV_2048x1080_60fps_420'
%         'Netflix_FoodMarket_2048x1080_60fps_420'
%         'Netflix_Narrator_2048x1080_60fps_420'
%         'Netflix_PierSeaside_2048x1080_60fps_420'
%         'Netflix_RitualDance_2048x1080_60fps_420'
%         'Netflix_RollerCoaster_2048x1080_60fps_420'
%         'Netflix_SquareAndTimelapse_2048x1080_60fps_420'
%         'Netflix_Tango_2048x1080_60fps_420'
%         'Netflix_ToddlerFountain_2048x1080_60fps_420'
%         'Netflix_TunnelFlag_2048x1080_60fps_420'
%         'Netflix_WindAndNature_2048x1080_60fps_420'
%         'female150'
%         'male150'
%         'onedarkfinal'
%         'simo'
%         'training'    
%         'x2'
    };
    QPList=[22 27 32 37];
    
    for iSeq=1:length(yuvNameList)
        for iQP=1:length(QPList)
            extractCUDepthGrndTruth(iSeq,yuvNameList{iSeq},QPList(iQP),filePathInput,filePathExtract);
        end
    end
end

function filePathAndName=getFilePathAndName(filePath,keyWords1,keyWords2)
    dirOutput=dir([filePath '*' keyWords1 '*' keyWords2 '*']);
    [filePath '*' keyWords1 '*' keyWords2 '*']
    fileNameList={dirOutput.name}';
    assert(length(fileNameList)==1);
    filePathAndName=[filePath fileNameList{1}];
end

function nSamplesMatrix=extractCUDepthGrndTruth(...
    iSeq,yuvName,QP,...
    filePathInput,...
    filePathExtract...
    )
    fileNameCUDepthIndex=getFilePathAndName(filePathInput,['_' yuvName '_qp' num2str(QP)],'_Index.dat');
    fileNameCUDepth=getFilePathAndName(filePathInput,['_' yuvName '_qp' num2str(QP)],'_CUDepth.dat');
    fileNameExtract64=[filePathExtract yuvName '_qp' num2str(QP) '_CU64Samples.dat'];
    fileNameExtract32=[filePathExtract yuvName '_qp' num2str(QP) '_CU32Samples.dat'];
    fileNameExtract16=[filePathExtract yuvName '_qp' num2str(QP) '_CU16Samples.dat'];

    fidCUDepthIndex=fopen(fileNameCUDepthIndex);
    fidCUDepth=fopen(fileNameCUDepth);

    fidExtract64=fopen(fileNameExtract64,'w+');
    fidExtract32=fopen(fileNameExtract32,'w+');
    fidExtract16=fopen(fileNameExtract16,'w+');

    nSamplesMatrix=zeros(3,2);
    %[[n64split n64nonsplit]
    % [n32split n32nonsplit]
    % [n16split n16nonsplit]]

    while ~feof(fidCUDepthIndex)
        tline=fgetl(fidCUDepthIndex);
        nList=sscanf(tline,'%d %d %d');
        nFrame=nList(1);
        if nFrame==0
            nListTemp=sscanf(tline,'%d %d %d %d %s');
        end
        width=nList(2);
        height=nList(3);
        widthIn16=fix(width/16);
        heightIn16=fix(height/16);
        infoTemp=fread(fidCUDepth,widthIn16*heightIn16,'uint8');
        infoTemp=reshape(infoTemp,widthIn16,heightIn16)';
        info(:,:,nFrame+1)=infoTemp;
    end

    infoYInCTU=zeros(64,64);
    nTotal=0;
    
    fileNameYUV=[filePathInput yuvName '.yuv']
    fidYUV=fopen(fileNameYUV);
    for iFrame=0:size(info,3)-1
        disp(['Sequence ' num2str(iSeq) ', QP ' num2str(QP) ' : Frame ' num2str(iFrame+1) ' / ' num2str(size(info,3))]);
        Y=fread(fidYUV,width*height,'uint8');
        UV=fread(fidYUV,width*height/2,'uint8');
        matrixY=reshape(Y,width,height)';

        widthInCTU=floor(size(info,2)/4);
        heightInCTU=floor(size(info,1)/4);
        for y=1:heightInCTU
            for x=1:widthInCTU
                nTotal=nTotal+1;
                infoYInCTU(:,:)=matrixY((y-1)*64+1:y*64,(x-1)*64+1:x*64);
                infoCUDepthInCTU=info((y-1)*4+1:y*4,(x-1)*4+1:x*4,iFrame+1);
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

        
        widthIn32=widthInCTU*2;
        heightIn32=heightInCTU*2;
        for y=1:heightIn32
            for x=1:widthIn32
                isValid32=0;
                infoYIn32x32(:,:)=matrixY((y-1)*32+1:y*32,(x-1)*32+1:x*32);
                infoCUDepthIn32x32=info((y-1)*2+1:y*2,(x-1)*2+1:x*2,iFrame+1);
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

        widthIn16=widthInCTU*4;
        heightIn16=heightInCTU*4;
        for y=1:heightIn16
            for x=1:widthIn16
                isValid16=0;
                infoYIn16x16(:,:)=matrixY((y-1)*16+1:y*16,(x-1)*16+1:x*16);
                infoCUDepthIn16x16=info(y,x,iFrame+1);
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

        % Uncomment these lines to show CU depth matrix (optional).
%         infoShown=imresize(info(:,:,iFrame+1),5,'nearest');
%         imshow(infoShown,[0 3]);
%         title(['POC ' num2str(iFrame)]);
%         pause;
    end
    fclose(fidYUV);
    
    if iSeq==1
        fidLogStat=fopen('LogStat.txt','w+');
    else
        fidLogStat=fopen('LogStat.txt','a+');
    end
    fprintf(fidLogStat,'Sequence %d, QP %d:\r\n',iSeq,QP);
    fprintf(fidLogStat,'%10d%10d\r\n%10d%10d\r\n%10d%10d\r\n\r\n',...
        nSamplesMatrix(1,1),nSamplesMatrix(1,2),...
        nSamplesMatrix(2,1),nSamplesMatrix(2,2),...
        nSamplesMatrix(3,1),nSamplesMatrix(3,2));
    fclose('all');
end

clear;
close;

t=csvread('TimeValues.csv');
pop=csvread('PopulationValues.csv');
bState=csvread('BacteriaValues.csv');
control=csvread('ControlInput.csv');
% bField=csvread('FieldValues.csv');

D=control(:,1);
e_proj=control(:,2);
Lac=bState(:,3:6:end-1);
Tet=bState(:,4:6:end-1);
aTc=bState(:,5:6:end-1);
IPTG=bState(:,6:6:end-1);

for i=1:size(Lac,1)
   avg_Lac(i)=mean(Lac(i,Lac(i,:)>0));
   avg_Tet(i)=mean(Tet(i,Tet(i,:)>0));
   cell_n(i)=length(Lac(i,Lac(i,:)>0));
end


 cd('./images');
 % create the video writer with 1 fps
 writerObj = VideoWriter('MOV1.avi');
 writerObj.FrameRate = 24;
 
 
 % set the seconds per image
 % open the video writer
 open(writerObj);
 
 tt=0;
 [~,rect]=imcrop(imread(sprintf('%d,00.png',tt)));
 
 % write the frames to the video
 im_dim=4320/5+1;
 ff=figure(1)
 for u=1:im_dim
     
     % convert the image to a frame
     
     subplot(3,4,[1 5 9]);
     imshow(imcrop(imread(sprintf('%d,00.png',tt*60)),rect));
     subplot(3,4,[6 7 8] );
     plot(t(t<tt),avg_Lac(t<tt),'r','linewidth',2);
     hold on;
     line([0 4320], [750 750], 'LineStyle', '-.', 'linewidth', 1, 'color', [1 0 0])
     plot(t(t<tt),avg_Tet(t<tt),'g','linewidth',2);
     line([0 4320], [300 300], 'LineStyle', '-.', 'linewidth', 1, 'color', [0 1 0])
     axis([0 4320 0 max(avg_Lac)]);
     xticks(480*[1 2 3 4 5 6 7 8 9]);
     xticklabels(2*[1 2 3 4 5 6 7 8 9]);
     ylabel('LacI-TetR');
     subplot(3,4, [2 3 4]); 
     plot(t(t<tt),cell_n(t<tt),'linewidth',2);
     axis([0 4320 0 max(cell_n)]);
     ylabel('Number of Cells')
     xticks(480*[1 2 3 4 5 6 7 8 9]);
     xticklabels(2*[1 2 3 4 5 6 7 8 9]);
     subplot(3,4,[10 11 12]);
     plot(t(t<tt),control(t<tt,1),'linewidth',2);
     axis([0 4320 0 1]);
     xticks(480*[1 2 3 4 5 6 7 8 9]);
     xticklabels(2*[1 2 3 4 5 6 7 8 9]);
     ylabel('Duty-Cycle');
     xlabel('Time [periods]');
   
     writeVideo(writerObj, getframe(ff));
     clf(gcf);
     tt=tt+5;
 end
 % close the writer object
 close(writerObj);
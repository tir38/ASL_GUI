function [] = testCarSequence()
% Jason Atwood
% 10/12/2012
tic
clc
clear all
close all
commandwindow
warning on verbose


%% ========== code ===========
load('/data/carSequence.mat');
fprintf('done loading car sequence data\n');
[pixelHeight,pixelWidth,~,numberOfFrames] = size(sequence);
initialRectangle = [318, 202, 418, 274];
rectHeight = initialRectangle(4) - initialRectangle(2);
rectWidth = initialRectangle(3) - initialRectangle(1);
rect = initialRectangle;

TrackedObject(1,:) = [rect(1),rect(2),rect(3),rect(4)]; % put initial rectangle in output file

for i = 1:(numberOfFrames-1)

    % pull two consecutive frames from sequence and grayscale
    frameIt = sequence(:,:,:,i);
    It = rgb2gray(frameIt);
    frameIt1 = sequence(:,:,:,i+1);
    It1 = rgb2gray(frameIt1);
    
    % display entire frame
    figure(1)
    subplot(1,2,1)
    axis equal
    imshow(It1)
    rectangle('Position',[rect(1),rect(2),rectWidth,rectHeight]);
    title('tracked object')

    % display just rect
    subplot(2,3,3)
    template = It(rect(2):rect(4),rect(1):rect(3));
    axis equal
    imshow(template)
    title_string = strcat('template: frame ',num2str(i));
    title(title_string);

    % run Lucas Kanade
    [u,v] = LucasKanade(It, It1, rect);
    
    % set plot title for plot generated inside LucasKanade
    subplot(2,3,6)
    title_string = strcat('warped image: frame ',num2str(i));
    title(title_string);
    
    % update rectangle
    rect(1) = rect(1) + round(u);
    rect(3) = rect(3) + round(u);
    rect(2) = rect(2) + round(v);
    rect(4) = rect(4) + round(v);

    % add updated rectangle to output file
    TrackedObject(i+1,:) = [rect(1),rect(2),rect(3),rect(4)];

    % save images
    if (i == 20) || (i == 60) || (i == 80)
        filename = strcat('tracking_results_at_frame_', num2str(i), '.png'); 
        saveas(1,filename);
    end
    
end

save('trackCoordinates.mat', 'TrackedObject'); %save pertinent data to .mat flie

close all
fprintf('\nDone!\n')
toc
end
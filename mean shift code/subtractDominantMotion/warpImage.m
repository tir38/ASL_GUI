function [outputImage] = warpImage(inputImage,p)
% Jason Atwood
% 10/10/2012
% does simple warping for LucasKanade and LucasKanadeAffine

% input:
% - input image
% - warping parameters either (2x1) or (6x1) vector

% output:
% - output image

% % to test this subfuction:
% load('carSequence.mat');
% frame1 = sequence(:,:,:,1);
% I = rgb2gray(frame1);
% p = [0,0];
% [output] = warpImage(I,p);
% imshow(output,[0,max(max(output))])


%% ----------- code ---------------
if (length(p) == 2) % for translational flow
    warning off MATLAB:colon:nonIntegerIndex % not sure why I need this
    
    % build X,Y,V matrices for interp2
    [width, height] = size(inputImage);

    X = repmat((1:height),width,1); 
    Y = repmat((1:width)',1,height);
    V = double(inputImage);

    Xq = X + p(1);
    Yq = Y + p(2);

    outputImage = interp2(X,Y,V,Xq,Yq);
    outputImage(isnan(outputImage)) = 0; % convert any NaN's => 0

elseif (length(p) == 6) % for affine flow
    
    % build X,Y,V matrices for interp2
    [width, height] = size(inputImage);

    X = repmat((1:height),width,1); 
    Y = repmat((1:width)',1,height);
    V = double(inputImage);
       
    [width, height] = size(inputImage);
    
    M = [1+p(1), p(3), p(5); p(2), 1+p(4), p(6); 0 0 1];%
    % p(1) is already 1 + p(1). same for p(4)
    
    for i = 1:width
        for j = 1:height
            product = M*[X(i,j);Y(i,j);1];
            Xq(i,j)= product(1);
            Yq(i,j)= product(2);
        end
    end

    outputImage = interp2(X,Y,V,Xq,Yq);
    outputImage(isnan(outputImage)) = 0; % convert any NaN's => 0
    
else
    fprintf('error: incorrect number of warp parameters\n')
end
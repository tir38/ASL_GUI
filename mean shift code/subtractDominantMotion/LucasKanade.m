function [u,v] = LucasKanade(It, It1, rect)
% Jason Atwood
% 10/12/2012

% inputs:
% - It:  is the image frame I(t) , already greyscaled
% - It1: is the image frame I(t+1) , 

% outputs:
% - [u, v] optical flow in x and y directions, units = pixels

%% ===== code ==============

threshold = 0.15;
[dX, dY] = gradient(double(It1)); % generate gradients of It1

% smooth gradients
gaussFilter = fspecial('gaussian',[3,3],2);
dX = imfilter(dX,gaussFilter,'replicate');
dY = imfilter(dY,gaussFilter,'replicate');

p = [0 0]; % intial guess of translational warping parameters

%% iterate until threshold
while (0 == 0)    
% map pixels in template to pixels in It1, based on current guess of warping parameters
    warpedImage = warpImage(It1,p);
    
% compute error between warped image (Wx_p) and template
    error = double(It) - double(warpedImage);
    error = reshape(error,[],1); % convert error to column matrix

% warp the gradients
    warped_dX = warpImage(dX,p);
    warped_dY = warpImage(dY,p);
    % for computational speed, rearrange warped_Dx and warped_Dy into column vectors
    warped_dX = reshape(warped_dX,[],1);
    warped_dY = reshape(warped_dY,[],1);
     
% compute steepest decents
    warped_Gradients = [warped_dX, warped_dY];
    steepestDecent = double(warped_Gradients); % because J is identity
    
% Hessian
    H = zeros(2);
    for i = 1:length(steepestDecent) % over all pixels
        H = H + steepestDecent(i,:)' *steepestDecent(i,:);
    end

% comute sum
    sum = 0;
    for i = 1:length(error)
        sum = sum + steepestDecent(i,:)'*error(i,:);
    end
    
% compute delta p
    deltaP = H\sum;
    
% break loop or update P
    normP = norm(deltaP);
    if (normP < threshold)
        break
    else
        p = p + deltaP';
    end
end % while loop  

% apply final p to (0,0) i.e. u,v = p
fprintf('LK output: [%f, %f]\n',p(1),p(2))
u = p(1);
v = p(2);
end
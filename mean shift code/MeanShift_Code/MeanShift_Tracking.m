function [x,y] = MeanShift_Tracking(q,I2,Lmap,height,width,f_thresh,max_it,x0,y0,H,W,k,gx,gy)
%% Mean-Shift Video Tracking 
% 7/2008        - Sylvain Bernhardt - initial implementation
% 11/28/2012    - Jason Atwood      - conversion for single image
%
% description:
% computes x,y position of patch in image2 based on template from image1, using
% Mean-Shift algorithm
%
% inputs:
% - q           : [m x n] matrix, PDF of the template from image 1
% - I2          : [o x p] matrix, image2
% - Lmap        : int, length of colormap, also number of bins for PDF
% - height      : int, height of image 2
% - width       : int, width of image 2
% - f_thresh    : float, similarity threshold
% - max_it      : int, the MINIMUM number of iterations
% - x0          : int, previous x location of template
% - y0          : int, previous y location of template
% - H           : int, height of template
% - W           : int, width of template
% - k           : [m x n] matrix, Parzen window
% - gx          : float, x gradient of kernel (Parzen window)
% - gy          : float, y gradient of kernel (Parzen window)
%
% outputs:
% - x : int, the x location in image 2
% - y : int, the y location in image 2
%
% subfuctions:
% - Density_estim - Sylvain Bernhardt
% - Simil_func - Sylvain Bernhardt

%% -------------- code -----------------
% initial guess of x and y in this frame, based on values in previous frame
y = y0;
x = x0;

% it is possible that patch of image 2 will be outside of image
% if so return original x0, y0
if (x<1) || (y<1) || ((x+W-1)>width) || ((y+H-1)>height)
%     fprintf('\t1. bumped against boundary, returning original x,y\n')
    return
end

% compute patch in image 2
T2 = I2(y:y+H-1,x:x+W-1);

% compute PDF of patch of image 2
p = Density_estim(T2,Lmap,k,H,W,0);

% computation of the similarity value between the two PDF.
[fi,w] = Simil_func(q,p,T2,k,H,W);

% apply Mean-shift algorithm
step = 1; % iteration counter
while fi<f_thresh && step<max_it % iterate until BOTH minimum number of iterations and threshold have been met
    step = step+1;
    num_x = 0;
    num_y = 0;
    den = 0;
    for i = 1:H
        for j=1:W
            num_x = num_x+i*w(i,j)*gx(i,j);
            num_y = num_y+j*w(i,j)*gy(i,j);
            den = den+w(i,j)*norm([gx(i,j) gy(i,j)]);
        end
    end
    
    % Displacement vector (dx,dy) on the gradient ascent
    if den ~= 0
        dx = round(num_x/den);
        dy = round(num_y/den);
        y = y+dy;
        x = x+dx;
    end
    
    % update patch 2, PDF of patch 2, and similarity betweend PDF 1 and PDF 2
    if (x<1) || (y<1) || ((x+W-1)>width) || ((y+H-1)>height)
        x = x0;
        y = y0;
%         fprintf('\t2. bumped against boundary, returning original x,y\n')
        return
    end
    T2 = I2(y:y+H-1,x:x+W-1);
    p = Density_estim(T2,Lmap,k,H,W,0);
    [fi,w] = Simil_func(q,p,T2,k,H,W);
end
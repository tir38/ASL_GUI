function [M]=LucasKanadeAffine(It,It1)
%Justin Farrell
%16-720 Computer Vision
%Assignment 3
%Section 3, Q5

It=double(It);
It1=double(It1);

%Initial Guess
p=[0;0;0;0;0;0];

%Create full image sized grid and fix to It
[X,Y]=meshgrid(1:size(It1,2),1:size(It1,1));

%Smooth and calculate image gradients
h=fspecial('gaussian',[3 3],1.5);
G=imfilter(It1,h,'replicate');
[Gx,Gy]=gradient(G);

%Define variables to end iterations
ep=.2;  %norm of deltap<ep
loops=0;
while 1==1
    %(1) Warp I with W(x; p) to compute I(W(x; p))
    %Create homography based on p
    M=[1+p(1) p(3) p(5); 
        p(2) 1+p(4) p(6); 
        0 0 1];

    %Create new grid by warping the fixed grid
    temp=[0;0;0];
    for i=1:size(X,1)
        for j=1:size(X,2)
            temp=M*[X(i,j); Y(i,j); 1];
            Xw(i,j)=temp(1);
            Yw(i,j)=temp(2);
        end
    end

    %Sample It1 at new warped grid points
    Iwarped=interp2(X,Y,It1,Xw,Yw);

    %2) Compute the error image T(x)  I(W(x; p))
    Ierror=It-Iwarped;

    %3) Sample the gradient at new warped grid points
    Gxw=interp2(X,Y,Gx,Xw,Yw);
    Gyw=interp2(X,Y,Gy,Xw,Yw);

    %4) Evaluate the jacobian
    Jx=[X(:) zeros(size(X(:))) Y(:) zeros(size(X(:))) ones(size(X(:))) zeros(size(X(:)))];
    Jy=[zeros(size(X(:))) X(:) zeros(size(X(:))) Y(:) zeros(size(X(:))) ones(size(X(:)))];

    %5) Steepest Descent
    Idescent=zeros(numel(X),6);
    Gxv=Gxw(:); %vectorize warped gradient
    Gyv=Gyw(:); %vectorize warped gradient

    for j=1:numel(X)
        J=[Jx(j,:); Jy(j,:)];
        Gradient=[Gxv(j) Gyv(j)];
        Idescent(j,:)=Gradient*J;
    end

    %6 Compute the Hessian
    Hess=zeros(6);
    for i=1:numel(X)
        if isnan(Idescent(i,1))~=1
            Hess=Hess+(Idescent(i,:)'*Idescent(i,:));
        end
    end

    %7) Compute summation
    Ierrorv=double(Ierror(:));
    sumTerm=zeros(6,1);

    for i=1:numel(X)
        if isnan(Idescent(i,1))~=1
            if isnan(Ierrorv(i))~=1
                sumTerm(:)=sumTerm+(Idescent(i,:)'*Ierrorv(i));
            end
        end
    end

    %8) deltaP
    deltaP=Hess\sumTerm;
    p=p+deltaP;

    %Break loop error condition met

    if(norm(deltaP)<ep)
        break;
    end
    %Break loop if max iterations is met
    loops=loops+1;
    if(loops>100)
        display('Exceeded loop count');
        break;
    end
end






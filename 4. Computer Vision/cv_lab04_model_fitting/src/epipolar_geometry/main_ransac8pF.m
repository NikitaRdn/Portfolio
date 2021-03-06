% =========================================================================
% Exercise 4.5: Feature extraction and matching
% =========================================================================
clear
addpath helpers

%don't forget to initialize VLFeat

%Load images
% imgName1 = ''; % Try with some different pairs
% imgName2 = '';
dataset=3;


if(dataset==0)
    imgName1 = '';
    imgName2 = '';

    % Your camera calibration
    K = [];
elseif(dataset==1)
	imgName1 = 'images/ladybug_Rectified_0768x1024_00000064_Cam0.png';
	imgName2 = 'images/ladybug_Rectified_0768x1024_00000080_Cam0.png';

	K = [130.5024      0  500.0005
	      0  130.5024  372.3164
	      0         0    1.0000];
elseif(dataset==2)
	imgName1 = 'images/rect1.jpg';
	imgName2 = 'images/rect2.jpg';

	K = [  	1653.5  0    	0982.7;
			0    	1655.3 	0725.4;
			0.0		0.0		1.0 ];
elseif(dataset==3)
	imgName1 = 'images/pumpkin1.jpg';
	imgName2 = 'images/pumpkin2.jpg';

    K = [1197, 0,      466.19;
        0,     1199.1, 314.13;
        0,     0,      1];
end
img1 = single(rgb2gray(imread(imgName1)));
img2 = single(rgb2gray(imread(imgName2)));

%extract SIFT features and match
[fa, da] = vl_sift(img1,'PeakThresh',1);
[fb, db] = vl_sift(img2,'PeakThresh',1);
[matches, scores] = vl_ubcmatch(da, db);

x1s = [fa(1:2, matches(1,:)); ones(1,size(matches,2))];
x2s = [fb(1:2, matches(2,:)); ones(1,size(matches,2))];

%show matches
clf
showFeatureMatches(img1, x1s(1:2,:), img2, x2s(1:2,:), 1,'b');


%%
% =========================================================================
% Exercise 4.6: 8-point RANSAC
% =========================================================================

threshold = 2;

% implement ransac8pF
[inliers1, inliers2, outliers1, outliers2, M, F] = ransac8pF(x1s, x2s, threshold);


showFeatureMatches(img1, inliers1(1:2,:), img2, inliers2(1:2,:), 2,'g');
showFeatureMatches(img1, outliers1(1:2,:), img2, outliers2(1:2,:), 3,'r');
% showFeatureMatches(img1, outliers1(1:2,:), img2, outliers2(1:2,:), 2);

%% Additinal RANSAC wih essential matrix

nnx1s=K\inliers1;
nnx2s=K\inliers2;
E=K'*F*K;
[Eh, ~] = essentialMatrix(nnx1s, nnx2s);

P1 = [eye(3) [0;0;0]];
P2 = decomposeE(E, nnx1s, nnx2s);

Ms={[P1; 0 0 0 1],[P2;0 0 0 1]};
showCameras(Ms,4)
% TODO: triangulate 3D points and plot together with cameras
% The function showCameras.m  can be useful here
[X, err] = linearTriangulation(P1, nnx1s, P2, nnx2s);
figure(4)
plot3(X(1,:),X(2,:),X(3,:),'xb');
% =========================================================================
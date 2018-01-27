function AlignedImg = face_registration(Detected, isShowed)
landmarks = Detected.points;
img = Detected.img;
% Shows image with landmarks
if isShowed
    figure
    imshow(img);
    hold on 
    plot(landmarks(:,1),landmarks(:,2),'o')
    for i=1:size(landmarks,1)
        text(landmarks(i,1),landmarks(i,2),int2str(i));
    end
end

% Extracts the eye coordinates based on the landmarks
x1 = mean(landmarks(37:42,1));
y1 = mean(landmarks(37:42,2));
x2 = mean(landmarks(43:47,1));
y2 = mean(landmarks(43:47,2));

x_position = [x1;x2];
y_position = [y1;y2];

% the template of left eye center and right eye center
template = [72 82; 184 82]; % TODO! maybe consider the poses too

% Aligns the image
tform = cp2tform([x_position y_position], template, 'nonreflective similarity'); %similarity %affine
im_sample_registered = imtransform(img, tform, 'bicubic', 'XData', [1 256], 'YData', [1 300], 'XYScale', 1);
new_landmarks = tformfwd(tform,landmarks);
img_result = im_sample_registered;
if isShowed
    figure
    imshow(img_result)
end

% Formats output
AlignedImg.originalImg = img;
AlignedImg.alignedImg = img_result;
AlignedImg.landmarks = new_landmarks;
AlignedImg.name = Detected.name;
imwrite(img_result,strcat('Face Detection/DetectedFaces/',strrep(Detected.name,'/','.')));
end % of function
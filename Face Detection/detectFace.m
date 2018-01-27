%{
function Detected = detectFace(img)

Function   : Detect Faces

Description: The procedure detects appearances of face(s) inside an image,
             and crops the image to that region only;
             Also it stores the final image, the file path,
             landmarks and pose information in a struct
             (Detected).

Parameters : img         - an rgb or gray image
             path        - the file path to the original image
             isShowed    - boolean value,
                           decides if the the results are displayed
Return     : the normalized image

Examples of Usage:
    >> face_img = imread('face.jpg');
    >> norm_face = normalize(face_img)  % fixContrast = fixNoise = 1
    >> norm_face = normalize(face_img, 0)  % fixContrast = fixNoise = 0
    >> norm_face = normalize(face_img, 1, 0)  % fixContrast = 1, 
                                              % fixNoise = 0    
%}

function Detected = detectFace(img, path, isShowed)
addpath(genpath('Face Detection'))
img = imresize(img,[300 NaN]); % Optional: resize the image
Detected(1).name = path;
Detected(1).img = im2double(img);

% % Initialization to store the results
Detected(1).points = []; % MAT containing 66 Landmark Locations
Detected(1).pose = []; % POSE information [Pitch;Yaw;Roll]

clm_model='Face Detection/DRMF/model/DRMF_Model.mat';
load(clm_model);    
Detected = DRMF(clm_model, Detected, 1, isShowed);
end
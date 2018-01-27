close all
clear
clc

% Get images in the Test Images folder
addpath(genpath('.'))
img_list=dir(['Test Images/','*.png']);
p = randperm(length(img_list));
img_list = img_list(p);

% Options
mode = 'region';
classifierName = 'ensemble';
dataset = 'ck'; %for getting the classifier
if strcmp(dataset, 'ck')
    emotions = ["anger", "contempt", "disgust", "fear", "happy", "sadness", "surprise"];
else
     emotions = ["happy","sad","surprise","anger","disgust","fear"];
end

for i = 1:length(img_list)
    % Choose image and mode
    disp(img_list(i).name)
    path = char(strcat('Test Images/',img_list(i).name));
    img = imread(path);
    figure
    imshow(img);
    
    % Aligns face
    img = normalize(img,0);
    Detected = detectFace(img, path, 1);
    AlignedImg = face_registration(Detected, 1);
    
    % Extracts features
    X = featureExtract(AlignedImg, mode, 1);
    
    % Classify
    load(strcat('Classifiers/', classifierName,'/',dataset,'_',mode,'_classifier.mat'));
    disp('Result:');
    disp(emotions(classifier.predict(X,1)));
    pause
end

emotions = ["anger", "contempt", "disgust", "fear", "happy", "sadness", "surprise"];

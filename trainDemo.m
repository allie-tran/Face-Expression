clear
close all
clc
% addpath(genpath('.'))
rng(1)

% Hyper-parameters
mode = 'region'; %whole, multi, region
classifierName = 'svm'; %svm, ensemble, bayes, discr, tree, knn
validationMode = 'cross'; %None, cross
dataset = 'ck'; %ck, jaffe
isAligned = 0; % aligned images are available % This is really slow
isProcessed = 0; % histograms are available
if strcmp(dataset, 'ck')
    emotions = ["anger", "contempt", "disgust", "fear", "happy", "sadness", "surprise"];
else
     emotions = ["happy","sad","surprise","anger","disgust","fear"];
end
% Get data
if isProcessed
    load(strcat('Data/', mode, '_', dataset,'.mat'));
else
    [X, y, paths] = getTrainingData(dataset, mode,...
        strcat('Data/', mode,'_', dataset), isAligned);
end
X(y==8,:) = [];
y(y==8) = [];

dist = @(h1,h2) distance(Ch1,h2);
x = tsne(X, 'Distance', 'seuclidean', 'NumPCAComponents', 0);
%'cosine', 'seuclidean', 'cityblock','chebychev', 'spearman', 'correlation'
% 'mahalanobis','hamming', 'jaccard'
gscatter(x(:,1),x(:,2),y)
legend("anger", "contempt", "disgust", "fear", "happy", "sadness", "surprise")

% PCA
numberOfDimensions = 100;
coeff = pca(X);
reducedDimension = coeff(:,1:numberOfDimensions);
X = X * reducedDimension;

%%
if strcmp(validationMode,'None')
    % Splits dataset randomly 7-3
%     p = randperm(size(X,1));
%     X = X(p,:); y = y(p); paths = paths(p);

    len = round(size(X,1) * 0.7);
    tr.X = X(1:len,:); tr.y = y(1:len);
    tr.paths = {paths{1:len}};
    test.X = X(len:size(X,1),:); test.y = y(len:size(X,1));
    test.paths = {paths{len:size(X,1)}};
    
    %% Trains data
    classifier = trainData(tr, classifierName, mode, dataset);
    
    %% Gets results
    training_result = classifier.predict(tr.X,0);
    testing_result = classifier.predict(test.X,0);
    
    test_acc = sum(testing_result == test.y)/size(test.y,1);
    fprintf('Testing accuracy %6.4f\n',test_acc);
    train_acc = sum(training_result == tr.y)/size(tr.y,1);
    fprintf('Training accuracy %6.4f\n',train_acc);
    disp('Confusion matrix for training set');
    disp(confusionmat(training_result,tr.y));
    disp('Confusion matrix for testing set');
    disp(confusionmat(testing_result,test.y));
    for i=1:length(test.y)
        if testing_result(i) ~= test.y(i)
            img = imread(test.paths{i});
            imshow(img);
            strcat('Test Images/',emotions(test.y(i)),'-',...
                emotions(testing_result(i)),'.png')
            pause
        end
    end
elseif strcmp(validationMode,'cross') % cross-validation
    % Shuffles
    p = randperm(size(X,1));
    X = X(p,:); y = y(p); paths = paths{p};
    len = floor(size(X,1)/10);  
    C = zeros(length(emotions),length(emotions));
    sums = zeros(length(emotions),1);
    for i=1:10
        all = 1:size(X,1);
        forTest = (all>len*(i-1) & all<=len*i);
        tr.X = X(~forTest,:); tr.y = y(~forTest);
        test.X = X(forTest,:); test.y = y(forTest);
        
        classifier = trainData(tr, classifierName, mode, dataset);
        testing_result = classifier.predict(test.X,0);
        test_acc(i) = sum(testing_result == test.y)/size(test.y,1);

        C = C+confusionmat(testing_result,test.y,'ORDER',1:length(emotions));
        for label=1:length(emotions)
            sums(label) = sums(label)+sum(test.y==label);
        end
     end
    fprintf('Mean testing accuracy %6.4f\n',mean(test_acc));
    disp('Confusion matrix for testing set')
    for label=1:length(emotions)
         C(:,label) = C(:,label)/sums(label);
    end
    disp(C*100)
else % leave-one-subject-out
    load(strcat('Data/', mode, '_', dataset,'.mat'));
    for i=1:length(train)
        classifier = trainData(train{i}, classifierName, mode, dataset);
        testing_result = classifier.predict(test{i}.X,0);
        test_acc(i) = sum(testing_result == test{i}.y)/size(test{i}.y,1);
    end
    fprintf('Mean testing accuracy %6.4f\n',mean(test_acc));
end
function h = histogramExtract(AlignedImg, mode, isShowed)
% Uses LBP the one image
P = 8; % Number of points of interest
R = 1; % Radius
mapping = getmapping(P, 'u2'); % uniform
num = mapping.num;

img = AlignedImg.alignedImg;
% Get the histograms
% -------------------------%
if strcmp(mode, 'whole')
    img = img(ceil(0.05*256):floor(0.86*256),...
        ceil(0.15*256):floor(0.85*256));
    h = lbp(img,R,P,mapping,'nh');
    
    if isShowed
        subplot(2,1,1); imshow(lbp(img,1,8,mapping,'i'))
        subplot(2,1,2); bar(h);
    end
    % -------------------------%
elseif strcmp(mode,'multi')
    division = 9;
    lenx = floor(size(img,1)/division);
    leny = floor(size(img,2)/division);
    h = zeros(1,num*division*division);
    for i=1:division
        for j=1:division
            sub_h = lbp(img(lenx*(i-1)+1:lenx*i,leny*(j-1)+1:leny*j),R,P,mapping,'nh');
            h(1,num*(division*(i-1)+j-1)+1 : num*(division*(i-1)+j)) = sub_h;
            if isShowed
                subplot(division,division*2,division*2*(i-1)+j);
                imshow(img(lenx*(i-1)+1:lenx*i,leny*(j-1)+1:leny*j));
                subplot(division,division*2,division*2*(i-1)+j+division);
                bar(sub_h);
            end
        end
    end
    
    if isShowed
        figure
        bar(1:num*division*division,h,'histc');
    end
    
    % -------------------------%
elseif strcmp(mode, 'region')
    % Defines regions
    p = AlignedImg.landmarks;
    num_regions = length(p);
    %         regions{1} = [p(22,2)-20 p(28,2) p(40,1) p(43,1)];
    %         regions{2} = [p(20,2)-10 p(18,2)+10 p(18,1)-10 p(22,1)+10];
    %         regions{3} = [p(25,2)-10 p(27,2)+10 p(23,1)-10 p(27,1)+10];
    %         regions{4} = [min(p(25,2),p(20,2))-10, max(p(27,2),p(18,2))+10,...
    %             p(18,1)-10, p(27,1)+10];
    %         regions{5} = [p(38,2)-20 p(42,2)+10 p(37,1)-20 p(40,1)+10];
    %         regions{6} = [p(44,2)-20 p(47,2)+10 p(43,1)-10 p(46,1)+20];
    %         regions{7} = [min(p(44,2),p(38,2))-10, max(p(42,2),p(47,2))+10,...
    %             p(37,1)-10, p(46,1)+20];
    %         regions{8} = [p(28,2) p(34,2)+10 p(40,1)-5 p(43,1)+5];
    %
    %         regions{9} = [p(51,2)-19 p(58,2)+10 p(49,1)-10 p(55,1)+10];
    %         regions{10} = [p(32,2) p(60,2)+15 p(49,1)-35 p(50,1)];
    %         regions{11} = [p(36,2) p(56,2)+15 p(54,1) p(55,1)+35];
    %         regions{12} = [p(58,2)-15 p(58,2)+20 p(59,1)-10 p(57,1)+10];
    d1 = 10;
    d2 = (p(27,1)-p(18,1))/8;
    top = p(18,2)-20; left=p(18,1);
    for i=1:2
        for j=1:8
            regions((i-1)*4+j,:) = [top + (i-1)*d1 top + i*d1 left + (j-1)*d2 left + j*d2];
        end
    end
    regions(17,:) = [p(22,2)-20 p(28,2) p(40,1) p(43,1)];
    for i=18:num_regions
        regions(i,:) =  [p(i,2)-20 p(i,2)+20 p(i,1)-20 p(i,1)+20];
    end
    % Extracts LBP
    h = zeros(1,num*(num_regions));
    for i=1:num_regions
        r = regions(i,:);
        r = [max(r(1),1) min(r(2),size(img,1))...
            max(r(3),1) min(r(4),size(img,2))];
        while r(2) - r(1) < 5
            if r(1) > 10
                r(1) = r(1) - 1;
            else
                r(2) = r(2) + 1;
            end
        end
        while r(4) - r(3) < 5
            if r(3) > 1
                r(3) = r(3) - 1;
            else
                r(4) = r(4) + 1;
            end
        end
        reg = img(ceil(r(1)):floor(r(2)),...
            ceil(r(3)):floor(r(4)));
        reg_h = lbp(reg,R,P,mapping,'nh');
        h(1,num*(i-1)+1:num*i) = reg_h;
        if isShowed
            subplot(ceil(sqrt(num_regions)),ceil(sqrt(num_regions)),i);
            imshow(reg);
            %                     subplot(3, num_regions,i+num_regions);
            %                     imshow(lbp(reg,1,8,mapping,'i'));
        end
    end
end
%      h = h.^(-1/2);

end % of function
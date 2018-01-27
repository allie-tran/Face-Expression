%{
function norm_img = normalize(img)

Function   : Normalize

Description: The procedure converts an image
             into grayscale if possible.
             It also corrects the contrast,
             reduces unwanted noise.

Parameters : img         - an rgb or gray image
             fixContrast - boolean value 
                           for if the procedure should fix the contrast
                           Default: True (1)     
             fixNoise    - boolean value 
                           for if the procedure should reduce noise    
                           Default: True (1) 
Return     : the normalized image

Examples of Usage:
    >> face_img = imread('face.jpg');
    >> norm_face = normalize(face_img)  % fixContrast = fixNoise = 1
    >> norm_face = normalize(face_img, 0)  % fixContrast = fixNoise = 0
    >> norm_face = normalize(face_img, 1, 0)  % fixContrast = 1, 
                                              % fixNoise = 0    
%}

function img = normalize(varargin) % (image, fixContrast, fixNoise)

img = varargin{1};
if nargin == 1
    fixContrast = 1;
    fixNoise = 1;
elseif nargin == 2   
    fixContrast = varargin{2};
    fixNoise = varargin{2};
else
    fixContrast = varargin{2};
    fixNoise = varargin{3};
end

% Convert to grayscale for rgb images
if size(img,2) == 3
    img = rgb2gray(img);
end

if fixNoise
    img = medfilt2(img);
end

if fixContrast
    img = histeq(img);
end
end % of function

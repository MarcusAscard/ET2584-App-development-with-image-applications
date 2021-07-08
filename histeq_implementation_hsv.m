clear all

im = imread('images/bild2.jpg');
grayscale = false;

if size(im,3)==3 % if rgb image, extract v-component from image
    im_hsv = rgb2hsv(im);
    v = im_hsv(:,:,3);
    v = uint8(255*v); % double [0,1] -> uint8 [0,256], because cdf_transform will be [0,256]
else
    grayscale = true;
    v = im;
end

count = imhist(v);
figure,
bar(count)
title('Original Histogram')
xlabel('Brightness Level')
ylabel('Value')

[im_hist ~] = imhist(v); % make histogram using only v-component component

pdf  = im_hist/(size(v,1)*size(v,2)); % convert from intensities to probability density function

cdf = cumsum(pdf);
cdf_transform = floor(255*cdf); % equalized intensity values

v_histeq = zeros(size(v));
for i=1:size(v,1)
    for j=1:size(v,2)
        if v(i,j) == 0 % Array indices must be positive integers or logical values.
            v(i,j) = 1;
        end
        v_histeq(i,j) = cdf_transform(v(i,j)); % value from v is replaced with new value at index v(i,j) in cdf_transform
    end
end

im_hsv(:,:,3) = v_histeq/255; % rescale back into [0,1]
rgb = hsv2rgb(im_hsv); % convert to RGB

figure,
imshow(rgb)
title('Image After Histogram Equalization')
figure,
if grayscale == true
    imshow(im)
else
    imshow(im)
end
title('Original Image')

greyscale_histeq_uint8 = uint8(v_histeq);
new_count = imhist(greyscale_histeq_uint8);
figure,
bar(new_count)
title('Equalized Histogram')
xlabel('Brightness Level')
ylabel('Value')

figure,
imshow(histeq(im))
title('MATLABs histeq-function')


%  Performance evaluation
histeq_im = histeq(im);
if ~grayscale
    histeq_im = histeq_im(:,:,3);
end

mad_histeq = mad(v_histeq,0,'all');
mad_orig = mad(double(v),0,'all');
mad_matlab_histeq= mad(double(histeq_im),0,'all');
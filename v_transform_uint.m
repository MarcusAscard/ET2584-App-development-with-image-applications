clear all

im = imread('images/gray_apple.jpeg');
grayscale = false;

if size(im,3)==3 % If rgb image, extract v-component from image
    im_hsv = rgb2hsv(im);
    v = im_hsv(:,:,3);
    v = uint8(256*v); % double [0,1] -> uint8 [0,256]
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

[im_hist, ~] = imhist(v); % Make histogram using only v-component component

v_vec = reshape(v,[],1); % convert matrix to column vector
v_vec = sort(v_vec); % sort vector in ascending order

n_vec = zeros(1,10);

for i = 1:10
    n_vec(i) = mod(length(v_vec), i); % vector with remainders
    if n_vec(i) == 0 % find highest integer which gives zero remainder
        n = i;
    end
end

vec_seg = reshape(v_vec,length(v_vec)/n,[]); % segment vector into n equally large segments

spaced_vec = cell(1,length(v_vec)/n);

for i = 0:n-1 % make n-column cell with values in the intervals [k,(k+1)/n], k = 0,1,2,...,n
    spaced_vec{i+1} = linspace((i/n)*255,((i+1)/n)*255,length(v_vec)/n);
    spaced_vec{i+1} = reshape(spaced_vec{i+1},[],1);
end

spaced_vec = uint8(cell2mat(spaced_vec)); % convert back to matrix for convenience

[row, col] = size(v);

v_trans_im = uint8(zeros(size(v)));
v_temp = v;

r = 0;
c = 0;
orig_pixel_val = 0.0;
new_pixel_val = 0.0;

for i = 1:row
    for j = 1:col
        orig_pixel_val = v(i,j);
        [r, c] = find(vec_seg==orig_pixel_val,1); % index of pixel value in vec_seg
        vec_seg(r,c) = 0; % since find finds first occurence of orig_pixel_val by default we need to mark the index as used to avoid duplicates
        new_pixel_val = spaced_vec(r,c);
        v_trans_im(i,j) = new_pixel_val;
    end
end

close all

im_hsv(:,:,3) = double(v_trans_im)/255;  % uint8 [0,255] -> double [0,1]
rgb = hsv2rgb(im_hsv);
figure,
imshow(rgb)
xlabel('Image after V-transform')

figure,
imshow(im)
xlabel('Original image')

figure,
imshow(histeq(im))
xlabel('MATLABs histeq-function')

%  Performance evaluation
histeq_im = histeq(im);
if ~grayscale
    histeq_im = histeq_im(:,:,3);
end

mad_v = mad(double(v_trans_im),0,'all');
mad_orig = mad(double(v_temp),0,'all');
mad_histeq= mad(double(histeq_im),0,'all');

figure,
imshow(rgb)
title('Image after V-transform')

figure,
imshow(im)
title('Original image')

figure,
imshow(histeq(im))
title('MATLABs histeq-function')

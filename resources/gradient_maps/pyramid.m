height = zeros(2*256 - 1);

for i = 2:length(height) - 1
    height(i:end+1-i, i:end+1-i) = height(i:end+1-i, i:end+1-i) + 1;
end
img = zeros(2*256-1, 2*256-1, 3);
img(:, :, 1) = mat2gray(height);
imshow(img)
imwrite(img, 'pyramid.png')
surf(height, 'Edgecolor', 'none');
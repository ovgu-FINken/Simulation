%creates a gradient map with some randomly placed hills (Gauss curves)
%will overwrite hills.png without asking
% R: height
% G: x gradient (0.5 intensity corresponds to 0 gradient)
% B: y gradient

%square size in pixels
size = 1024;

%you can change these to create different types of landscape
num_hills = 8;

min_height = 100;
max_height = 255;
min_sigma = 10000;
max_sigma = 50000;


[coords1, coords2] = meshgrid(1:size, 1:size);
terrain = zeros(size);
for i = 1:num_hills
    mu = [randi(size) randi(size)];
    height = randi([min_height max_height]);
    sigma = randi([min_sigma, max_sigma]);
    values = mvnpdf([coords1(:) coords2(:)], mu, [sigma sigma]);
    values = reshape(values, size, size);
    terrain = terrain+values*height;
end

%visualization
surf(terrain, 'EdgeColor', 'none');

axis([1 size 1 size 0 max(max(terrain))*1.1]);
y_grad = diff(terrain);
x_grad = diff(terrain')';

%normalization for encoding in RGB
total_min = min(min(x_grad(:)), min(y_grad(:)));
total_max = max(max(x_grad(:)), max(y_grad(:)));
terrain = mat2gray(terrain);
x_grad = x_grad / (total_max - total_min)  + 0.5;
y_grad = y_grad / (total_max - total_min)  + 0.5;
x_grad = padarray(x_grad, [0 1], 'post');
y_grad = padarray(y_grad, [1 0], 'post');
figure()
img = zeros(size, size, 3);
img(:, :, 1) = terrain;
img(:, :, 2) = x_grad;
img(:, :, 3) = y_grad;
imshow(img);
imwrite('hills.png');


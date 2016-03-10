%creates a gradient map with some randomly placed hills (Gauss curves)
% R: height
% G: x gradient (0.5 intensity corresponds to 0 gradient)
% B: y gradient

% easily turn on and off 3D and arrow visualization
visualize = true;

%square size in pixels
size = 4096;

%you can change these to create different types of landscape
num_hills = 16;

min_height = 150;
max_height = 255;
min_sigma = 20000;
max_sigma = 100000;

%create some mountains
[coords1, coords2] = meshgrid(1:size, 1:size);
terrain = zeros(size);
for i = 1:num_hills
    i
    mu = [randi(size) randi(size)];
    height = randi([min_height max_height]);
    sigma = randi([min_sigma, max_sigma]);
    values = mvnpdf([coords1(:) coords2(:)], mu, [sigma sigma]);
    values = reshape(values, size, size);
    terrain = terrain+values*height;
end

%visualization
if visualize == true
    surf(terrain, 'EdgeColor', 'none');
    axis([1 size 1 size 0 max(max(terrain))*1.1]);
    y_grad = diff(terrain);
    x_grad = diff(terrain')';

    %gradient visualization with arrows
    gradient_pos_x = 1:30:size;
    gradient_pos_x = repmat(gradient_pos_x, length(gradient_pos_x), 1);
    gradient_pos_y = gradient_pos_x' * -1;
    selected_gradients_x = x_grad(1:30:end, 1:30:end);
    selected_gradients_y = y_grad(1:30:end, 1:30:end) * -1;
    figure()
    quiver(gradient_pos_x, gradient_pos_y, selected_gradients_x, selected_gradients_y);
    xlim([1 size]);
    ylim([-size -1]);
end

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
%uncomment this to save the created image
%imwrite(img, 'hills.png');



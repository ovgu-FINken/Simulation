%creates a gradient map with the gradients forming a circle around a center
%point
% R: not used
% G: x gradient (0.5 intensity corresponds to 0 gradient)
% B: y gradient

%square size in pixels
size = 1024;

%position of circle center
center = [512 512];

r = zeros(size);
[coords1, coords2] = meshgrid(1:size, 1:size);
x_grad = (center(2) - coords2) * -1;
y_grad = center(1) - coords1; 
%normalize all gradient vectors to same length
magn = sqrt(x_grad .^ 2 + y_grad .^2);
x_grad = x_grad ./ magn;
y_grad = y_grad ./ magn;

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

%normalization for encoding in RGB
total_min = min(min(x_grad(:)), min(y_grad(:)));
total_max = max(max(x_grad(:)), max(y_grad(:)));
x_grad = x_grad / (total_max - total_min)  + 0.5;
y_grad = y_grad / (total_max - total_min)  + 0.5;
figure()
img = zeros(size, size, 3);
img(:, :, 1) = r;
img(:, :, 2) = x_grad;
img(:, :, 3) = y_grad;
imshow(img);
%uncomment this to save the created image
imwrite(img, 'circle.png');
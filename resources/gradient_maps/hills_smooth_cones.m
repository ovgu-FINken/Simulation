%creates a gradient map with some randomly placed hills (cones) makes sure
%the edges fit together to be able to loop around endlessly
% R: height
% G: x gradient (0.5 intensity corresponds to 0 gradient)
% B: y gradient

%square size in pixels
clear all;
size = 1024;

min_height = 80;
max_height = 150;
min_steep = 0.3;
max_steep = 1.4;
max_overlap = round(max_height / min_steep)+10;

%create some mountains
[coords1, coords2] = meshgrid(1-max_overlap:size+max_overlap, 1-max_overlap:size+max_overlap);
coords1 = coords1 + max_overlap;
coords2 = coords2 + max_overlap;
terrain = zeros(size);

%create hills, until we have no more flat terrain
while ~all(all(terrain))
%     candX = coords1(terrain(:) == 0);
%     candY = coords2(terrain(:) == 0);
    mu = [randi(size) randi(size)]+max_overlap;
    height = randi([min_height max_height]);
    steepness = (max_steep - min_steep) * rand() + min_steep;
    hillx = subplus(height - steepness*abs(mu(1) - coords1));
    hilly = subplus(height - steepness*abs(mu(2) - coords2));
    hill_t = (hillx .* hilly).^0.65;
    laps_x = [hill_t((1:size) + max_overlap, max_overlap + size + 1:end), zeros(size, size - 2*max_overlap), hill_t((1:size) + max_overlap, 1:max_overlap)];
    laps_y = [hill_t(max_overlap + size + 1:end, (1:size) + max_overlap); zeros(size - 2*max_overlap, size); hill_t(1:max_overlap, (1:size) + max_overlap)];
    laps_ct = [hill_t(max_overlap + size + 1:end, max_overlap + size + 1:end), zeros(max_overlap, size - 2*max_overlap), hill_t(max_overlap + size + 1:end, 1:max_overlap)];
    laps_cb = [hill_t(1:max_overlap, max_overlap + size + 1:end), zeros(max_overlap, size - 2*max_overlap), hill_t(1:max_overlap, 1:max_overlap)];
    laps_c = [laps_ct; zeros(size - 2*max_overlap, size);laps_cb];
    hill = hill_t(max_overlap + 1:max_overlap + size, max_overlap + 1:max_overlap + size);
    hill = hill + laps_x + laps_y + laps_c;
    terrain = terrain + hill;
    sum(terrain(:) == 0)
end

%visualization
surf(terrain, 'EdgeColor', 'none');

axis([1 size 1 size 0 max(max(terrain))*1.1]);
y_grad = diff(terrain);
x_grad = diff(terrain')';
x_grad(:, size) = terrain(:, 1) - terrain(:, end);
y_grad(size, :) = terrain(1, :) - terrain(end, :);

%normalization for encoding in RGB
total_min = min(min(x_grad(:)), min(y_grad(:)));
total_max = max(max(x_grad(:)), max(y_grad(:)));
max_abs = max(total_max, abs(total_min));
terrain = mat2gray(terrain);
%trading accuracy for encoding efficiency. 0.5 always means zero gradient,
%the absolute maximum is always 1 or 0.
x_grad = x_grad / max_abs * 0.5  + 0.5;
y_grad = y_grad / max_abs * 0.5  + 0.5;
figure()
img = zeros(size, size, 3);
img(:, :, 1) = terrain;
img(:, :, 2) = x_grad;
img(:, :, 3) = y_grad;
imshow(img);
%imwrite(img, 'hills_smooth.png');



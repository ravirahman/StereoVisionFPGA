clear all
close all

% Load the stereo images.
left = imread('Images/Art/view1.png');
right = imread('Images/Art/view5.png');

leftI = mean(left, 3);
%leftI = left;
rightI = mean(right, 3);
%rightI = right;

coordinates = [418, 782; 690, 387; 880, 180; 1000, 842];
[r, num_squares] = size(coordinates);
half_N = 2; % half window size (window size = half_N*2+1)
N = 2*half_N+1;

% perform the block matching
tic()
match_coordinates = perform_block_matching(leftI, rightI, coordinates);
elapsed = toc()

% Visulize the results
figure(100)

subplot(1,2,1)
title('Left')
imshow(left)
%image(leftI)
hold on
% Plot a rectangle for each block we have to match
colors = [0, 0, 0; 1, 0, 0; 0, 1, 0; 0, 0, 1]; % Array of colors
for i = 1:r
    rectangle('Position',[coordinates(i,1)-N/2 ,coordinates(i,2)-N/2, N, N],...
         'LineWidth',3,'LineStyle','--', 'EdgeColor', colors(i,:))
end   

subplot(1,2,2)
title('Right')
imshow(right)
%image(rightI)
hold on
% Plot a rectangle where we found the matching
for i = 1:r
    rectangle('Position',[match_coordinates(i,1)-N/2, match_coordinates(i,2)-N/2, N, N],...
         'LineWidth',3,'LineStyle','--', 'EdgeColor', colors(i,:))
end   

% -----------------------------------------------------------------------

% FUNCTIONS

% This function takes a pair of stereo image and a list of coordinates 
% for bounding boxes in the left image, and performs block matching to 
% find matching blocks in the right image. It returns the coordinates
% of the center of the most similar block in the right image.

% We assume the images are already reconstructed.
% For now, no subpixel accuray (probably not needed because it will make
% the hardware complex)

function right_coords = perform_block_matching(img_left, img_right, left_coords)

% ----------------------------------------------------------------
% Parameters
% img_left: left image
% img_right: right image
% left_coords: left image coordinates of the center of the blocks where 
%              we want to perform block matching on. Two column matrix,
%              where first column is x and second column is y. The number 
%              of rows is the number of bnlocks we want to search

% Note: we are assuming that the blocks are not in the corners
% ----------------------------------------------------------------

% Design choices
half_N = 2; % Window size = 2*half_N+1
N = 2*half_N; % Window size (x and y)
search_range = 200; % how many pixels away from the block's location
   % in the left image to search for a matching block in the right image
unidir_search = 1; % If True, search is unidrectional (only to the left)
                   % If False, search is bidirectional (left and right)


% ----------------------------------------------------------------
[r, foo] = size(left_coords);

right_coords = left_coords*0;

% Iterate over each block to match
for i = 1:r
    
    c = left_coords(i,:);
    x = c(1); y = c(2);
    
    template_block = img_left(y-half_N:y+half_N, x-half_N:x+half_N,:); % The block to match
    %figure
    %imshow(template_block)
    %pause
    
    num_blocks = search_range+1; % Number of blocks to compare the template to
    block_scores = zeros(1,num_blocks); % vector to keep the score for each block
    
    if (unidir_search)
        displacements = -search_range:0;
    else
        displacements = -search_range/2:search_range/2;
    end

    % Iterate over each comparison block and calculate the score
    for j = 1:length(displacements)
       dis = displacements(j);
       compare_block = img_right(y-half_N:y+half_N, x+dis-half_N:x+dis+half_N,:);
       block_scores(j) = calculate_score(template_block, compare_block); 
                         % Use a function so we can change the way the
                         % score is calculated
                         
%        if j == 1 || j == length(displacements)
%            figure
%            dis
%            imshow(compare_block)
%            pause
%        end
    end
    
    %figure
    %plot(displacements, block_scores)
    
    
    % Now we have all the scores. Need to find the highest one
    [~, index] = min(block_scores);
    right_coords(i,:) = [x+displacements(index), y];
    
end



end



% Calculates the score between the two specified blocks
function score = calculate_score(block1, block2)

    % Simple SAD (Sum of Absolute Differences)
    score = sum(sum(sum(abs(block1 - block2))));
    
end
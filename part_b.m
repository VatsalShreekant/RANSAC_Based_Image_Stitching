function mosaic = part_b(im_left, im_right)

if nargin == 0
  im_left=imread('Ryerson-left.jpg');
  im_right=imread('Ryerson-right.jpg');
end

im_left = im2single(im_left);
im_right = im2single(im_right);
sizeOfImg_left=size(im_left,3);
sizeOfImg_right=size(im_right,3);

img_left = rgb2gray(im_left);
img_right = rgb2gray(im_right);


[fa,da] = vl_sift(img_left);
[fb,db] = vl_sift(img_right);

% perm_left = randperm(size(fa,2));
% sel_left = perm_left(1:2);
% h1_left = vl_plotframe(fa(:,sel_left));
% h2_left = vl_plotframe(fa(:,sel_left));
% set(h1_left,'color','k','linewidth',3);
% set(h2_left,'color','y','linewidth',2);
% h3_left = vl_plotsiftdescriptor(da(:,sel_left),fa(:,sel_left));
%figure(1);
%set(h3_left,'color','g') ;

[matches, scores] = vl_ubcmatch(da,db);

num_Of_Matches = size(matches,2);

x_coord = fa(1:2,matches(1,:)); 
x_coord(3,:) = 1;
y_coord = fb(1:2,matches(2,:)); 
y_coord(3,:) = 1;
clear H;
clear score;
clear ideal;
for iterations = 1:90
  % estimate homograpyh
  column_subset = vl_colsubset(1:num_Of_Matches, 4);
  A = [];
  for i = column_subset
    tensor_product = kron(x_coord(:,i)', vl_hat(y_coord(:,i)));
    A = cat(1, A, tensor_product);
  end
  [U,S,V] = svd(A);
  H{iterations} = reshape(V(:,9),3,3);
  cell_array_H = H{iterations};
  x_coordinate = cell_array_H * x_coord;
  U_derivative = x_coordinate(1,:)./x_coordinate(3,:);
  U_derivative= U_derivative - y_coord(1,:)./y_coord(3,:);
  V_derivative = x_coordinate(2,:)./x_coordinate(3,:);
  V_derivative = V_derivative - y_coord(2,:)./y_coord(3,:);
  ideal{iterations} = (U_derivative.*U_derivative + V_derivative.*V_derivative) < 36;
  cell_array_ideal = ideal{iterations};
  score(iterations) = sum(ideal{iterations});
end
[score, best] = max(score);
H = H{best};
ideal = ideal{best};
function error_func = residual(H)
 u = H(1) * x_coord(1,ideal);
 u = u + H(4) * x_coord(2,ideal);
 u = u + H(7);
 v = H(2) * x_coord(1,ideal);
 v = v + H(5) * x_coord(2,ideal);
 v = v  + H(8);
 db = H(3) * x_coord(1,ideal);
 db = db + H(6);
 db = db .* x_coord(2,ideal) + 1;
 U_derivative = y_coord(1,ideal) - u;
 U_derivative = U_derivative ./ db;
 V_derivative = y_coord(2,ideal) - v;
 V_derivative = V_derivative ./ db;
 sum_value = U_derivative.*U_derivative;
 sum_value = sum_value + V_derivative.*V_derivative;
 error_func = sum(sum_value);
end
im2_dim1_length = size(im_right,1);
im1_dim1_length = size(im_left,1);


h_derivative_1 = max(im2_dim1_length-im1_dim1_length,0);
h_derivative_2 = max(im1_dim1_length-im2_dim1_length,0);

figure(1); 
clf;
subplot(2,1,1);
padded_array_1 = padarray(im_left,h_derivative_1,'post');
padded_array_2 = padarray(im_right,h_derivative_2,'post');
fa_matches_ind_1 = fa(1,matches(1,:));
fa_macthes_ind_2 = fa(2,matches(1,:));
fa_matches_ideal_ind_1 = fa(1,matches(1,ideal));
fa_matches_ideal_ind_2 = fa(2,matches(1,ideal));
fb_matches_ind_1 = fb(1,matches(2,:));
fb_matches_ind_2 = fb(2,matches(2,:));
fb_matches_ideal_ind_1 = fb(1,matches(2,ideal));
fb_matches_ideal_ind_2 = fb(2,matches(2,ideal));
imagesc([padded_array_1 padded_array_2]);
ideal_sum = sum(ideal);
sum_percentage_val = (100*ideal_sum);
sum_percentage_val = sum_percentage_val/num_Of_Matches;
im1_dim2_length = size(im_left,2);
line([fa_matches_ind_1;fb_matches_ind_1+im1_dim2_length],[fa_macthes_ind_2;fb_matches_ind_2]);
title(sprintf('%d Matching Features', num_Of_Matches));
axis image off;

subplot(2,1,2);
imagesc([padded_array_1 padded_array_2]);
%im1_dim2_length = size(im_left,2);
line([fa_matches_ideal_ind_1;fb_matches_ideal_ind_1+im1_dim2_length],[fa_matches_ideal_ind_2;fb_matches_ideal_ind_2]);
title(sprintf('%d (%.2f%%) Total inliner from %d',ideal_sum,sum_percentage_val,num_Of_Matches)) ;
axis image off;
drawnow;

im1_dim1_length = size(im_left,1);
im1_dim2_length = size(im_left,2);
im2_dim1_length = size(im_right,1);
im2_dim2_length = size(im_right,2);
img2_corner = [1 im2_dim2_length im2_dim2_length  1; 1 1 im2_dim1_length im2_dim1_length; 1 1 1 1 ];
img2_corner_ = inv(H);
img2_corner_ = img2_corner_ * img2_corner;
img2_corner_(1,:) = img2_corner_(1,:) ./ img2_corner_(3,:);
img2_corner_(2,:) = img2_corner_(2,:) ./ img2_corner_(3,:);
img_left_casting = im2double(im_left);
img_right_casting = im2double(im_right);
u_max = max([im1_dim2_length img2_corner_(1,:)]);
u_min = min([1 img2_corner_(1,:)]);
v_min = min([1 img2_corner_(2,:)]);
v_max = max([im1_dim1_length img2_corner_(2,:)]);
ur = u_min:u_max;vr = v_min:v_max;[u,v] = meshgrid(ur,vr);
im1_ = vl_imwbackward(img_left_casting,u,v);

z_val = H(3,1) * u;
z_val = z_val + (H(3,2) * v);
z_val =  z_val + H(3,3);
u_val = H(1,1) * u;
u_val = u_val + H(1,2) * v;
u_val = (u_val+ H(1,3)) ./ z_val;
v_val = H(2,1) * u;
v_val = v_val + H(2,2) * v;
v_val = (v_val + H(2,3)) ./ z_val;
im2_ = vl_imwbackward(img_right_casting,u_val,v_val);
mass = ~isnan(im1_) + ~isnan(im2_);
im1_(isnan(im1_)) = 0;
im2_(isnan(im2_)) = 0;
mosaic = (im1_ + im2_) ./ mass;

figure(2); 
clf;
imagesc(mosaic); 
axis image off;
title('Mosaic');

if nargout == 0, clear mosaic; 
end

end
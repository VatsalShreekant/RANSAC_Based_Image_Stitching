# RANSAC_Based_Image_Stitching
This application writes a simple mosaic/panorama algorithm. A panorama is a wide-angle image constructed by compositing together a number of images with overlapping fields-of-views in a photographically plausible way.

## Mosaic based on an affine transformation:

The following two sample Parliament images are loaded:
![Capture](https://user-images.githubusercontent.com/32462270/117908817-1fef6f80-b2a7-11eb-9d12-95f13087babf.PNG)


The stitching is performed based on the following steps:
1. Preprocessing: Load 2 sample images, convert to single and to grayscale.
2. Detect keypoints and extract descriptors: Compute image features in both images. The feature detector and descriptor to be used is SIFT. The  VLFeat library is publicly available to compute SIFT features.
3. Match features: Compute distances between every SIFT descriptor in one image and every descriptor in the other image.
4. Prune features: Select the closest matches based on the matrix of pairwise descriptor distances obtained above.
5. Robust transformation estimation: Implement RANSAC to estimate an affine transformation mapping one image to the other. Use the minimum number of pairwise matches to estimate the affine transformation. Since the minimum number of pairwise points are being used, the transformation can be estimated using an inverse transformation rather than least-squares.
6. Compute optimal transformation: Using all the inliers of the best transformation found using RANSAC (i.e., the one with the most inliers), compute the final transformation with least-squares.
7. Create panorama: Using the final affine transformation recovered using RANSAC, generate the final mosaic and display the color mosaic result to the screen.

Affine panorama result using the Parliament images:
![Capture](https://user-images.githubusercontent.com/32462270/117909419-34803780-b2a8-11eb-897b-7cf92ce2d75c.PNG)

## Panorama based on a homography transformation:
The following two sample Egerton Ryerson statue images are loaded:
![Capture](https://user-images.githubusercontent.com/32462270/117909677-ace6f880-b2a8-11eb-8aa9-761a874b8537.PNG)

The panorama based on a homography transformation is performed based on the following steps:
1. Rreuse the code from Mosaic but swap out the parts that refer to the affine transformation with the homography.
2. The minimum number of point correspondences to estimate a homography is four. Using a homography yields a set of homogeneous linear equations, AX = 0. The solution to both the system of homogeneous equations consisting of four point correspondences and homogeneous least squares is obtained from the singular value decomposition (SVD) of A by the singular vector corresponding to the smallest singular value: [U,S,V]=svd(A); X = V(:,end).
3. Display the color mosaic result to the screen: Using the RANSAC-based homography code generate the mosaic using the Egerton Ryerson images.

Hhomography panorama result using the Egerton Ryerson statue images:
![image](https://user-images.githubusercontent.com/32462270/117910064-457d7880-b2a9-11eb-939a-82dc8c01f1b0.png)


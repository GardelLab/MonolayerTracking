# MonolayerTracking


Tracking code associated with the manuscript Cell cycle-dependent active stress drives epithelia remodeling doi: https://doi.org/10.1101/804294 

Code written by John Devany - jdevany@uchicago.edu

Code can be run on matlab and requires several scripts available on the matlab file exchange:

Phase Stretch Transform - https://www.mathworks.com/matlabcentral/fileexchange/55330-jalalilabucla-image-feature-detection-using-phase-stretch-transform

Simple Tracker - https://www.mathworks.com/matlabcentral/fileexchange/34040-simpletracker

Edge Linking and Line Segment Fitting - https://www.peterkovesi.com/matlabfns/

Uniform colormaps - https://www.mathworks.com/matlabcentral/fileexchange/51986-perceptually-uniform-colormaps


Overview of the functions:

Segmentation:

outlineCells13t - function for segmenting cell images. Mainly based on PST to generate initial segmentation then cleans up partial edges and filters out some potential segmentation errors. Includes optimized parameters for 20x images of MDCK stargazin gfp used in the paper.

findendsjunctions2 - modified version of findendsjunction from Peter Kovesi 

filledgegaps4 - modified version of filledgegaps from Peter Kovesi, uses and anisotropic blob instead of a circular blob to connect edges. Since the junctions are straight lines this works better than a round blob. 

outlinecellstack - runs outlinecells13t over an image stack and saves segmented images

outlineFnuc - uses PST to segment nuceli from fucci labeled cells. runs on an image stack and produces a stack of segmented images

Tracking:

cellTrackingMDCK20ar3 - tracking function to measure cell displacements from segmented image stacks uses simpleTracker to determine cell trajectories from the centroids. 2 initial tracking steps remove mean displacement from stage drift. Code generates list of cell displacements and shapes (v0) and average properties (v1) and output images of cell speed area and displacement as heatmaps.

measureperimTPV3- computes the perimeter and area of objects using the three pixel vector method based on Inoue and Kimura 1987 (https://doi.org/10.1016/0308-9126(87)90245-8)

generatethreepixelclasses - subfunction of measureperimTPV3 which input the different edge lenth corrections

frameAvg - averages image frames for output images

classifyendpoints - finds the cell verticies

filtavg - averages values excluding outliers

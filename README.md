# PreprocessData.jl

The Julia package `PreprocessData.jl` provides tools to download and preprocess tabular and image datasets. Its goal is to provide various datasets in an uniformed format.

Package contains several tabular and image datasets, but adding new dataset can be easily done.

## Tabular datasets
 
The output format of tabular data is either a `DataFrame`, where rows are samples and columns are features, last column being the labels; or an `Array` with samples and features and a `Vector` with labels.

### How to add a new dataset
To add a new tabular dataset a little information about it is needed. This information is to be saved to a `.jl` file into this package folder which is located in `~/.julia/packages/PreprocessData/src/datasets/tabular`.


# PreprocessData.jl

The Julia package `PreprocessData.jl` provides tools to download and preprocess tabular and image datasets. Its goal is to provide various datasets in an uniformed format.

Package contains several tabular and image datasets, but adding new dataset can be easily done.

## Tabular datasets
 
The output format of tabular data is either a `DataFrame`, where rows are samples and columns are features, last column being the labels; or an `Array` with samples and features and a `Vector` with labels.

### How to add a new tabular dataset
Adding new dataset is illustrated on a non-existing Example dataset.

To add a new tabular dataset a little information about it is needed. This information is to be saved to a `.jl` file into this package folder which is located in `~/.julia/packages/PreprocessData/src/datasets/tabular`, name of this file is the name of the dataset (here we use Example dataset, so the name of the file is example.jl)

#### **Mandatory information for every dataset:**
```julia
struct Example <: Tabular end
url(::Example) = "http://url.address.to.file.csv"
prep(::Example) = path -> preprocess(path, Example())
```
> prep function has to be in this format, some modification are possible.
> - If the downloading file is compressed write `path -> preprocess(extract(path), Example())`.
> - If the file needs some editing, one can add keyword arguments that are supported in CSV.File()function, see the [CSV.jl](https://csv.juliadata.org/stable/) documentation. `path -> preprocess(path, Example(), kwargs...)`
```julia
target(::Example) = 5
```
> Number of column with labels or write `FileLabels` if labels are in a separate file.
```julia
size(::Example) = (150, 0, 0)
```     
> Number of instances of (train, valid, test) data
```julia
problem(::Iris) = Classification
```
Type of problem `Classification` or `Regression`

#### **Other information:**
```julia
checksum(::Example) = "6f608b71a7317216319b4d27b4d9bc84e6abd734eda7872b71a458569e2656c0"
```
> Checksum is not mandatory, however if it is not obtained, warning will be displayed. If checksum is not known, it will be provided after the first download, then needs to be copied to the `example.jl` file.
```julia
headers(::Example) = ["Age", "Height", "Weight", "Target"]
```
> If known can be written to a `Tuple`.
```julia
categorical(::Example) = 1:3
```
> If dataset contains columns with categorical variables, the columns will be labeled, if numbers of the columns are provided. It can be one number, vector of numbers or a range.
```julia
message(::Example) = "Example dataset was created by me."
```
> Additional information about the dataset, that is displayed before downloading.

## Image datasets
Package currently supports image datasets from [MLDatasets.jl](https://juliaml.github.io/MLDatasets.jl/stable/).
For other image datasets new types and methods has to be written. For every (even new type) dataset `size(::Example)` has to be defined.


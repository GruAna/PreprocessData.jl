module PreprocessData

using DataDeps, DataFrames, CSV, InteractiveUtils, Random
using MLDatasets
using InteractiveUtils: subtypes
using LinearAlgebra: norm
using Statistics: mean, std

export L2, MinMax, Std
export Train, Valid, Test
export Image, Tabular, GrayImage, ColorImage, Regression, Classification

export split_traintest, split_trainvalidtest
export load, df_to_array
export normalize!, meanstd, minmax, l2norm
export binarize, classes

export listdatasets, info, remove

const DATASET_DIR_TAB = joinpath(@__DIR__, "datasets/tabular")
const DATASET_DIR_IMG = joinpath(@__DIR__, "datasets/image")

include("types.jl")
include("utils.jl")
include("tabular.jl")
include("image.jl")
include("registering.jl")
include("preprocess.jl")
include("split.jl")
include("postprocess.jl")
include("infos.jl")

scriptfiles = [readdir(DATASET_DIR_TAB; join = true); readdir(DATASET_DIR_IMG; join = true)]
for s in scriptfiles
    splitext(s)[2] == ".jl" && include(s)
end

function __init__()
    for T in InteractiveUtils.subtypes(Tabular)
        registering(T())
    end
end
end # module

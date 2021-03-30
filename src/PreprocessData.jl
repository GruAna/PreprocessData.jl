module PreprocessData

using DataDeps, DataFrames, CSV, InteractiveUtils, Random
using MLDatasets

export call
export split_traintest, split_trainvalidtest

const DATASET_DIR_TAB = joinpath(@__DIR__, "datasets/tabular")
const DATASET_DIR_IMG = joinpath(@__DIR__, "datasets/image")

include("types.jl")
include("utils.jl")
include("tabular.jl")
include("image.jl")
include("preprocessing.jl")
include("split.jl")

include.(readdir(DATASET_DIR_TAB; join = true))
include.(readdir(DATASET_DIR_IMG; join = true))

function __init__()
    for T in InteractiveUtils.subtypes(Tabular)
        registering(T())
    end
end
end # module

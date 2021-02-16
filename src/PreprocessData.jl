module PreprocessData

using DataDeps, DataFrames, CSV, InteractiveUtils, Random

export call
export split_traintest, split_trainvalidtest

const DATASET_DIR = joinpath(@__DIR__, "datasets")

include("utils.jl")
include("split.jl")
include("preprocessing.jl")

include.(readdir(DATASET_DIR; join = true))

function __init__()
    for T in InteractiveUtils.subtypes(DatasetName)
        registering(T())
    end
end
end # module

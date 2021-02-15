module PreprocessData

using DataDeps, DataFrames, CSV, Random, InteractiveUtils

export call_dataset

const datasets_dir = joinpath(@__DIR__, "datasets")

include("errors.jl")
include("split.jl")
include("preprocessing.jl")

include.(readdir(datasets_dir; join = true))

function __init__()
    for T in InteractiveUtils.subtypes(DatasetName)
        registering_dataset(T())
    end
end
end # module

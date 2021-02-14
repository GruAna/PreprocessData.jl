module PreprocessData

using DataDeps, DataFrames, CSV, Random

export call_dataset

const datasets_dir = joinpath(@__DIR__, "datasets")

include("errors.jl")
include("split.jl")
include("preprocessing.jl")

end # module

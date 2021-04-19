struct Nuclear <: Tabular end
url(::Nuclear) = "https://github.com/JuliaStats/RDatasets.jl/raw/master/data/boot/nuclear.csv.gz"
checksum(::Nuclear) = "0283f0f95a2df8e66ea40035483b6dcecb11fd856823f190ea943d774d0b9a44"
preprocess(::Nuclear) = path -> preprocess(extract(path), Nuclear(), header = true)
target(::Nuclear) = 11
size(::Nuclear) = (32, 0, 0)
problem(::Nuclear) = Classification

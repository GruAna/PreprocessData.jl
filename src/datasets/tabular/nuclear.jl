struct Nuclear <: Tabular end
url(::Nuclear) = "https://github.com/JuliaStats/RDatasets.jl/raw/master/data/boot/nuclear.csv.gz"
checksum(::Nuclear) = "0283f0f95a2df8e66ea40035483b6dcecb11fd856823f190ea943d774d0b9a44"
prep(::Nuclear) = path -> preprocess(extract(path), Nuclear())
target(::Nuclear) = 1
headers(::Nuclear) = 1
size(::Nuclear) = (32, 0, 0)
problem(::Nuclear) = Regression
message(::Nuclear) = "Nuclear Power Station Construction Data"

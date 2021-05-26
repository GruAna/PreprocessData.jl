struct Ionosphere <: Tabular end
url(::Ionosphere) = "https://archive.ics.uci.edu/ml/machine-learning-databases/ionosphere/ionosphere.data"
checksum(::Ionosphere) = "46d52186b84e20be52918adb93e8fb9926b34795ff7504c24350ae0616a04bbd"
prep(::Ionosphere) = path -> preprocess(path, Ionosphere())
target(::Ionosphere) = 35
size(::Ionosphere) = (351, 0, 0)
problem(::Ionosphere) = Classification

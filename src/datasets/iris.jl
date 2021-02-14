struct Iris <: DatasetName end
url(::Iris) = "http://archive.ics.uci.edu/ml/machine-learning-databases/iris/iris.data"
checksum(::Iris) = "6f608b71a7317216319b4d27b4d9bc84e6abd734eda7872b71a458569e2656c0"
preprocess(::Iris) = path -> preprocess(path, name(Iris()), target_col = 5 )
sampleSize(::Iris) = (150,)
push!(dict, "iris" => Iris())
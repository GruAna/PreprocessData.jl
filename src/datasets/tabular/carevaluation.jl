struct CarEvaluation <: Tabular end
url(::CarEvaluation) = "http://archive.ics.uci.edu/ml/machine-learning-databases/car/car.data"
checksum(::CarEvaluation) = "b703a9ac69f11e64ce8c223c0a40de4d2e9d769f7fb20be5f8f2e8a619893d83"
prep(::CarEvaluation) = path -> preprocess(path, CarEvaluation())
target(::CarEvaluation) = 7
categorical(::CarEvaluation) = 1:6
size(::CarEvaluation) = (1728, 0, 0)
problem(::CarEvaluation) = Classification

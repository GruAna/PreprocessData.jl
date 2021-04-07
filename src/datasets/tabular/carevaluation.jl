struct Carevaluation <: Tabular end
url(::Carevaluation) = "http://archive.ics.uci.edu/ml/machine-learning-databases/car/car.data"
checksum(::Carevaluation) = "b703a9ac69f11e64ce8c223c0a40de4d2e9d769f7fb20be5f8f2e8a619893d83"
preprocess(::Carevaluation) = path -> preprocess(path, Carevaluation(), categorical_cols = 1:6 )
target(::Carevaluation) = 7
size(::Carevaluation) = (1728, 0, 0)
problem(::Carevaluation) = Classification

struct CarEvaluation <: DatasetName end
url(::CarEvaluation) = "http://archive.ics.uci.edu/ml/machine-learning-databases/car/car.data"
checksum(::CarEvaluation) = "b703a9ac69f11e64ce8c223c0a40de4d2e9d769f7fb20be5f8f2e8a619893d83"
preprocess(::CarEvaluation) = path -> preprocess(path, datasettype(CarEvaluation()), target_col = 7, categorical_cols = 1:6 )
size(::CarEvaluation) = (1728, 0, 0)
datasettype(::CarEvaluation) = Tabular

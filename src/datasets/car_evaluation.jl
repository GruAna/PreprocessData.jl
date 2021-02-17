struct Car_evaluation <: DatasetName end
url(::Car_evaluation) = "http://archive.ics.uci.edu/ml/machine-learning-databases/car/car.data"
checksum(::Car_evaluation) = "b703a9ac69f11e64ce8c223c0a40de4d2e9d769f7fb20be5f8f2e8a619893d83"
preprocess(::Car_evaluation) = path -> preprocess(path, name(Car_evaluation()), target_col = 7, categorical_cols = 1:6 )
sampleSize(::Car_evaluation) = (1728,)

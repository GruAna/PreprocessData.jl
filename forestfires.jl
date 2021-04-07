struct Forestfires <: Tabular end
url(::Forestfires) = "https://archive.ics.uci.edu/ml/machine-learning-databases/forest-fires/forestfires.csv"
checksum(::Forestfires) = ""
preprocess(::Forestfires) = path -> preprocess(path, Forestfires(), categorical_cols = [3;4])
target(::Forestfires) = 13
size(::Forestfires) = (517, 0, 0)
problem(::Forestfires) = Regression

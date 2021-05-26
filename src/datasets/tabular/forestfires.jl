struct Forestfires <: Tabular end
url(::Forestfires) = "https://archive.ics.uci.edu/ml/machine-learning-databases/forest-fires/forestfires.csv"
checksum(::Forestfires) = "0d6586a1fa52f55bef48578aef14eb97273f1e9330e1a53423df497a77065253"
prep(::Forestfires) = path -> preprocess(path, Forestfires())
target(::Forestfires) = 13
headers(::Forestfires) = 1
categorical(::Forestfires) = [3;4]
size(::Forestfires) = (517, 0, 0)
problem(::Forestfires) = Regression

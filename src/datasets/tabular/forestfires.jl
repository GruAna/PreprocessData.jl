struct ForestFires <: Tabular end
url(::ForestFires) = "https://archive.ics.uci.edu/ml/machine-learning-databases/forest-fires/forestfires.csv"
checksum(::ForestFires) = "0d6586a1fa52f55bef48578aef14eb97273f1e9330e1a53423df497a77065253"
prep(::ForestFires) = path -> preprocess(path, ForestFires())
target(::ForestFires) = 13
headers(::ForestFires) = 1
categorical(::ForestFires) = [3;4]
size(::ForestFires) = (517, 0, 0)
problem(::ForestFires) = Regression

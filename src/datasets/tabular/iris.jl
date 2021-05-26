struct Iris <: Tabular end
url(::Iris) = "http://archive.ics.uci.edu/ml/machine-learning-databases/iris/iris.data"
checksum(::Iris) = "6f608b71a7317216319b4d27b4d9bc84e6abd734eda7872b71a458569e2656c0"
prep(::Iris) = path -> preprocess(path, Iris())
target(::Iris) = 5
size(::Iris) = (150, 0, 0)
headers(::Iris) = ["sepal length", "sepal width", "petal length", "petal width", "class"]
problem(::Iris) = Classification

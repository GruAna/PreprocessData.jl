struct Abalone <: Tabular end
url(::Abalone) = "https://archive.ics.uci.edu/ml/machine-learning-databases/abalone/abalone.data"
checksum(::Abalone) = "de37cdcdcaaa50c309d514f248f7c2302a5f1f88c168905eba23fe2fbc78449f"
prep(::Abalone) = path -> preprocess(path, Abalone())
target(::Abalone) = 9
categorical(::Abalone) = 1
size(::Abalone) = (4177, 0, 0)
problem(::Abalone) = Regression

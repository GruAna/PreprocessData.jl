struct Pokus <: Tabular end
url(::Pokus) = "https://archive.ics.uci.edu/ml/machine-learning-databases/abalone/abalone.data"
checksum(::Pokus) = "de37cdcdcaaa50c309d514f248f7c2302a5f1f88c168905eba23fe2fbc78449f"
preprocess(::Pokus) = path -> preprocess(path, Abalone())
target(::Pokus) = 1
transposed(::Pokus) = true
size(::Pokus) = (3, 0, 0)
problem(::Pokus) = Regression

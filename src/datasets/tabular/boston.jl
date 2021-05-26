struct Boston <: Tabular end
url(::Boston) = "https://raw.githubusercontent.com/JuliaML/MLDatasets.jl/master/src/BostonHousing/boston_housing.csv"
checksum(::Boston) = "98134236b4a7c71da63ada2de5a11f985afa9f21df6f5a952429ca7f66a0abc7"
prep(::Boston) = path -> preprocess(path, Boston())
target(::Boston) = 14
headers(::Boston) = 1
categorical(::Boston) = 9
size(::Boston) = (506, 0, 0)
problem(::Boston) = Regression
message(::Boston) = "Boston Housing Dataset"

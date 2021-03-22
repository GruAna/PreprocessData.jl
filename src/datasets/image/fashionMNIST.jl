struct FashionMNIST <: MLImage end
getModule(::FashionMNIST) = MLDatasets.FashionMNIST
size(::FashionMNIST) = (60000, 0, 10000)

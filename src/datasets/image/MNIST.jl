struct MNIST <: MLImage end
getModule(::MNIST) = MLDatasets.MNIST
size(::MNIST) = (60000, 0, 10000)

struct CIFAR10 <: MLImage end
getModule(::CIFAR10) = MLDatasets.CIFAR10
size(::CIFAR10) = (50000, 0, 10000)

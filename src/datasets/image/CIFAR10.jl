struct CIFAR10 <: ColorImage{MLImage} end
getModule(::CIFAR10) = MLDatasets.CIFAR10
size(::CIFAR10) = (50000, 0, 10000)
problem(::CIFAR10) = Classification

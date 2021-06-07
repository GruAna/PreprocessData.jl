struct CIFAR100 <: ColorImage{MLImage} end
getModule(::CIFAR100) = MLDatasets.CIFAR100
size(::CIFAR100) = (50000, 0, 10000)
problem(::CIFAR100) = Classification

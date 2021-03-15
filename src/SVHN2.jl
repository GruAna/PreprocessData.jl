struct SVHN2 <: Image end
getModule(::SVHN2) = MLDatasets.SVHN2
size(::SVHN2) = (73257, 0, 26032)

abstract type DatasetName end
abstract type Tabular <: DatasetName end
abstract type Image <: DatasetName end
# abstract type GrayImage <: Image end
# abstract type ColorImage <: Image end
abstract type MLImage <: Image end

abstract type Problem end
abstract type Classification <: Problem end
abstract type Regression <: Problem end

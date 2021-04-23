abstract type DatasetName end
abstract type Tabular <: DatasetName end

abstract type ImageType end
abstract type MLImage <: ImageType end

abstract type Image{T <: ImageType} <: DatasetName end
abstract type GrayImage{T <: ImageType} <: Image{T} end
abstract type ColorImage{T <: ImageType} <: Image{T} end


abstract type Problem end
abstract type Classification <: Problem end
abstract type Regression <: Problem end

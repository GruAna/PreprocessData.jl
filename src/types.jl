# ---------------------------------- Type of datasets ---------------------------------- */

abstract type DatasetName end
abstract type Tabular <: DatasetName end

abstract type ImageType end
abstract type MLImage <: ImageType end

abstract type Image{T <: ImageType} <: DatasetName end
abstract type GrayImage{T <: ImageType} <: Image{T} end
abstract type ColorImage{T <: ImageType} <: Image{T} end

# -------------------------------------------------------------------------------------- */
abstract type File end
abstract type Labels <: File end
abstract type Header <: File end

abstract type Problem end
abstract type Classification <: Problem end
abstract type Regression <: Problem end

abstract type Normalization end
abstract type L2 <: Normalization end
abstract type Std <: Normalization end
abstract type MinMax <: Normalization end

abstract type Split end
abstract type Train <: Split end
abstract type Valid <: Split end
abstract type Test <: Split end

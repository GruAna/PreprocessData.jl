function getModule(::Image{MLImage}) end
name(dataset::Image{MLImage}) = String(nameof(typeof(dataset)))
function url(dataset::Image{MLImage})
    text = "URL address for $dataset can be found in MLDatasets.jl."
    @info text
    return text
end
function checksum(dataset::Image{MLImage})
    text = "Checksum address for $dataset can be found in MLDatasets.jl."
    @info text
    return text
end

target(dataset::Image{MLImage}) = @info "Target for $dataset can be obtained by loading the whole data."

# ---------------------------- Util functions for splitting ---------------------------- */

"""
    getdata(dataset::Image{MLImage}, type::Type{<:Split})

Returns data from dataset. `type` is either `Train` or `Test.`
"""
function getdata(dataset::Image{MLImage}, type::Type{Train})
    datadep = getModule(dataset)
    return datadep.traindata()
end

function getdata(dataset::Image{MLImage}, type::Type{Test})
    datadep = getModule(dataset)
    return datadep.testdata()
end

getdata(dataset::Image{MLImage}, type::Type{Valid}) = error("No valid data in image datasets from MLDatasets.jl.")

"""
    load(dataset::Image, type::Symbol; kwargs...)

Loads dataset of given type.

- `type::Type{<:Split}=Train`: other possible type is `Test`.
"""
load(dataset::Image{<:ImageType}, type::Type{<:Split}=Train) = getdata(dataset, type)

"""
    splits(dataset::Image{MLImage}, data, indeces1, indeces2)

Devides `data` from `dataset` to two parts.
"""
function splits(dataset::Image{MLImage}, data,  indeces1, indeces2)
    datadep = getModule(dataset)
    return datadep.traindata(indeces1), datadep.traindata(indeces2)
end

"""
    postprocess(dataset::Image{MLImage}, data...)

Returns image data.
"""
function postprocess(dataset::Image{MLImage}, data...; kwargs...)
    return data
end

"""
    labels(dataset::MLImage)

Returns train label array for given dataset.
"""
function labels(dataset::MLImage)
    datadep = getModule(dataset)
    return datadep.trainlabels()
end

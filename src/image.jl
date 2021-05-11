function getModule(::Image{MLImage}) end
name(dataset::Image{MLImage}) = String(nameof(typeof(dataset)))

# ---------------------------- Util functions for splitting ---------------------------- */

"""
    getdata(dataset::Image{MLImage}, type::Symbol)

Returns data from dataset. `type` is either `:train` or `:test.`
"""
function getdata(dataset::Image{MLImage}, type::Symbol=:train)
    datadep = getModule(dataset)
    if type == :train
        return datadep.traindata()
    elseif type == :test
        return datadep.testdata()
    else
        throw(ArgumentError("Unknown type of data."))
    end
end

"""
    load(dataset::Image, type::Symbol; kwargs...)

Loads dataset of given type.

- `type::Symbol`: default type is `:train`, other possible types are `test` and `valid`.
"""
load(dataset::Image{<:ImageType}, type::Symbol=:train) = getdata(dataset, type)

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

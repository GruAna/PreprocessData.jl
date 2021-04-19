function getModule(::Image) end
name(dataset::MLImage) = String(nameof(typeof(dataset)))

# ---------------------------- Util functions for splitting ---------------------------- */

"""
    getdata(dataset::MLImage, type::Symbol)

Returns data from dataset. `type` is either `:train` or `:test.`
"""
function getdata(dataset::MLImage, type::Symbol=:train)
    datadep = getModule(dataset)
    if type == :train
        return datadep.traindata()
    elseif type == :test
        return datadep.testdata()
    else
        throw(ArgumentError("Unknown type of data."))
    end
end

load(dataset::Image, type::Symbol=:train) = getdata(dataset, type)

"""
    splits(dataset::MLImage, data, indeces1, indeces2)

Devides `data` from `dataset` to two parts.
"""
function splits(dataset::MLImage, data,  indeces1, indeces2)
    datadep = getModule(dataset)
    return datadep.traindata(indeces1), datadep.traindata(indeces2)
end

"""
    postprocess(dataset::Image, data...; kwargs...)

Returns image data. Kwargs are empty.
"""

function postprocess(dataset::Image, data...; kwargs...)
    return data
end

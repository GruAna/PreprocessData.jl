# --------------------- Functions for normalizing tabular datasets --------------------- */
"""
    normalize!(type::Type{Std}, data, mean, std; kwargs...)

Returns standardized data by the specified mean and standard deviation.

If `data` is an `AbstractArray`, in keyword argument `dims` dimensions can be specified
over which mean and standard deviation are computed.
"""
function normalize!(type::Type{Std}, data, mean, std; kwargs...)
    change!(data, mean, std)
    return
end

"""
    normalize!(type::Type{Std}, data; kwargs...)

Returns standardized data by the mean and variance of `data`.

If `data` is an `AbstractArray`, in keyword argument `dims` dimensions can be specified
over which mean and standard deviation are computed.
"""
function normalize!(type::Type{Std}, data; kwargs...)
    mean, std = meanstd(data; kwargs...)
    normalize!(type, data, mean, std; kwargs...)
    return
end

"""
    normalize!(type::Type{MinMax}, data, min, max; kwargs...)

Returns min-max scaled data based on specified minimum and maximum values.

If `data` is an `AbstractArray`, in keyword argument `dims` dimensions can be specified
over which (columns or rows) minimum and maximum are computed.
"""
function normalize!(type::Type{MinMax}, data, min, max; kwargs...)
    change!(data, min, max)
    return
end

"""
    normalize!(type::Type{MinMax}, data; kwargs...)

Returns min-max scaled data based on minimum and maximum values from `data`.

If `data` is an `AbstractArray`, in keyword argument `dims` dimensions can be specified
over which mean and standard deviation are computed.
"""
function normalize!(type::Type{MinMax}, data; kwargs...)
    min, max = minmax(data; kwargs...)
    normalize!(type, data, min, max; kwargs...)
    return
end

"""
    normalize!(type::Type{L2}, data, norm)

Returns normalized data by the specified `norm`.

If `data` is an `AbstractArray`, in keyword argument `dims` dimensions can be specified
over which norm is computed. For more see [`l2norm`](@ref)
"""

function normalize!(type::Type{L2}, data, norm; kwargs...)
    change!(data, norm)
    return
end

"""
    normalize!(type::Type{L2}, data; kwargs...)

Returns normalized data by the Euclidan norm of `data` elements.

If `data` is an `AbstractArray`, in keyword argument `dims` dimensions can be specified
over which mean and standard deviation are computed.
"""
function normalize!(type::Type{L2}, data; kwargs...)
    norm = l2norm(data; kwargs...)
    normalize!(type, data, norm; kwargs...)
    return
end

function normalize!(data; kwargs...)
    error("Type of normalization not specified, try Std, MinMax or L2.")
end

# ------------------ Util functions for normalizing tabular datasets ------------------- */
"""
    _select(data, selection)

    Returns data, range specified by `selection`.
"""
_select(data::AbstractArray, selection) = data[selection[1], selection[2]]

_select(data::AbstractDataFrame, selection) = data[!, selection]

"""
    meanstd(data; dims::Int=1)

Returns mean and standard deviation of columns or rows of given `data`.

Mean and standard deviation are returned in a row vector (`Tuple` of two `1xn Matrix`).

`data` can be an `AbstractArray` or `AbstractDataFrame`.
If `data` is an `AbstractArray`, a keyword argument `dims` can be provided to compute values
over dimensions.

This function uses `mean` and `std` from the package `Statistics`.
"""
function meanstd(data::AbstractArray; dims::Int=1)
    selected = _select(data, selectnumeric(data; dims=dims))
    mean(selected; dims=dims), std(selected; dims=dims)
end
function meanstd(data::AbstractDataFrame)
    selected = _select(data, selectnumeric(data))
    mean.(eachcol(selected)), std.(eachcol(selected))
end

"""
    minmax(data; dims::Int=1)

Returns minimum and maximum of columns or rows of given `data`.
If `data` is an `AbstractArray`, `dims` specifies whether it is over columns or rows.
"""
function minmax(data::AbstractArray; dims::Int=1)
    selected = _select(data, selectnumeric(data))
    minimum(selected; dims=dims), maximum(selected; dims=dims)
end

function minmax(data::AbstractDataFrame)
    selected = _select(data, selectnumeric(data))
    minimum.(eachcol(selected)), maximum.(eachcol(selected))
end

"""
    l2norm(data; dims::Int=1)

Returns norm of columns or rows of given `data`.

If `data` is an `AbstractArray`, in keyword argument `dims` dimensions can be specified
over which norm is computed. If `data` is an `AbstractDataFrame`, then norm is calculated
for columns.

This function uses `norm` from the package `LinearAlgebra`.
"""
function l2norm(data::AbstractArray; dims::Int=1)
    selected = _select(data, selectnumeric(data))
    if dims == 1    #by columns
        return makerow(norm.(eachcol(selected)))
    elseif dims == 2
        return norm.(eachrow(selected))
    else
        throw(ArgumentError("Wrong dimensions."))
    end
end

function l2norm(data::AbstractDataFrame)
    selected = _select(data, selectnumeric(data))
    return norm.(eachcol(selected))
end

"""
    selectnumeric(data::AbstractDataFrame)

Returns array of number of columns which contain values of type `Number`.
"""
function selectnumeric(data::AbstractDataFrame)
    n = Base.size(data, 2)
    nums = Int[]

    for i in 1:n-1
        if eltype(data[:,i]) <: Number
            append!(nums, i)
        end
    end

    return nums
end

"""
    selectnumeric(data::AbstractArray; dims::Int=1)

Returns tuple array of number of columns or rows which contain values of type `Number` and
other element of the tuple is `Colon` :.
"""
function selectnumeric(data::AbstractArray; dims::Int=1)
    nums = Int[]

    if dims == 1
        n = Base.size(data, 2)

        for i in 1:n
            if eltype(data[1,i]) <: Number && eltype(data[2,i]) <: Number
                append!(nums, i)
            end
        end

        return (:, nums)

    elseif dims == 2
        n = Base.size(data, 1)

        for i in 1:n
            if eltype(data[i,1]) <: Number && eltype(data[i,1]) <: Number
                append!(nums, i)
            end
        end

        return (nums,:)

    else
        throw.ArgumentError("Unsopported dimensions. (1 or 2 are accepted)")
    end
end

"""
    makerow(vec::Matrix)

For matrix permutes dimensions (makes a row vector from column vector). If `vec` is already
a row vector then does nothing.
"""
makerow(vec::AbstractArray) = Base.size(vec, 1) == 1 ? vec : permutedims(vec)

"""
    change(data, substracted, divided)

Changes `data` elements following a formula: `data .- substracted ./ devided`.
"""
function change!(data::AbstractArray, substracted, devided)
    selection = selectnumeric(data)
    data[selection[1], selection[2]] .= (data[selection[1], selection[2]] .- substracted) ./ devided
    return
end

function change!(data::AbstractDataFrame, substracted, devided)
    selected = _select(data, selectnumeric(data))
    n = length(devided)

    for i in 1:n
        # selected[!,i] = convert.(Float64,selected[:,i])
        selected[:,i] .= ((selected[:,i] .- substracted[i]) ./ devided[i])
    end

    return
end

"""
    change!(data, divided)

Changes `data` elements following a formula: `data ./ devided`.
"""
function change!(data::AbstractArray, devided)
    selection = selectnumeric(data)
    data[selection[1], selection[2]] .= data[selection[1], selection[2]] ./ devided
    return
end

function change!(data::AbstractDataFrame, devided)
    selected = _select(data, selectnumeric(data))
    n = length(devided)

    for i in 1:n
    #    selected[!,i] = convert.(Float64,selected[:,i])
        selected[:,i] .= selected[:,i] ./ devided[i]
    end

    return
end

# ------------------ Util functions for binarizing tabular datasets -------------------- */
"""
    classes(dataset)

Prints unique names of target values.
"""
classes(dataset::DatasetName) = unique(labels(dataset))

"""
    binarize(data, pos_labels)

Binarize data for specified positive labels. (Data must contain just labels no feature valeus.)
"""
binarize(data, pos_labels::AbstractString) = binarize(data, [pos_labels])
binarize(data, pos_labels) = [in(i, pos_labels) for i in data]

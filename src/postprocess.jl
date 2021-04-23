# ------------------ Util functions for normalizing tabular datasets ------------------- */

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
    mean(data; dims=dims), std(data; dims=dims)
end
function meanstd(data::AbstractDataFrame; dims)
    mean.(eachcol(data[:,1:end-1])), std.(eachcol(data[:,1:end-1]))
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

If `data` is an `AbstractArray`, changes all elements.
If `data` is an `AbstractDataFrame`, changes elements in all columns except last one.
"""
function change(data::AbstractArray, substracted, devided; dims=1)
        (data .- substracted) ./ devided
end

function change(data::AbstractDataFrame, substracted, devided)
    n = length(substracted)
    for i in 1:n
        if eltype(data[:,i]) <: Number
            data[!,i] = (data[:,i] .- substracted[i]) ./ devided[i]
        end
    end
    return data
end

"""
    standardization(data...; kwargs...)

Returns normalized data by the first group of data in `data` using mean and variance.

If `data` is an `AbstractArray`, in keyword argument `dims` dimensions can be specified
over which mean and standard deviation are computed.
"""
function standardization(data; kwargs...)
    nmean, nstd = meanstd(data; kwargs...)

    return change(data, nmean, nstd)
end

function standardization(data...;kwargs...)

    nmean, nstd = meanstd(first(data); kwargs...)

    return [change(d,nmean, nstd) for d in data]
end

"""
    minimaxi(data; dims=1)

Returns minimum and maximum of columns or rows of given `data`.
If `data` is an `AbstractArray`, `dims` specifies whether it is over columns or rows.
"""
minimaxi(data::AbstractArray; dims=1) = minimum(data; dims=dims), maximum(data; dims=dims)

minimaxi(data::AbstractDataFrame; dims) = minimum.(eachcol(data[:,1:end-1])), maximum.(eachcol(data[:,1:end-1]))


"""
    minmax(data...; kwargs...)

Returns min-max scaled data by the first group of data in `data`.

If `data` is an `AbstractArray`, in keyword argument `dims` dimensions can be specified
over which (columns or rows) minimum and maximum are computed.
"""
function minmax(data...; kwargs...)
    nmin, nmax = minimaxi(first(data); kwargs...)

    return [change(d,nmin, nmax-nmin) for d in data]
end

"""
    mynorm(data; dims)

Returns norm of columns or rows of given `data`.

If `data` is an `AbstractArray`, in keyword argument `dims` dimensions can be specified
over which norm is computed. If `data` is an `AbstractDataFrame`, then norm is calculated
for columns.

This function uses `norm` from the package `LinearAlgebra`.
"""
function mynorm(data::AbstractArray; dims::Int=1)
    if dims == 1    #by columns
        return makerow(norm.(eachcol(data)))
    elseif dims == 2
        return norm.(eachrow(data))
    else
        throw(ArgumentError("Wrong dimensions."))
    end
end

function mynorm(data::AbstractDataFrame; dims)
    return norm.(eachcol(data[:,1:end-1]))
end

"""
    l2normalization(data...; kwargs...)

Returns normalized data by the first group of data in `data`.

If `data` is an `AbstractArray`, in keyword argument `dims` dimensions can be specified
over which norm is computed. For more see [`mynorm`](@ref)
"""
function l2normalization(data...; kwargs...)
    nnorm = mynorm(first(data); kwargs...)
    data isa AbstractArray ? zero = 0 : zero = zeros(length(nnorm))

    return [change(d, zero, nnorm) for d in data]
end

function l2normalization(data; kwargs...)
    nnorm = mynorm(data; kwargs...)
    data isa AbstractArray ? zero = 0 : zero = zeros(length(nnorm))

    return change(data, zero, nnorm)
end

createzero(data::AbstractArray) = 0
createzero(data::AbstractDataFrame) = zeros(length(nnorm))
"""
    normalize(type, data... kwargs...)

Normalizes given `data` by the first group of data in `data`.

# Keyword arguments
-`type::Symbol=:Z`: specify which feature scaling is used. For standardization, `type` is
`:standardization`,`:standard`,`:z` or `:Z`. For minmax scaling `type` is `:minmax` or `:mm`,
for l2 normalization `type` is `:l2`, `:L2` or `:norm`.
-`data` can be `AbstractArray` or `AbstractDataFrame`.

If `data` is an `AbstractArray`, a keyword argument `dims` can be provided to compute values
over dimensions.
"""
function normalize(data...; type::Symbol=:Z, kwargs...)
    if type in (:z, :Z, :standardization, :standard)
        return standardization(data...; kwargs...)
    elseif type in (:minmax, :mm)
        return minmax(data...; kwargs...)
    elseif type in (:l2, :L2, :norm)
        return l2normalization(data...; kwargs...)
    end
end

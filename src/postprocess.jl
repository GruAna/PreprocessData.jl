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
function meanstd(data::AbstractDataFrame)
    mean.(eachcol(data)), std.(eachcol(data))
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
function change!(data::AbstractArray, substracted, devided; dims=1)
    data .= (data .- substracted) ./ devided
    display(data)
    return
end

function change!(data::AbstractDataFrame, substracted, devided)
    n = length(substracted)
    for i in 1:n
        data[:,i] .= (data[:,i] .- substracted[i]) ./ devided[i]
    end
    return
end

"""
    standardization(data...; kwargs...)

Returns normalized data by the first group of data in `data` using mean and variance.

If `data` is an `AbstractArray`, in keyword argument `dims` dimensions can be specified
over which mean and standard deviation are computed.
"""
function standardization!(data; kwargs...)
    nmean, nstd = meanstd(data; kwargs...)
    change!(data, nmean, nstd)
    return
end


"""
    minimaxi(data; dims=1)

Returns minimum and maximum of columns or rows of given `data`.
If `data` is an `AbstractArray`, `dims` specifies whether it is over columns or rows.
"""
minimaxi(data::AbstractArray; dims=1) = minimum(data; dims=dims), maximum(data; dims=dims)

minimaxi(data::AbstractDataFrame) = minimum.(eachcol(data)), maximum.(eachcol(data))


"""
    minmax(data...; kwargs...)

Returns min-max scaled data by the first group of data in `data`.

If `data` is an `AbstractArray`, in keyword argument `dims` dimensions can be specified
over which (columns or rows) minimum and maximum are computed.
"""
function minmax!(data; kwargs...)
    nmin, nmax = minimaxi(data; kwargs...)
    change!(data, nmin, nmax-nmin)
    return
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

function mynorm(data::AbstractDataFrame)
    return norm.(eachcol(data))
end

"""
    l2normalization(data...; kwargs...)

Returns normalized data by the first group of data in `data`.

If `data` is an `AbstractArray`, in keyword argument `dims` dimensions can be specified
over which norm is computed. For more see [`mynorm`](@ref)
"""
function l2normalization!(data; kwargs...)
    nnorm = mynorm(data; kwargs...)
    data isa AbstractArray ? zero = 0 : zero = zeros(length(nnorm))
    change!(data, zero, nnorm)
    return
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
other element of the tuple is `Colon`.
"""
function selectnumeric(data::AbstractArray; dims::Int=1)
    nums = Int[]

    if dims == 1
        n = Base.size(data, 2)

        for i in 1:n
            if eltype(data[:,i]) <: Number
                append!(nums, i)
            end
        end

        return (:, nums)

    elseif dims == 2
        n = Base.size(data, 1)

        for i in 1:n
            if eltype(data[i,:]) <: Number
                append!(nums, i)
            end
        end

        return (nums,:)

    else
        throw.ArgumentError("Unsopported dimensions. (1 or 2 are accepted)")
    end
end

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
function normalize!(data::AbstractDataFrame; type::Symbol=:Z)
    selection = selectnumeric(data)
    display(selection)
    if type in (:z, :Z, :standardization, :standard)
        standardization!(data[!,selection])
    elseif type in (:minmax, :mm)
        minmax!(data[!, selection])
    elseif type in (:l2, :L2, :norm)
        l2normalization!(data[!, selection])
    end
    return
end

# NOT FINISHED - not changing data!!!!!!!!!
function normalize!(data::AbstractArray; type::Symbol=:standard, dims::Int=1)
    selection = selectnumeric(data)

    if type in (:z, :Z, :standardization, :standard)
        standardization!(data[selection[1], selection[2]]; dims)
    elseif type in (:minmax, :mm)
        minmax!(data[selection[1], selection[2]]; dims)
    elseif type in (:l2, :L2, :norm)
        l2normalization!(data[selection[1], selection[2]]; dims)
    end
    display(data) # !!!!!!!!!!!! nothing
    return
end

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

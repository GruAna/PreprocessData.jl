# -------------------------- Util functions for preprocessing -------------------------- */

# Default header for Tabular datasets is empty String.
"""
    headers(::Tabular)

Returns column names of `Tabular` dataset. Default is empty `String`.
"""
headers(dataset::Tabular) = ""

"""
    target(::Tabular)

Returns order of target column.

Default target for `Tabular` datasets is last column. It can be different number for every
dataset, so we mark it as zero and remember it for later use.
Target should be always specified manually in dataset.jl file.
"""
target(dataset::Tabular) = 0

"""
    categorical(::Tabular)

Returns indeces of columns containing categorical data. Default is empty range.
"""

categorical(dataset::Tabular) = 1:0


# ---------------------------- Util functions for splitting ---------------------------- */
"""
    getdata(dataset::Tabular, type::Symbol)

Returns data from dataset. `type` is either `:train`, `:test.` or `:valid`.
"""
function getdata(
    dataset::Tabular,
    type::Symbol=:train,
    )
    path = getpath(dataset)       # path to a directory of given datadep

    if type == :test
        file = "data-test.csv"
    elseif type == :valid
        file = "data-valid.csv"
    else
        file = "data-train.csv"
    end
    df = CSV.File(joinpath(path, file), header = true) |> DataFrame

    return df
end

"""
    load(dataset::Tabular, type::Symbol; kwargs...)

Loads dataset of given type.

- `type::Symbol`: default type is `:train`, other possible types are `test` and `valid`.

# Keywords
- `toarray::Bool=false`: if false returns `DataFrame`, else returns `Tuple` of arrays
- `header::Bool=false`: if true returnes `DataFrame` has column names belonging to the
dataset (it they are found), else default column naming is returned.
"""
function load(
    dataset::Tabular,
    type::Symbol=:train;
    toarray::Bool=false,
    header::Bool=false,
    )
    path = getpath(dataset)       # path to a directory of given datadep

    df = getdata(dataset, type)

    return postprocess(dataset, df, toarray, header)
end

"""
    splits(dataset::Tabular, data, indeces1, indeces2)

Devides `data` from `dataset` to two parts.
"""
function splits(dataset::Tabular, data, indeces1, indeces2)
    return data[indeces1,:], data[indeces2,:]
end

"""
    postprocess(dataset::Tabular, df::DataFrame,toarray::Bool, header::Bool)

Returns data of `Tabular` dataset.

#Arguments
toarray::Bool=false: Returns data either as a tuple of two tuples (each has a data array
and labels vector) or as `DataFrame`.
header::Bool=false: If true, searches for header file for the dataset and renames columns
according to the file, else nothing happens.

If both `toarray==true` and `header==true` nothing happens.
"""
function postprocess(
    dataset::Tabular,
    df::DataFrame,
    toarray::Bool=false,
    header::Bool=false,
    )
    header && !toarray && changeheader(dataset, df)

    return df_or_array(df, toarray)
end

function postprocess(
    d::Tabular,
    data1::DataFrame,
    data2::DataFrame;
    toarray::Bool=false,
    header::Bool=false,
    )
    return postprocess(d,data1,toarray,header), postprocess(d,data2,toarray,header)
end

function postprocess(
    d::Tabular,
    data1::DataFrame,
    data2::DataFrame,
    data3::DataFrame;
    toarray::Bool=false,
    header::Bool=false,
    )
    return postprocess(d,data1,toarray,header), postprocess(d,data2,toarray,header), postprocess(d,data3,toarray,header)
end

# ----------------------- Util functions for manipulating header ----------------------- */

"""
    loadheader(path::String, dataset::Tabular)

Loads header for given dataset from a file.

Changes position of target column if target column was not the last column.
"""
function loadheader(path::String, dataset::Tabular)
    if isfile(path)
        df = CSV.File(path, header = false) |> DataFrame
        targ = target(dataset)
        header = Array(df[:,1])
        if targ != 0   # if targ == 0 it was assumed that it is the last col
            push!(header, header[targ])
            header = header[Not(targ)]
        end
        return header
    else
        return ""
    end
end

"""
    getheader(dataset::Tabular)

Returns header found in header.csv in folder .../datadeps/dataset. See `load`.
"""
function getheader(dataset::Tabular)
    path = joinpath(getpath(dataset), "header.csv")
    return loadheader(path, dataset)
end

"""
    changeheader(dataset::Tabular, df::DataFrame)

Changes header of `DataFrame` od given dataset, id there is a header.
"""
function changeheader(dataset::Tabular, df::DataFrame)
    hds = getheader(dataset)
    if isempty(hds)
        @info "No file with header (column names) found."
    else
        new_header(hds, df)
    end
end

"""
    new_header(header::Vector{String}, df::DataFrame...)

Change column names of `DataFrames` to column names from header.

Length of `header` must be the same as number of columns of `df`.
"""
function new_header(header::Vector{String}, df::DataFrame...)
    if isempty(header)
        return nothing
    end
    for d in df
        rename!(d, header)
    end
end

# ---------------------------------- Other functions ----------------------------------- */

"""
    meanstd(data; dims)

Returns mean and standard deviation of columns or rows of given `data`.

Mean and standard deviation are returned in a row vector (`Tuple` of two `1xn Matrix`).

# Arguments
- `data` can be an `AbstractArray` or `AbstractDataFrame`
If `data` is an `AbstractArray`, a keyword argument `dims` can be provided to compute values
over dimensions.

This function uses `mean` and `std` from the package `Statistics`.
"""
function meanstd(data::AbstractArray; dims::Int=1)
    mean(data; dims), std(data; dims)
end
function meanstd(data::AbstractDataFrame)
    makerow(mean.(eachcol(data[:,1:end-1]))), makerow(std.(eachcol(data[:,1:end-1])))
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

# Arguments
If `data` is an `AbstractArray`, changes all elements.
If `data` is an `AbstractDataFrame`, changes elements in all columns except last one.
"""
function change(data::AbstractArray, substracted, devided; dims=1)
        (data .- substracted) ./ devided
end

function change(data::AbstractDataFrame, substracted, devided)
    n = Base.size(data,2)
    for i in 1:n-1
        if eltype(data[:,i]) <: Number
            data[!,i] = (data[:,i].-substracted) ./ devided
        end
    end
    return data
end

function normalize(type::Symbol=:Z, data...; kwargs...)
    if type in (:standardization, :z, :Z)
        return standardization(data...; kwargs...)
    elseif type in (:minmax, :mm)
        return minmax(data...; kwargs...)
    end
end

function standardization(data; kwargs...)
    nmean, nstd = meanstd(data; kwargs...)

    return change(data, nmean, nstd)
end

function standardization(data...;kwargs...)

    nmean, nstd = meanstd(first(data); kwargs...)

    return [change(d,nmean, nstd) for d in data]
end

minimaxi(data; dims=1) = minimum(data; dims), maximum(data; dims)

function minmax(data...; kwargs...)
    nmin, nmax = minimaxi(first(data); kwargs...)

    return [change(d,nmin, nmax-nmin) for d in data]
end

function mynorm(data::AbstractArray; dims::Int=1)
    if dims == 1    #by columns
        return norm.(eachcol(data))
    elseif dims == 2
        return norm.(eachrow(data))
    else
        throw(ArgumentError("Wrong dimensions."))
    end
end

function mynorm(data::AbstractDataFrame)
    return norm.(eachcol(data[:,1:end-1]))
end

function l2normalization(data...; kwargs...)
    nnorm = makerow(mynorm(first(data); kwargs...))

    return [change(d,0, nnorm) for d in data]
end

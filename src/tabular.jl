# -------------------------- Util functions for preprocessing -------------------------- */

# Default header for Tabular datasets is empty String.
headers(::Tabular) = ""

# Default target for Tabular datasets is last column. It can be different number for every
# dataset, so we mark it as zero and remember it for later use.
# target should be always specified manually in dataset.jl file
target(dataset::Tabular) = 0

"""
    getheader(dataset::Tabular)

Returns header found in header.csv in folder .../datadeps/dataset. See `load`.
"""
function getheader(dataset::Tabular)
    path = joinpath(getpath(dataset), "header.csv")
    return load(path, dataset)
end

"""
    load(path::String, dataset::Tabular)

Returns header as `Vector{String}` if there is a header file in path, else returns empty `String`.

For good functionality - in header file each column name must be on a new line.
"""
function load(path::String, dataset::Tabular)
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

# ---------------------------- Util functions for splitting ---------------------------- */
"""
    getdata(dataset::Tabular, type::Symbol)

Returns data from dataset. `type` is either `:train`, `:test.` or `:valid`.
"""
function getdata(dataset::Tabular, type::Symbol)
    path = getpath(dataset)       # path to a directory of given datadep
    if type == :test
        return CSV.File(joinpath(path, "data-test.csv"), header = true) |> DataFrame
    elseif type == :valid
        return CSV.File(joinpath(path, "data-valid.csv"), header = true) |> DataFrame
    else
        return CSV.File(joinpath(path, "data-train.csv"), header = true) |> DataFrame
    end
end

"""
    splits(dataset::Tabular, data, indeces1, indeces2)

Devides `data` from `dataset` to two parts.
"""
function splits(dataset::Tabular, data, indeces1, indeces2)
    return data[indeces1,:], data[indeces2,:]
end

"""
    final_data(toarray::Bool, data1::DataFrame, data2::DataFrame)

Returns data of `Tabular` dataset, either as a tuple of two tuples (teach has a data array
and labels vector) or as three `DataFrames`.
"""
function final_data(toarray::Bool, data1::DataFrame, data2::DataFrame)
    return df_or_array(data1, toarray), df_or_array(data2, toarray)
end

"""
    final_data(toarray::Bool, data1::DataFrame, data2::DataFrame, data3::DataFrame)

Returns data of `Tabular` dataset, either as a tuple of three tuples (teach has a data array
and labels vector) or as three `DataFrames`.
"""
function final_data(
    toarray::Bool,
    data1::DataFrame,
    data2::DataFrame,
    data3::DataFrame,
)
    return df_or_array(data1, toarray), df_or_array(data2, toarray), df_or_array(data3, toarray)
end

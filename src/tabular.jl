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
    return loadheader(path, dataset)
end

"""
    load(path::String, dataset::Tabular)

Returns header as `Vector{String}` if there is a header file in path, else returns empty `String`.

For good functionality - in header file each column name must be on a new line.
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
function getdata(
    dataset::Tabular,
    type::Symbol=:train;
    toarray::Bool=false,
    header::Bool=false,
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

function postprocess(
    dataset::Tabular,
    df::DataFrame,
    toarray::Bool=false,
    header::Bool=false,
    )
    header && changeheader(dataset, df)

    return df_or_array(df, toarray)
end

function postprocess(
    d::Tabular,
    data1::DataFrame,
    data2::DataFrame,
    toarray::Bool=false,
    header::Bool=false,
    )
    return postprocess(d, data1,toarray,header), postprocess(d, data2,toarray,header)
end

function postprocess(
    d::Tabular,
    data1::DataFrame,
    data2::DataFrame,
    data3::DataFrame,
    toarray::Bool=false,
    header::Bool=false,
    )
    return postprocess(d, data1,toarray,header), postprocess(d, data2,toarray,header), postprocess(d, data3,toarray,header)
end

function changeheader(dataset::Tabular, df::DataFrame)
    hds = getheader(dataset)
    if isempty(hds)
        @info "No file with header (column names) found."
    else
        new_header(hds, df)
    end
end

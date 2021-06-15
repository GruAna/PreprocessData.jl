# -------------------------- Util functions for preprocessing -------------------------- */

# Default header for Tabular datasets is empty String.
"""
    headers(::Tabular)

Returns column names of `Tabular` dataset. Default is empty `String`.
"""
headers(dataset::Tabular) = ""

"""
    target(::Tabular)

Returns order of target column, else throws error.
"""
target(dataset::Tabular) = error("Target value not specified for $dataset dataset.")

"""
    categorical(::Tabular)

Returns indeces of columns containing categorical data. Default is empty range.
"""

categorical(dataset::Tabular) = 1:0
transposed(dataset::Tabular) = false

# ---------------------------- Util functions for splitting ---------------------------- */
"""
    getdata(dataset::Tabular, type::Type{<:Split})

Returns data from dataset. `type` is either `Train`, `Test` or `Valid`.
"""
function getdata(dataset::Tabular, type::Type{Train})
    return CSV.File(joinpath(getpath(dataset) , "data-train.csv"), header=true) |> DataFrame
end

function getdata(dataset::Tabular, type::Type{Valid})
    return CSV.File(joinpath(getpath(dataset) , "data-valid.csv"), header=true) |> DataFrame
end

function getdata(dataset::Tabular, type::Type{Test})
    return CSV.File(joinpath(getpath(dataset) , "data-test.csv"), header=true) |> DataFrame
end
# getpath(dataset) - path to a directory of given datadep

"""
    load(dataset::Tabular, type::Type{<:Split}; kwargs...)

Loads dataset of given type. Type based on filenames in datadeps folder (types available
only if the dataset was splitted before downloading, else the whole dataset is of type `Train`)

- `type::Type{<:Split}=Train`: other possible types are `Test` or `Valid`.

# Keywords
- `toarray::Bool=false`: if false returns `DataFrame`, else returns `Tuple` of arrays
- `header::Bool=false`: if true returnes `DataFrame` has column names belonging to the
dataset (it they are found), else default column naming is returned.
"""
function load(
    dataset::Tabular,
    type::Type{<:Split}=Train;
    toarray::Bool=false,
    header::Bool=false,
    )
    return postprocess(dataset, getdata(dataset, type), toarray, header)
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
        if targ isa Int
            push!(header, header[targ])
            header = header[Not(targ)]
        end
        return header
    else
        @info "No file with header (column names) found."
        return ""
    end
end

"""
    getheader(dataset::Tabular)

Returns header found in header.csv in folder .../datadeps/dataset. See [`load`](@ref).
"""
function getheader(dataset::Tabular)
    path = joinpath(getpath(dataset), "header.csv")
    return loadheader(path, dataset)
end

"""
    changeheader(dataset::Tabular, df::DataFrame)

Changes header of `DataFrame` of given dataset, id there is a header.
"""
function changeheader(dataset::Tabular, df::DataFrame)
    hds = getheader(dataset)
    if !isempty(hds)
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

# ---------------------- Other functions for manipulating header ---------------------- */

"""
    labels(dataset::Tabular)

Returns train label array for given dataset.
"""
function labels(dataset::Tabular)
    df = load(dataset)
    return df[:,end]
end

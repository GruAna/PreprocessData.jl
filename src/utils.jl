function getModule(::Image) end
name(dataset::DatasetName) = lowercasefirst(String(nameof(typeof(dataset))))
getpath(dataset::DatasetName) = @datadep_str name(dataset)
headers(::Tabular) = ""

function target(dataset::Tabular)
    path = joinpath(getpath(dataset), "data-train.", extension(dataset))
    return ncol(CSV.File(path) |> DataFrame)
end

function getheader(dataset::Tabular)
    path = joinpath(getpath(dataset), "header.csv")
    return load(path, dataset)
end

function load(path::String, dataset::Tabular)
    if isfile(path)
        df = CSV.File(path, header = false) |> DataFrame
        targ = target(dataset)
        header = Vector(df[:,1])
        push!(header, header[targ])
        header = header[Not(targ)]
        return header
    else
        return ""
    end
end

function new_header(header::Vector{String}, df::DataFrame...)
    if isempty(header)
        return nothing
    end
    for d in df
        rename!(d, header)
    end
end


"""
    get_files(dataset)

Get all files (filepaths) in dataset directory.
"""
function get_files(dataset)
    dsString = name(dataset)
    path = @datadep_str dsString
    return readdir(path, join=true)
end

"""
    get_filename(path)

Get name of the file without filename extension.
`path` must include filename.
"""
function get_filename(path)
    filename = basename(path)
    return splitext(filename)[1]
end

function get_filetext(path)
    filename = basename(path)
    return (splitext(filename)[2])[2:end]
end

"""
    df_or_array(returnArray::Bool, df::DataFrame)

    Based on returnArray return either a `DataFrame` (true) or an `Array` (false).
"""
function df_or_array(df::DataFrame, toarray::Bool)
    return toarray ? df_to_array(df) : df
end


function df_to_array(df::DataFrame)
    return Array(df[:,1:end-1]), df[:,end]
end

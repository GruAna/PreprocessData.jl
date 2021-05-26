function preprocess(::DatasetName) end
extension(dn::DatasetName) = extension(dn)
extension(::Tabular) = "csv"

"""
    function call(dataset)

Download the dataset using `DataDeps` package
and create a csv file, see [`preprocess?`](@ref)).
"""
call(dataset::DatasetName) = @datadep_str name(dataset)

"""
    registering(dsName::DatasetName)

Create a registration block for DataDeps package.
"""
function registering(dsName::DatasetName)
    DataDeps.register(DataDep(
        name(dsName),
        """
            Dataset: $(name(dsName))
            Website: $(url(dsName))
        """,
        url(dsName),
        checksum(dsName),
        post_fetch_method = prep(dsName)
    ))
end

"""
    extract(path)

Extracts file using `DataDeps.unpack` function and returns path to the new extracted file.
"""
function extract(path)
    newPath = splitext(path)[1]
    DataDeps.unpack(path)
    return newPath
end

"""
    preprocess(path, dataset, header, kwargs...)

Create csv file containing data from tabular dataset in "standard" format.

The format can be described as - columns represents attributes, rows instances,
attributes in a row are separated by comma. First row of file is header.
Last column contains target values and is named Target. If `dataset` has defined
`categorical` columns, appends "-C" at the beginning of column name.

#Keyword arguments
- `kwargs...`: keyword arguments that are possible in `CSV.File` function.
"""
function preprocess(
    path::AbstractString,
    dataset::Tabular;
    kwargs...
)
    # If header is Integer, it means it is in the file together with data and is used in
    # CSV.file loading.
    headers(dataset) isa Integer ? header = headers(dataset) : header = false

    df = CSV.File(
        path,
        header = header,
        transpose = transposed(dataset),
        missingstrings = ["", "NA", "?", "*", "#DIV/0!", "missing", "NaN"],
        truestrings = ["T", "t", "TRUE", "true", "y", "yes", "Y"],
        falsestrings = ["F", "f", "FALSE", "false", "n", "no", "N"],
        kwargs...
        ) |> DataFrame

    # if header is an Int or true or if header is defined in $dataset.jl
    # saves header to a file header.csv
    # does not overwrite
    if headers(dataset) isa Int || header
        save_header(names(df), path)
    elseif !isempty(headers(dataset))
        save_header(headers(dataset), path)
    end

    # place target column
    col = target(dataset)    #target column, either Int or String "labels"

    if col isa String
        col = string("labels-", typeSplit)
    end

    df = place_target(col, df)

    categorical_cols = categorical(dataset)
    for i in categorical_cols
        rename!(df, i => names(df)[i]*"-C")
    end

    ext = extension(dataset)
    name = getfilename(path)
    typeSplit = find_in(name)

    pathForSave = joinpath(dirname(path), string("data-",typeSplit,".",ext))
    CSV.write(pathForSave, df, delim=',', writeheader=true)
    rm(path)
end

function save_header(names::Vector{<:AbstractString}, path::AbstractString)
    open(joinpath(dirname(path), "header.csv"),"w") do io
        [write(io, d*"\n") for d in names]
    end
end

function rename_cols(df::AbstractDataFrame)
    return rename!(df, collect(1:(ncol(df)-1)) .=> ["Column $i" for i in 1:ncol(df)-1])
end


"""
    place_target(column::Int, df::AbstractDataFrame)

Moves column from its position to last position in `DataFrame` df.
"""
function place_target(column::Int, df::AbstractDataFrame)
    lastColIndex = ncol(df)

    if column > 0 || column < lastColIndex
        #Move target column to last position
        df.Target = df[!, column]
        df = df[!, Not(column)]
        # rename columns after target column was moved, don't if col was already the last column
        rename_cols(df)
    else
        rename!(df, lastColIndex => "Target")
    end

    return df
end

"""
    place_target(fileName::AbstractString, df::AbstractDataFrame)

Pushes column with labels from a file to last position in `DataFrame` df.
"""
function place_target(fileName::AbstractString, df::AbstractDataFrame)
    pathLabels = joinpath(pwd(), fileName)
    dfLabels = CSV.File(
        pathLabels,
        header = ["Target"],
        missingstrings = ["", "NA", "?", "*", "#DIV/0!"],
        truestrings = ["T", "t", "TRUE", "true", "y", "yes"],
        falsestrings = ["F", "f", "FALSE", "false", "n", "no"],
        ) |> DataFrame
    df = hcat(df, dfLabels)
    rm(pathLabels)

    return df
end

"""
    preprocess(path::AbstractString, type::Symbol)

Renames downloaded file based on type.

If type is `:labels`,`label` or `:target` (used for file containing labels) file is renamed.
For labels filename has format labels-typeSplit.csv. For typeSplit see [`find_in`](@ref).
If type is `:header` or `:headers` (used for file containing header) file is renamed.
For header filename has format header.csv.
"""
function preprocess(path::AbstractString, type::Symbol)
    if type == :labels || type == :label || type == :target
        typeSplit = find_in(getfilename(path))
        mv(basename(path), string("labels-", typeSplit))
    elseif type == :header || type == :headers
        mv(basename(path), string("header.csv"))
    else
        throw(ArgumentError("Unknown type for preprocess."))
    end
end

"""
    find_in(name::AbstractString)

Searches for strings train, test, valid in given name.

If one of the substrings is present then returns it.
If none is present then returns "train".

#Examples
```julia-repl
julia> PreprocessData.find_in("name-test.csv")
"test"

julia> PreprocessData.find_in("name.csv")
"train"
```
"""
function find_in(name::AbstractString)
    if occursin("train", name) || (!occursin("valid", name) && !occursin("test", name))
        return "train"
    elseif occursin("valid", name)
        return "valid"
    elseif occursin("test", name)
        return "test"
    end
end

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
        post_fetch_method = preprocess(dsName)
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
    preprocess(path, dataset, header, categorical_cols, kwargs...)

Create csv file containing data from dataset in "standard" format.

The format can be described as - columns represents attributes, rows instances,
attributes in a row are separated by comma. First row of file is header
Last column contains target values and is named Target.`categorical_cols` if provided prepend "Categ-"
at the beginning of column name.

#Arguments
- `header::Bool=false`: false no header, names `Column 1` are created.
True first row of file contains column names.
- `categorical_cols=0:1`: range of columns with categorical values.
- `kwargs...`: keyword arguments that are possible in `CSV.File` function.
"""
function preprocess(
    path::AbstractString,
    dataset::DatasetName;
    header::Bool = false,
    categorical_cols::Union{Int, UnitRange{Int}, Array{Int,1}}=1:0,
    kwargs...
)
    df = CSV.File(
        path,
        header = header,
        missingstrings = ["", "NA", "?", "*", "#DIV/0!"],
        truestrings = ["T", "t", "TRUE", "true", "y", "yes"],
        falsestrings = ["F", "f", "FALSE", "false", "n", "no"],
        kwargs...
        ) |> DataFrame

    # if header is true or if header is defined in $dataset.jl
    # saves header to a file header.csv
    # does not overwrite
    if header
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

    for i in categorical_cols
        rename!(df, i => names(df)[i]*"-Cat")
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

function rename_cols(df::DataFrame)
    return rename!(df, collect(1:(ncol(df)-1)) .=> ["Column $i" for i in 1:ncol(df)-1])
end


"""
    place_target(column::Int, df::DataFrame)

Moves column from its position to last position in `DataFrame` df.
"""
function place_target(column::Int, df::DataFrame)
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
    place_target(fileName::String, df::DataFrame)

Pushes column with labels from a file to last position in `DataFrame` df.
"""
function place_target(fileName::String, df::DataFrame)
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
    preprocess(path::String, type::Symbol)

Renames downloaded file based on type.

If type is `:labels`,`label` or `:target` (used for file containing labels) file is renamed.
For labels filename has format labels-typeSplit.csv. For typeSplit see `find_in`.
If type is `:header` or `:headers` (used for file containing header) file is renamed.
For header filename has format header.csv.
"""
function preprocess(path::String, type::Symbol)
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
    find_in(name::String)

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
function find_in(name::String)
    if occursin("train", name) || (!occursin("valid", name) && !occursin("test", name))
        return "train"
    elseif occursin("valid", name)
        return "valid"
    elseif occursin("test", name)
        return "test"
    end
end
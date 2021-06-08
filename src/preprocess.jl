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
    col = target(dataset)    #target column, either Int or Type{File}

    name = getfilename(path)
    typeSplit = find_in(name)

    df = place_target(col, df, typeSplit)

    categorical_cols = categorical(dataset)
    for i in categorical_cols
        rename!(df, i => names(df)[i]*"-C")
    end

    ext = extension(dataset)

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
function place_target(column::Int, df::AbstractDataFrame, ::AbstractString)
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
    place_target(::Type{Labels}, df::AbstractDataFrame, typeSplit::AbstractString)

Pushes column with labels from a file to last position in `DataFrame` df.
"""
function place_target(::Type{Labels}, df::AbstractDataFrame, typeSplit::AbstractString)
    pathLabels = joinpath(pwd(), string("labels-", typeSplit))
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
    preprocess(path::AbstractString, ::Type{Labels})

Renames downloaded file with labels based on type. Filename has format labels-typeSplit.csv.
For typeSplit see [`find_in`](@ref).
"""
function preprocess(path::AbstractString, ::Type{Labels})
    typeSplit = find_in(getfilename(path))
    mv(basename(path), string("labels-", typeSplit))
end

"""
    preprocess(path::AbstractString, ::Type{Header})

Renames downloaded file with header to header.csv.
"""
function preprocess(path::AbstractString, ::Type{Header})
    mv(basename(path), string("header.csv"))
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

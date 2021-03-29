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
    preprocess(path, name, header_names, target_col, categorical_cols, kwargs...)

Create csv file containing data from dataset in "standard" format.

The format can be described as - columns represents attributes, rows instances,
attributes in a row are separated by comma. First row of file is header
Last column contains target values and is named Target, if `target_col` is provided
and has value within bounds. `categorical_cols` if provided prepend "Categ-"
at the beginning of column name.

#Arguments
- `header_names`: name of columns can be passed in `header_names`,
if not names `Column 1` are created.
- `target_col`: either `Int` containing index of target column in dataset, or name
(`String`) of file with only labels for the dataset. File must be in the same directory as
dataset.
"""
function preprocess(
    path::AbstractString,
    dataset::DatasetName;
    header::Bool = false,
    categorical_cols::Union{Int, UnitRange{Int}, Array{Int,1}}=1:0,
    kwargs...
)
    name = get_filename(path)
    ext = extension(dataset)

    typeSplit = _find_in(name)

    df = CSV.File(
        path,
        header = false,
        missingstrings = ["", "NA", "?", "*", "#DIV/0!"],
        truestrings = ["T", "t", "TRUE", "true", "y", "yes"],
        falsestrings = ["F", "f", "FALSE", "false", "n", "no"],
        kwargs...
        ) |> DataFrame

    for i in categorical_cols
        rename!(df, i => "Categ-"*names(df)[i])
    end

    col = target(dataset)    #target column, either Int or String "labels"

    if col isa String
        col = string("labels-", typeSplit)
    end

    df = place_target(col, df)

    # if header is true or if header is defined in $dataset.jl
    # saves header to a file header.csv
    # does not overwrite
    if header
        save_header(names(df), path)
    elseif !isempty(headers(dataset))
        save_header(headers(dataset), path)
    end

    pathForSave = joinpath(dirname(path), string("data-",typeSplit,".",ext))
    CSV.write(pathForSave, df, delim=',', writeheader=true)
    rm(path)
end

function save_header(names::Vector{<:AbstractString}, path::AbstractString)
    open(joinpath(dirname(path), "header.csv"),"w") do io
        [write(io, d*"\n") for d in names]
    end
end

#path to a file with labels
function preprocess(path::String)
    typeSplit = _find_in(get_filename(path))
    mv(basename(path), string("labels-", typeSplit))
end

function _find_in(name::String)
    if occursin("train", name) || (!occursin("valid", name) && !occursin("test", name))
        return "train"
    elseif occursin("valid", name)
        return "valid"
    elseif occursin("test", name)
        return "test"
    end
end


function place_target(column::Int, df)
    last_col_index = ncol(df)

    #Move target column to last position if not there already.
    if column > 0 && column < last_col_index
        df.Target = df[!, column]
        df = df[!, Not(1)]
    end

    if column == last_col_index
        rename!(df, last_col_index => "Target")
    end

    return df
end

#labels are in a separate file, merge it with df with data
function place_target(fileName::String, df)
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

abstract type DatasetName end
name(dn::DatasetName) = lowercasefirst(String(nameof(typeof(dn))))
function preprocess(::DatasetName) end

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
    path::String;
    header_names::Union{Vector{String}, Vector{Symbol}, Int}=0,
    target_col=0,
    categorical_cols::Union{Int, UnitRange{Int}, Array{Int,1}}=1:0,
    kwargs...
)
    name = get_filename(path)[1]
    extension = get_filename(path)[end]
    df = CSV.File(
        path,
        header = header_names,
        missingstrings = ["", "NA", "?", "*", "#DIV/0!"],
        truestrings = ["T", "t", "TRUE", "true", "y", "yes"],
        falsestrings = ["F", "f", "FALSE", "false", "n", "no"],
        kwargs...
        ) |> DataFrame


    for i in categorical_cols
        rename!(df, i => "Categ-"*names(df)[i])
    end

    df = place_target(target_col, df)

    path_for_save = joinpath(dirname(path), string(extension,"-",name,".csv"))
    CSV.write(path_for_save, df, delim=',', writeheader=true)
    rm(path)
end

function place_target(target_col::Int, df)
    last_col_index = ncol(df)

    #Move target column to last position if not there already.
    if target_col > 0 && target_col < last_col_index
        df.target = df[!, target_col]
        df = df[!, 1:end ] .!= target_col
    end

    if target_col == last_col_index
        rename!(df, last_col_index => "Target")
    end
    return df
end

function place_target(target_col::String, df)
    pathLabels = joinpath(pwd(), target_col)
    println(pathLabels)
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

"""
    get_path(dataset)

Get path to the preprocessed dataset file `data-dataset.csv`.
"""
function get_path(dataset)
    path = @datadep_str dataset
    joinpath(path , "data-$dataset.csv")
end

"""
    get_filename(path)

Get name of the file without filename extension.
`path` must include filename.
"""
function get_filename(path)
    filename = splitdir(path)[end]
    return split(filename,".")
end

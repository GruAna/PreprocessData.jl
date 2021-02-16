"""
    get_path(dataset)

Get path to the preprocessed dataset file `data-dataset.csv`.
"""
function get_path(dataset)
    path = @datadep_str dataset
    joinpath(path , "data-$dataset.csv")
end

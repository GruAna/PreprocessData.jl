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
    filename = splitdir(path)[end]
    return split(filename,".")
end

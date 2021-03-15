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
    df_or_array(df::DataFrame, returnArray::Bool)

    Based on returnArray return either a `DataFrame` (true) or an `Array` (false).
"""
function df_or_array(df::DataFrame, returnArray::Bool)
    if returnArray
        return df_to_array(df)
    else
        return df
    end
end

function df_to_array(df::DataFrame)
    return Array(df[:,1:end-1]), df[:,end]
end

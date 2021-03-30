name(dataset::DatasetName) = lowercasefirst(String(nameof(typeof(dataset))))
getpath(dataset::DatasetName) = @datadep_str name(dataset)

"""
    get_filename(path)

Get name of the file without filename extension.
`path` must include filename.
"""
function get_filename(path)
    filename = basename(path)
    return splitext(filename)[1]
end

"""
    df_or_array(df::DataFrame, toarray::Bool)

Based on `toarray` return either a `DataFrame` (false) or an `Array` (true).
"""
function df_or_array(df::DataFrame, toarray::Bool)
    return toarray ? df_to_array(df) : df
end

"""
    df_to_array(df::DataFrame)

Converts `DataFrame` to `Array` (1:end-1 columns) and `Vector` (last column).
"""
function df_to_array(df::DataFrame)
    return Array(df[:,1:end-1]), df[:,end]
end

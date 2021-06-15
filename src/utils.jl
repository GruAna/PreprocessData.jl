getpath(dataset::DatasetName) = @datadep_str name(dataset)

"""
    getfilename(path)

Get name of the file without filename extension.
`path` must include filename.
"""
function getfilename(path)
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

"""
    load(dataset::DatasetName, type::Symbol; kwargs...)

Loads dataset of given type.

- `type::Type{<:Split}=Train`: other possible type is `Valid` or `Test`.
"""
load(dataset::DatasetName, type::Type{<:Split}=Train) = getdata(dataset, type)

"""
    getdata(dataset::DatasetName, type::Type{<:Split})

Method not specified for type `DatasetName`. `type` is either `Train`, `Test` or `Valid`.
"""
getdata(dataset::DatasetName, type::Type{<:Split}) = error("Method getdata not specified for $(typeof(dataset)).")

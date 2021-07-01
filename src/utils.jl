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
    df_or_array(df::DataFrame, toarray::Bool; cols::Int=1)

Based on `toarray` return either a `DataFrame` (false) or an `Array` (true).
"""
function df_or_array(df::DataFrame, toarray::Bool; cols::Int=1)
    return toarray ? df_to_array(df, cols=cols) : df
end

"""
    df_to_array(df::DataFrame; cols::Int=1)

Converts `DataFrame` to `Array` (1:end-1 columns) and `Vector` (last column).
"""
function df_to_array(df::DataFrame; cols::Int=1)
    if cols >= Base.size(df,2) || cols <= 0
        error("cols has to be bigger than 1 and smaller than number of all columns of DataFrame.")
    end
        return Array(df[:,1:end-cols]), Array(df[:,end-cols+1:end])
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

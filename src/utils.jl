name(dataset::DatasetName) = lowercasefirst(String(nameof(typeof(dataset))))
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

function printsubtypes(T::Type, level::Int = 0, indent::Int = 0)
    colors = [:light_magenta; :light_blue; :light_green; :light_yellow; :white]
    name = String(nameof(T))
    printstyled(repeat("   ", indent), name,"\n"; color = colors[level+1])
    printsubtypes.(subtypes(T), level + 1, indent + 1)
    return
end

function printproblemtypes(P::Type)
    datasets = subtypes(Tabular)
    for i in datasets
        if problem(i()) == P
            printstyled(i,"\n"; color = :light_yellow)
        end
    end
end

function listdatasets(which=:all)
    if which == :all
        printsubtypes(DatasetName)
    elseif which == :image
        printsubtypes(Image, 1)
    elseif which == :tabular
        printsubtypes(Tabular, 1)
    elseif which == :classification
        printproblemtypes(Classification)
    elseif which == :regression
        printproblemtypes(Regression)
    else
        error("Bad identifier.")
    end
end

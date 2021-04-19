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
    printstyled(repeat("   ", indent), name,"\n"; color=colors[level+1])
    printsubtypes.(subtypes(T), level + 1, indent + 1)
    return
end

function printproblemtypes(P::Type)
    datasets = subtypes(Tabular)
    printstyled(String(nameof(P))," datatsets\n", bold=true)

    for i in datasets
        if problem(i()) == P
            printstyled(String(nameof(i)),"\n"; color=:light_yellow)
        end
    end
end

function listdatasets(which::Symbol=:all)
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

function info(dataset::Tabular)

    printstyled("\n$dataset\n"; bold=true, color=:light_yellow)
    text = """
        Target column:  $(target(dataset))
        Problem type:   $(problem(dataset))
    """
    println(infotext(dataset),text)
end

function infotext(dataset::DatasetName)
    text = """
        Name:           $(name(dataset))
        Type:           $(nameof(supertype(typeof(dataset))))
        Downloaded:     $(isdownloaded(dataset) ? "Yes $(DataDeps.determine_save_path((name(dataset))))" : "No")
        Size:           $(PreprocessData.size(dataset)[1]) (train data)
                        $(PreprocessData.size(dataset)[2]) (valid data)
                        $(PreprocessData.size(dataset)[3]) (test data)
    """
end

function isdownloaded(dataset::DatasetName)
    path = joinpath(download_dir(),name(dataset))
    isfile(joinpath(path, "data-train.csv")) ? true : false
end



# Variation on function determine_save_path(name, rel=nothing) from DataDeps.jl (file
# locations.jl). Here are no arguments, returns path to directory where DataDeps files are
# downloaded (usually something like "/home/user/.julia/datadeps")
"""
    download_dir()

Determines the location to save all datadeps. Same as function from `DataDeps.jl` (see the
original function `DataDeps.determine_save_path`.)
"""
function download_dir()
    rel=nothing;
    cands = DataDeps.preferred_paths(rel; use_package_dir=false)
    path_ind = findfirst(cands) do path
        0 == first(DataDeps.uv_access(path, DataDeps.W_OK))
    end
    if path_ind === nothing
            @error """
            No writable path exists to save the data. Make sure there exists as writable path in your DataDeps Load Path.
            See https://www.oxinabox.net/DataDeps.jl/stable/z10-for-end-users/#The-Load-Path-1
            The current load path contains:
            """ cands
        throw(DataDeps.NoValidPathError("No writable path exists to save the data."))
    end
    return String(cands[path_ind])
end

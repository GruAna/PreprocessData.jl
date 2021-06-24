"""
    printsubtypes(T::Type, level::Int = 0, indent::Int = 0)

Prints tree of subtypes of given type T.
"""
function printsubtypes(T::Type, level::Int = 0, indent::Int = 0)
    colors = [:light_magenta; :light_blue; :light_green; :light_yellow; :white]
    name = String(nameof(T))
    printstyled(repeat("   ", indent), name,"\n"; color=colors[level+1])
    printsubtypes.(subtypes(T), level + 1, indent + 1)
    return
end

"""
    printproblemtypes(P::Type)

Prints names of tabular dataset that are of given type (Classification or Regression).
"""
function printproblemtypes(P::Type)
    datasets = [subtypes(Tabular); subtypes(GrayImage); subtypes(ColorImage)]
    printstyled(String(nameof(P))," datatsets\n", bold=true)

    for i in datasets
        if problem(i()) == P
            printstyled(String(nameof(i))," "; color=:light_yellow)
            println("(",(nameof(supertype(typeof(i())))),")")
        end
    end
end

"""
    listdatasets()

Print datatsets in a tree structure. Prints all datasets of the PreprocessData package.
"""
listdatasets() = printsubtypes(DatasetName)

"""
    listdatasets(type)

Print datatsets in a tree structure. Prints all datasets of given type known to PreprocessData
package. Type can be any subtype of `DatasetName` or `Classifacation` or `Regression`.
"""
listdatasets(type::Type{T} where T <: DatasetName) = printsubtypes(type,  1)

listdatasets(type::Type{T} where T <: Problem) = printproblemtypes(type)

"""
    info(dataset::DatasetName)

Prints information about given dataset.

Dataset must have a registration file.
"""
function info(dataset::Tabular)
    printstyled("\n$dataset\n"; bold=true, color=:light_yellow)
    text = """
        Target column:  $(target(dataset))
    """
    println(infotext(dataset),text)
end

function info(dataset::Image{MLImage})
    printstyled("\n$dataset\n"; bold=true, color=:light_yellow)
    println(infotext(dataset))
end

"""
    infotext(dataset::DatasetName)

Returns String with basic info about given dataset.
"""
function infotext(dataset::DatasetName)
    text = """
        Name:           $(name(dataset))
        Type:           $(nameof(supertype(typeof(dataset))))
        Downloaded:     $(isdownloaded(dataset) ? "Yes $(DataDeps.determine_save_path((name(dataset))))" : "No")
        Source:         $(url(dataset))
        Size:           $(PreprocessData.size(dataset)[1]) (train data)
                        $(PreprocessData.size(dataset)[2]) (valid data)
                        $(PreprocessData.size(dataset)[3]) (test data)
        Problem type:   $(nameof(problem(dataset)))
    """
    msg = message(dataset)
    if !isempty(msg)
        text = text*"""
            Message:        $msg
        """
    end
    return text
end

"""
    remove(dataset::DatasetName)

Removes dataset directory.
"""
function remove(dataset::DatasetName)
    rm(@datadep_str name(dataset); recursive=true)
end

"""
    isdownloaded(dataset::DatasetName)

Returns true if file data-train.csv is present in dataset directory.
"""
function isdownloaded(dataset::DatasetName)
    path = joinpath(download_dir(),name(dataset))
    return isdir(path)
end

# Variation on function determine_save_path(name, rel=nothing) from DataDeps.jl (file
# locations.jl). Here are no arguments, returns path to directory where DataDeps files are
# downloaded (usually something like "/home/user/.julia/datadeps")
"""
    download_dir()

Determines the location to save all datadeps. Same as function from `DataDeps.jl` (see the
original function [`DataDeps.determine_save_path`](@ref).)
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

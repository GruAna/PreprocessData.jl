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
    datasets = subtypes(Tabular)
    printstyled(String(nameof(P))," datatsets\n", bold=true)

    for i in datasets
        if problem(i()) == P
            printstyled(String(nameof(i)),"\n"; color=:light_yellow)
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
        Problem type:   $(nameof(problem(dataset)))
        Source:         $(url(dataset))
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
        Size:           $(PreprocessData.size(dataset)[1]) (train data)
                        $(PreprocessData.size(dataset)[2]) (valid data)
                        $(PreprocessData.size(dataset)[3]) (test data)
    """
end

"""
    remove(dataset::DatasetName)

Removes dataset directory.
"""
function remove(dataset::DatasetName)
    rm(@datadep_str name(dataset); recursive=true)
end

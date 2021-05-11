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
    listdatasets(which::Symbol=:all)

Print datatsets in a tree structure.

# Arguments
Argument `which` can be:
- `:all`: default value, prints all datasets to the PreprocessData pac,age,
- `:image` or `:i`: prints all known image datasets,
- `:tabular` or `:t`: prints all known tabular datasets,
- `:classification` or `:c`: prints all known datasets for classification problem,
- `:regression` or `:r`: prints all known datasets for regression problem,
anything else thorws an error.
"""
function listdatasets(which::Symbol=:all)
    print("\nPreprocessData ")
    if which == :all
        println("all datasets:")
        printsubtypes(DatasetName)
    elseif which == :image || which == :i
        println("image datasets:")
        printsubtypes(Image,  1)
    elseif which == :tabular || which == :t
        println("tabular datasets:")
        printsubtypes(Tabular, 1)
    elseif which == :classification || which == :c
        println("classification datasets:")
        printproblemtypes(Classification)
    elseif which == :regression which == :r
        println("regression datasets:")
        printproblemtypes(Regression)
    else
        throw(ArgumentError("Bad identifier."))
    end
end

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
    """
    println(infotext(dataset),text)
end

function info(dataset::MLImage)
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

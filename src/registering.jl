name(dataset::DatasetName) = lowercase(String(nameof(typeof(dataset))))
url(dataset::DatasetName) = error("URL address not specified for $dataset dataset.")
checksum(::DatasetName) = ""
size(::DatasetName) = error("Size not specified for $dataset dataset.")
problem(::DatasetName) = error("Type of problem not specified for $dataset dataset.")
message(::DatasetName) = ""
function prep(::DatasetName) end

"""
    registering(dsName::DatasetName)

Create a registration block for DataDeps package.
"""
function registering(dsName::DatasetName)
    DataDeps.register(DataDep(
        name(dsName),
        """
            Dataset: $(name(dsName))
            Website: $(url(dsName))
            $(message(dsName))
        """,
        url(dsName),
        checksum(dsName),
        post_fetch_method = prep(dsName)
    ))
end

"""
    extract(path)

Extracts file using `DataDeps.unpack` function and returns path to the new extracted file.
"""
function extract(path)
    newPath = splitext(path)[1]
    DataDeps.unpack(path)
    return newPath
end

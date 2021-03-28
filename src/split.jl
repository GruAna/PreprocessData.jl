"""
    split_traintest(dataset; kwargs...)

Split dataset from file to train and test data.

# Arguments
- `dataset::DatasetName`: name (type) of the datset for split

# Keywords
- `trainSize::Float64 = 0.8`: percentage of train data size
- `randomSeed::Int = 12345`: random seed for shuffling rows of the dataset
- `returnArray::Bool = true`: if true returns `DataFrame`, else returns `Tuple` of arrays

Return `Tuple{DataFrame}` (3 DataFrames - first with train data, second with test data,
target values and attributes are together in the `DataFrame`) or return `Tuple{Tuple{Array})`
(two inner tuples - first contains train data (first array attributes and second 1D array
labels) and second test data).
"""
function split_traintest(
    dataset::DatasetName;
    trainSize::Float64=0.8,
    randomSeed::Int=12345,
    returnArray::Bool=false,
)
    if !has_traindata(dataset)
        error("No train data found in $(call(dataset)). Check $dataset registration file
        and its function `size`.")
        return nothing
    end

    # If both files with train and test data are in directory.
    # size(dataset) = (train::Int, valid::Int, test::Int)
    if size(dataset)[3] > 0
        @info "Dataset already separated."

        train = get_data(dataset, :train)
        test = get_data(dataset, :test)

        # in this case there shall be only train data that needs to be separated to train
        # and test. (we are not interested in valid data in this case)
    else
        @info "Dataset has only train data. Separating test data from train data."

        train = get_data(dataset, :train)
        indecesTrain, indecesTest = shuffle_indeces(size(dataset)[1], trainSize, randomSeed)
        train, test = splits(dataset, train, indecesTrain, indecesTest)
    end

    return final_data(returnArray, train, test)
end

"""
    split_trainvalidtest(dataset; kwargs...)

Split dataset from file to train, valid and test data.

# Arguments
-`dataset::DatasetName `: name of the datset for split

# Keywords
- `trainSize::Float64 = 0.8`: percentage of train data size
- `validSize::Float64 = 0.2`: percentage of validation data size, selected from train data
- `randomSeed::Int = 12345`: random seed for shuffling rows of the dataset
- `returnArray::Bool = true`: if true returns `DataFrame`, else returns `Tuple` of arrays

Return `Tuple{DataFrame}` or `Tuple{Tuple{Array}}`. Return splitted data in order: train, valid, test.
If `returnArray = true` return 3 `DataFrames`, else return 3 tuples of arrays (first array
represents attributes, second represents labels for each).
"""
function split_trainvalidtest(
    dataset::DatasetName;
    trainSize::Float64=0.8,
    validSize::Float64=0.2,
    randomSeed::Int=12345,
    returnArray::Bool=false,
)
    if !has_traindata(dataset)
        error("No train data in $call(dataset). Check $dataset registration file
        and its function `size`.")
        return nothing
    end

    # If train, valid, test are present.
    if size(dataset)[2] != 0 && size(dataset)[3] != 0
        @info "Dataset already separated."

        train = get_data(dataset, :train)
        valid = get_data(dataset, :valid)
        test = get_data(dataset, :test)

    # If train and validation data are present in the directory but no test data.
    # Create test data from train data.
    elseif size(dataset)[2] != 0 && size(dataset)[3] == 0
        @info "Dataset already has data for validation, now separating test data."

        train = get_data(dataset, :train)
        valid = get_data(dataset, :valid)

        #create indeces for separation data for train and test
        indecesTrain, indecesTest = shuffle_indeces(size(dataset)[1], trainSize, randomSeed)
        train, test = splits(dataset, train, indecesTrain, indecesTest)

    # If train and test data are present but no valid data.
    # Create valid data from train data
    elseif size(dataset)[3] != 0
        @info "Dataset already has data for testing, now separating validation data."

        train = get_data(dataset, :train)
        test = get_data(dataset, :test)

        #create indeces for separation data for train and test
        indecesValid, indecesTrain = shuffle_indeces(size(dataset)[1], validSize, randomSeed)
        valid, train = splits(dataset, train, indecesValid, indecesTrain)
    else
        @info "Dataset has only train data. Separating test and validation data from train data."

        train = get_data(dataset, :train)

        #create indeces for separation data for train and test
        indecesTrain, indecesTest = shuffle_indeces(size(dataset)[1], trainSize, randomSeed)
        train, test = splits(dataset, train, indecesTrain, indecesTest)

        #create indeces for separation data for validation and train
        indecesValid, indecesTrain = shuffle_indeces(Base.size(indecesTrain,1), validSize, randomSeed)
        valid, train = splits(dataset, train, indecesValid, indecesTrain)
    end

    return final_data(returnArray, train, valid, test)
end

"""
    _shuffle_indeces(data, selectionSize, randomSeed)

Return two arrays containing indeces. First contains indeces with selecetion size,
second the rest (together 100%).

# Arguments
- data`:`Array`, `DataFrame`
- `selectionSize::Float64`: percentage, in what proportion data will be divided
- `randomSeed::Int`: random seed for shuffling indeces
"""
function shuffle_indeces(
    n,
    selectionSize::Float64,
    randomSeed::Int,
)
    # n = Base.size(data, 1)                               #row count
    nSelection = round(Int, selectionSize*n)        #count of rows of train data
    Random.seed!(randomSeed)
    indeces = randperm(n)                           #randomly sorted indeces (numbers 1:n)
    indecesSelection = indeces[1:nSelection]
    indecesRest = indeces[nSelection+1:end]

    return indecesSelection, indecesRest
end

"""
    has_traindata(dataset::DatasetName)

Return true if `size(dataset)[1] != 0`, else return false.
"""
function has_traindata(dataset::DatasetName)
    if size(dataset)[1] != 0
        return true
    else
        return false
    end
end

function get_data(dataset::Tabular, type::Symbol)
    path = getPath(dataset)       # path to a directory of given datadep
    if type == :test
        return CSV.File(joinpath(path, "data-test.csv"), header = true) |> DataFrame
    elseif type == :valid
        return CSV.File(joinpath(path, "data-valid.csv"), header = true) |> DataFrame
    else
        return CSV.File(joinpath(path, "data-train.csv"), header = true) |> DataFrame
    end
end

function get_data(dataset::MLImage, type::Symbol)
    datadep = getModule(dataset)
    if type == :train
        return datadep.traindata()
    elseif type == :test
        return datadep.testdata()
    end
end

function splits(dataset::Tabular, data, indeces1, indeces2)
    #create indeces for separation data
    return data[indeces1,:], data[indeces2,:]
end

function splits(dataset::MLImage, data,  indeces1, indeces2)
    datadep = getModule(dataset)
    return datadep.traindata(indeces1), datadep.traindata(indeces2)
end

<<<<<<< HEAD
function final_data(returnArray::Bool, data1::DataFrame, data2::DataFrame)
    return df_or_array(returnArray, data1), df_or_array(returnArray, data2)
end

function final_data(returnArray::Bool, data1::DataFrame, data2::DataFrame, data3::DataFrame)
=======
function final_data(data::DataFrame; addheader = false, returnArray = false)
    if addheader
        rename!(df ...)
    end
    if returnArray
        ...
        data = (x, y)
    else
        data = df
    end
    return data
end

postprocess(data::DataFrame...; kwargs...) = ([finaldata(d; kwargs...) for d in data]...,)


function final_data(dataset::Tabular, returnArray::Bool, data1::DataFrame, data2::DataFrame, data3::DataFrame, addheader::Bool = false)
    if addheader
        rename!(data1, head)
    end

>>>>>>> febef6f06e969ede1f24e1d29479ddba383e0660
    return df_or_array(returnArray, data1), df_or_array(returnArray, data2), df_or_array(returnArray, data3)
end

function final_data(returnArray::Bool, data::Tuple...)
    return data
end

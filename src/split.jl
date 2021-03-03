"""
    split_traintest(dataset; kwargs...)

Split dataset from file to train and test data.

# Arguments
- `dataset::DatasetName`: name (type) of the datset for split

# Keywords
- `trainSize::Float64 = 0.8`: percentage of train data size
- `randomSeed::Int = 12345`: random seed for shuffling rows of the dataset
- `returnDf::Bool = true`: if true returns `DataFrame`, else returns `Tuple` of arrays

Return `Tuple{DataFrame}` (3 DataFrames - first with train data, second with test data,
target values and attributes are together in the `DataFrame`) or return `Tuple{Tuple{Array})`
(two inner tuples - first contains train data (first array attributes and second 1D array
labels) and second test data).
"""
function split_traintest(
    dataset::DatasetName;
    trainSize::Float64=0.8,
    randomSeed::Int=12345,
    returnDf::Bool=true,
)
    if !has_traindata(dataset)
        error("No train data in $call(dataset). Check $dataset registration file
        and its function `size`.")
    end

    pathToFile = get_files(dataset)

    # size(dataset) = (train::Int, valid::Int, test::Int)
    # in pathToFile files are in this order: test, train, valid (indeces 1, 2, 3),
    # if test is missing then train file is under index 1.
    # If both files with train and test data are in directory.
    if size(dataset)[3] > 0
        @info "Dataset already separated."

        dfTrain = CSV.File(pathToFile[2], header = true) |> DataFrame
        dfTest = CSV.File(pathToFile[1], header = true) |> DataFrame

        return df_or_array(dfTrain, returnDf), df_or_array(dfTest, returnDf)
    end

    # in this case only there shall be only train data that needs to be separated to train
    # and test. (we are not interested in valid date in this case)
    df = CSV.File(pathToFile[1], header = true) |> DataFrame

    #create indeces for separation data for train and test
    indecesTrain, indecesTest = _shuffle_indeces(df, trainSize, randomSeed)

    return _return_splits(df, indecesTrain, indecesTest, returnDf)
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
- `returnDf::Bool = true`: if true returns `DataFrame`, else returns `Tuple` of arrays

Return `Tuple{DataFrame}` or `Tuple{Tuple{Array}}`. Return splitted data in order: train, valid, test.
If `returnDf = true` return 3 `DataFrames`, else return 3 tuples of arrays (first array
represents attributes, second represents labels for each).
"""
function split_trainvalidtest(
    dataset::DatasetName;
    trainSize::Float64=0.8,
    validSize::Float64=0.2,
    randomSeed::Int=12345,
    returnDf::Bool=true,
)
    if !has_traindata(dataset)
        error("No train data in $call(dataset). Check $dataset registration file
        and its function `size`.")
    end

    pathToFile = get_files(dataset)

    # If train, valid, test are present.
    if size(dataset)[2] != 0 && size(dataset)[3] != 0
        @info "Dataset already separated."

        dfTrain = CSV.File(pathToFile[2], header = true) |> DataFrame
        dfVal = CSV.File(pathToFile[3], header = true) |> DataFrame
        dfTest = CSV.File(pathToFile[1], header = true) |> DataFrame

        return df_or_array(dfTrain, returnDf), df_or_array(dfVal, returnDf), df_or_array(dfTest, returnDf)
    end

    # If train and validation data are present in the directory but no test data.
    # Create test data from train data.
    if size(dataset)[2] != 0 && size(dataset)[3] == 0
        @info "Dataset already has data for validation, now separating test data."

        dfTrain = CSV.File(pathToFile[1], header = true) |> DataFrame
        dfVal = CSV.File(pathToFile[2], header = true) |> DataFrame

        #create indeces for separation data for train and test
        indecesTrain, indecesTest = _shuffle_indeces(dfTrain, trainSize, randomSeed)

        if returnDf
            dfTrain, dfTest = _return_splits(dfTrain, indecesTrain, indecesTest, returnDf)
            return dfTrain, dfVal, dfTest
        else

            train, test = _return_splits(dfTrain, indecesTrain, indecesTest, returnDf)

            return train, df_to_array(dfVal), test
        end
    end

    # If train and test data are present but no valid data.
    # Create valid data from train data
    if size(dataset)[3] != 0
        dfTrain = CSV.File(pathToFile[2], header = true) |> DataFrame
        dfTest = CSV.File(pathToFile[1], header = true) |> DataFrame

        #create indeces for separation data for train and test
        indecesTrain, indecesValid = _shuffle_indeces(dfTrain, validSize, randomSeed)

        return _return_splits(dfTrain, indecesTrain, indecesValid, returnDf), df_or_array(dfVal, returnDf)

    end

    df = CSV.File(pathToFile[1], header = true) |> DataFrame

    #create indeces for separation data for train and test
    indecesTrain, indecesTest = _shuffle_indeces(df, trainSize, randomSeed)

    #create indeces for separation data for validation and train
    indecesValid, indecesTrain = _shuffle_indeces(indecesTrain, validSize, randomSeed)

    return _return_splits(df, indecesTrain, indecesValid, indecesTest, returnDf)
end

"""
    _shuffle_indeces(data, selectionSize, randomSeed)

# Arguments
- data`:`Array`, `DataFrame`
- `selectionSize::Float64`: percentage, in what proportion data will be divided
- `randomSeed::Int`: random seed for shuffling indeces
"""
    function _shuffle_indeces(
    data,
    selectionSize::Float64,
    randomSeed::Int,
)
    n = Base.size(data, 1)                               #row count
    nSelection = round(Int, selectionSize*n)        #count of rows of train data
    Random.seed!(randomSeed)
    indeces = randperm(n)                           #randomly sorted indeces (numbers 1:n)
    indecesSelection = indeces[1:nSelection]
    indecesRest = indeces[nSelection+1:end]

    return indecesSelection, indecesRest
end

#for train-test split
"""
    _return_splits(df, indeces..., returnDf)

Return data selected into two parts (train, test) by given indeces.

# Arguments
- `df::DataFrame`
- `indeces1`, `indeces2`: array of numbers (indeces)
- `returnDf::Bool`: if true returns `DataFrame`, else returns `Array`
"""
function _return_splits(df::DataFrame, indeces1, indeces2, returnDf::Bool)
    return df_or_array(df[indeces1,:], returnDf), df_or_array(df[indeces2,:], returnDf)
end

#for train-valid-test
"""
    _return_splits(df, indeces..., returnDf)

Return data selected into three parts (train, valid, test) by given indeces.

# Arguments
- `df::DataFrame`
- `indeces1`, `indeces2`, `indeces3`: array of numbers (indeces)
- `returnDf::Bool`: if true returns `DataFrame`, else returns `Array`
"""
function _return_splits(df::DataFrame, indeces1, indeces2, indeces3, returnDf::Bool)
    return df_or_array(df[indeces1,:], returnDf), df_or_array(df[indeces2,:], returnDf), df_or_array(df[indeces3,:], returnDf)
end

"""
    df_or_array(df::DataFrame, returnDf::Bool)

    Based on returnDf return either a `DataFrame` (true) or an `Array` (false).
"""
function df_or_array(df::DataFrame, returnDf::Bool)
    if returnDf
        return df
    else
        return df_to_array(df)
    end
end

function df_to_array(df::DataFrame)
    return Array(df[:,1:end-1]), df[:,end]
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

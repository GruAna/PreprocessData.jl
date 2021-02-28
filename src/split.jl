"""
    split_traintest(dataset; kwargs...)

Split dataset from file to train and test data.

# Arguments
- `dataset::DatasetName`: name (type) of the datset for split

# Keywords
- `trainSize::Float64 = 0.8`: percentage of train data size
- `randomSeed::Int = 12345`: random seed for shuffling rows of the dataset
- `returnDf::Bool = true`: if true returns `DataFrame`, else returns `Array`

Return `DataFrame` (one with train data another with test data, target values and attributes
are together in the `DataFrame`) or return `Array` (four arrays - two with train data
(attributes and 1D array of target values) and two with test data)
"""
function split_traintest(
    dataset::DatasetName;
    trainSize::Float64=0.8,
    randomSeed::Int=12345,
    returnDf::Bool=true,
)
    pathToFile = get_files(dataset)

    # pathToFile may contain multiple files with already split dataset,
    # get indeces of those files in array pathToFile.
    # We are looking only for Train and Test files.
    indexTr = _getIndexOfFile(pathToFile, "train")
    indexTe = _getIndexOfFile(pathToFile, "test")

    # if both files with train and test data are in directory
    if indexTe != Int(0) && indexTr != Int(0)
        @info "Dataset already separated"

# To be done: ask user to create new split, or let it be...
# Do you want to merge current split and create new one with $randomSeed and $trainSize?

        dfTrain = CSV.File(pathToFile[indexTr], header = true) |> DataFrame
        dfTest = CSV.File(pathToFile[indexTe], header = true) |> DataFrame

        if returnDf
            return dfTrain, dfTest
        else
            xTrain, yTrain = dfToArray(dfTrain, :)
            xTest, yTest = dfToArray(dfTest, :)
            return xTrain, yTrain, xTest, yTest
        end
    end

    # If no index containing the word "train" found,
    # set as the file to be splitted the first file, assuming it is the only one.
    if indexTr == Int(0)
        indexTr = 1
    end

    df = CSV.File(pathToFile[indexTr], header = true) |> DataFrame

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
- `returnDf::Bool = true`: if true returns `DataFrame`, else returns `Array`

Return `DataFrame` or `Array` of train data and one-dimensional `Array` of corresponding
train target values and similarly with test data and test target values.
"""
function split_trainvalidtest(
    dataset::DatasetName;
    trainSize::Float64=0.8,
    validSize::Float64=0.2,
    randomSeed::Int=12345,
    returnDf::Bool=true,
)
    pathToFile = get_files(dataset)

    # pathToFile may contain multiple files with already split dataset,
    # get indeces of those files in array pathToFile.
    indexTr = _getIndexOfFile(pathToFile, "train")
    indexVal = _getIndexOfFile(pathToFile, "valid")
    indexTe = _getIndexOfFile(pathToFile, "test")

    if indexTe != Int(0) && indexTr != Int(0) && indexVal != 0
        @info "Dataset already separated"

# To be done: ask user to create new split, or let it be...
# Do you want to merge current split and create new one with $randomSeed and $trainSize?

        dfTrain = CSV.File(pathToFile[indexTr], header = true) |> DataFrame
        dfVal = CSV.File(pathToFile[indexVal], header = true) |> DataFrame
        dfTest = CSV.File(pathToFile[indexTe], header = true) |> DataFrame

        if returnDf
            return dfTrain, dfVal, dfTest
        else
            xTrain, yTrain = dfToArray(dfTrain, :)
            xVal, yVal = dfToArray(dfVal, :)
            xTest, yTest = dfToArray(dfTest, :)
            return xTrain, yTrain, xVal, yVal, xTest, yTest
        end
    end

    # If train and validation data are present in the directory but no test data.
    # Create test data from train data
    if indexTr != Int(0) && indexVal != 0 && indexTe == Int(0)
        dfTrain = CSV.File(pathToFile[indexTr], header = true) |> DataFrame
        dfVal = CSV.File(pathToFile[indexVal], header = true) |> DataFrame

        #create indeces for separation data for train and test
        indecesTrain, indecesTest = _shuffle_indeces(dfTrain, trainSize, randomSeed)

        return _return_splits(dfTrain, indecesTrain, indecesTest, returnDf), _return_df_or_array(dfVal, returnDf)
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
    n = size(data, 1)                               #row count
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
    if returnDf
        selection1 = df[indeces1,:]
        selection2 = df[indeces2,:]
        return selection1, selection2
    else
        x1, y1 = dfToArray(df, indeces1)
        x2, y2 = dfToArray(df, indeces2)
        return x1, y1, x2, y2
    end
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
    if returnDf
        selection1, selection2 = _return_splits(df, indeces1, indeces2, true)
        selection3 = df[indeces3,:]
        return selection1, selection2, selection3
    else
        x1, y1, x2, y2 = _return_splits(df, indeces1, indeces2, false)
        x3, y3 = dfToArray(df, indeces3)
        return x1, y1, x2, y2, x3, y3
    end
end

function _return_df_or_array(df::DataFrame, returnDf::Bool)
    if returnDf
        return df
    else
        return dfToArray(df,:)
    end
end

function dfToArray(df::DataFrame, indeces)
    return x, y = Array(df[indeces,1:end-1]), df[indeces,end]
end

"""
    _getIndexOfFile(paths::AbstractArray, findStr::String)

    Return index of array element that contains a given String.
    Used to find file in with given String among other files.
"""
function _getIndexOfFile(paths::AbstractArray, findStr::String)
    index::Int = 0
    containing = contains.(paths, findStr)
    for i in containing
        if i == 1
            index = i
            return index
        end
    end
    return index
end

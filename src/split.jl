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
    dsString = name(dataset)
    path = get_path(dsString)
    df = CSV.File(path, header = true) |> DataFrame

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
    dsString = name(dataset)
    path = get_path(dsString)
    df = CSV.File(path, header = true) |> DataFrame

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

#for train-test
"""
    _return_splits(df, indeces..., returnDf)

Return data into two parts selected by given indeces.

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
        x1 = Array(df[indeces1,1:end-1])
        y1 = df[indeces1,end]               #target 1D Array
        x2 = Array(df[indeces2,1:end-1])
        y2 = df[indeces2,end]                #target 1D Array
        return x1, y1, x2, y2
    end
end

#for train-valid-test
"""
    _return_splits(df, indeces..., returnDf)

Return data into three parts selected by given indeces.

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
        lits(df, indeces1, indeces2, false)
        x3, y3 = Array(df[indeces3,1:end-1]), df[indeces3,end]
        return x1, y1, x2, y2, x3, y3
    end
end

"""
    split_traintest(dataset; kwargs...)

Split dataset from file to train and test data.

# Arguments
-`dataset::DatasetName `: dataset for split

# Keyword arguments
- `trainSize::Float64=0.8`: percentage of train data size
- `seed::Int=12345`: random seed for shuffling rows of the dataset
- `toarray::Bool`: if false returns `DataFrame`, else returns `Tuple` of arrays
- `header::Bool`: if true returnes `DataFrame` has column names belonging to the
dataset (it they are found), else default column naming is returned.

Return `Tuple{DataFrame}` (3 DataFrames - first with train data, second with test data,
target values and attributes are together in the `DataFrame`) or return `Tuple{Tuple{Array})`
(two inner tuples - first contains train data (first array attributes and second 1D array
labels) and second test data).
"""
function split_traintest(
    dataset::DatasetName;
    trainSize::Float64=0.8,
    seed::Int=12345,
    kwargs...
)
    dsName = name(dataset)

    if !has_traindata(dataset)
        error("No train data found in $(getpath(dataset)). Check $dsName registration file
        and its function `size`.")
        return nothing
    end

    # If both files with train and test data are in directory.
    # size(dataset) = (train::Int, valid::Int, test::Int)
    if size(dataset)[3] > 0
        @info "Dataset $dsName already separated."

        train = getdata(dataset, :train)
        test = getdata(dataset, :test)

        # in this case there shall be only train data that needs to be separated to train
        # and test. (we are not interested in valid data in this case)
    else
        @info "Dataset $dsName has only train data. Separating test data from train data."

        train = getdata(dataset, :train)
        indecesTrain, indecesTest = shuffle_indeces(size(dataset)[1], trainSize, seed)
        train, test = splits(dataset, train, indecesTrain, indecesTest)
    end

    return postprocess(dataset, train, test; kwargs...)
end


"""
    split_trainvalidtest(dataset; kwargs...)

Split dataset from file to train, valid and test data.

# Arguments
-`dataset::DatasetName`: dataset for split

# Keyword arguments
- `trainSize::Float64=0.8`: percentage of train data size
- `validSize::Float64=0.2`: percentage of validation data size, selected from train data
- `seed::Int=12345`: random seed for shuffling rows of the dataset
- `toarray::Bool`: if false returns `DataFrame`, else returns `Tuple` of arrays
- `header::Bool`: if true returnes `DataFrame` has column names belonging to the
dataset (it they are found), else default column naming is returned.

Return `Tuple{DataFrame}` or `Tuple{Tuple{Array}}`. Return splitted data in order: train,
valid, test.
If `toarray = true` return 3 `DataFrames`, else return 3 tuples of arrays (first array
represents attributes, second represents labels for each).
"""
function split_trainvalidtest(
    dataset::DatasetName;
    trainSize::Float64=0.8,
    validSize::Float64=0.2,
    seed::Int=12345,
    kwargs...
)
    dsName = name(dataset)

    if !has_traindata(dataset)
        error("No train data in $(getpath(dataset)). Check $dsName registration file
        and its function `size`.")
        return nothing
    end

    # If train, valid, test are present.
    if size(dataset)[2] != 0 && size(dataset)[3] != 0
        @info "Dataset $dsName already separated."

        train = getdata(dataset, :train)
        valid = getdata(dataset, :valid)
        test = getdata(dataset, :test)

    # If train and validation data are present in the directory but no test data.
    # Create test data from train data.
    elseif size(dataset)[2] != 0 && size(dataset)[3] == 0
        @info "Dataset $dsName already has data for validation, now separating test data."

        train = getdata(dataset, :train)
        valid = getdata(dataset, :valid)

        #create indeces for separation data for train and test
        indecesTrain, indecesTest = shuffle_indeces(size(dataset)[1], trainSize, seed)
        train, test = splits(dataset, train, indecesTrain, indecesTest)

    # If train and test data are present but no valid data.
    # Create valid data from train data
    elseif size(dataset)[3] != 0
        @info "Dataset $dsName already has data for testing, now separating validation data."

        train = getdata(dataset, :train)
        test = getdata(dataset, :test)

        #create indeces for separation data for train and test
        indecesValid, indecesTrain = shuffle_indeces(size(dataset)[1], validSize, seed)
        valid, train = splits(dataset, train, indecesValid, indecesTrain)
    else
        @info "Dataset $dsName has only train data. Separating test and validation data from train data."

        train = getdata(dataset, :train)

        #create indeces for separation data for train and test
        indecesTrain, indecesTest = shuffle_indeces(size(dataset)[1], trainSize, seed)
        train, test = splits(dataset, train, indecesTrain, indecesTest)

        #create indeces for separation data for validation and train
        indecesValid, indecesTrain = shuffle_indeces(Base.size(indecesTrain,1), validSize, seed)
        valid, train = splits(dataset, train, indecesValid, indecesTrain)
    end

    return postprocess(dataset, train, valid, test; kwargs...)
end

"""
    _shuffle_indeces(n, size, seed)

Return two arrays containing indeces. First contains indeces with selecetion size,
second the rest (together 100%).

# Arguments
- `n::Int`: number of indeces.
- `size::Float64`: percentage, in what proportion data will be divided
- `seed::Int`: random seed for shuffling indeces
"""
function shuffle_indeces(n::Int,size::Float64,seed::Int)
    selection = round(Int, size*n)                  #count of rows of train data
    Random.seed!(seed)
    indeces = randperm(n)                           #randomly sorted indeces (numbers 1:n)
    indecesSelection = indeces[1:selection]
    indecesRest = indeces[selection+1:end]

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

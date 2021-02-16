"""
    split_traintest(dataset; kwargs...)

Split dataset from file to train and test data.

# Arguments
- `dataset::String`: name of the datset for split

# Keywords
- `train_size::Float64 = 0.8`: percentage of train data size
- `random_seed::Int = 12345`: random seed for shuffling rows of the dataset
- `return_df::Bool = true`: if true returns `DataFrame`, else returns `Array`

Return `DataFrame` or `Array` of train data and one-dimensional `Array` of corresponding
train target values and similarly with test data and test target values.
"""
function split_traintest(
    dataset::String;
    train_size::Float64=0.8,
    random_seed::Int=12345,
    return_df::Bool=true,
)
    path = get_path(dataset)
    df = CSV.File(path, header = true) |> DataFrame

    if(return_df)
        x = df[:,1:end-1]                   #values without target col
    else
        x = Array(df[:,1:end-1])
    end

    y = df[:,end]                           #target 1D Array
    n = size(x, 1)                          #row count
    n_train = round(Int, train_size*n)      #count of rows of train data
    Random.seed!(random_seed)
    indeces = randperm(n)                   #randomly sorted indeces (numbers 1:n)
    indeces_train = indeces[1:n_train]
    indeces_test = indeces[n_train+1:end]

    x_train = x[indeces_train, :]
    y_train = y[indeces_train]
    x_test = x[indeces_test, :]
    y_test = y[indeces_test]

    return x_train, y_train, x_test, y_test
end

"""
    split_trainvalidtest(dataset; kwargs...)

Split dataset from file to train, valid and test data.

# Arguments
- `dataset::String`: name of the datset for split

# Keywords
- `train_size::Float64 = 0.8`: percentage of train data size
- `valid_size::Float64 = 0.2`: percentage of validation data size, selected from train data
- `random_seed::Int = 12345`: random seed for shuffling rows of the dataset
- `return_df::Bool = true`: if true returns `DataFrame`, else returns `Array`

Return `DataFrame` or `Array` of train data and one-dimensional `Array` of corresponding
train target values and similarly with test data and test target values.
"""
function split_trainvalidtest(
    dataset::String;
    train_size::Float64=0.8,
    valid_size::Float64=0.2,
    random_seed::Int=12345,
    return_df::Bool=true,
)
    path = get_path(dataset)
    df = CSV.File(path, header = true) |> DataFrame

    if(return_df)
        x = df[:,1:end-1]                   #values
    else
        x = Array(df[:,1:end-1])
    end

    y = df[:,end]                           #target 1D Array
    n = size(x, 1)                          #row count
    n_train = round(Int, train_size*n)      #count of rows of train data
    Random.seed!(random_seed)
    indeces = randperm(n)                   #randomly sorted indeces (numbers 1:n)
    indeces_train = indeces[1:n_train]
    indeces_test = indeces[n_train+1:end]

    #separate data for validation
    n_valid = round(Int, valid_size*n_train)
    indeces_valid = indeces_train[1:n_valid]
    indeces_train = indeces_train[n_valid+1:end]
    x_valid, y_valid = x[indeces_valid, :], y[indeces_valid]
    x_train, y_train = x[indeces_train, :], y[indeces_train]
    x_test, y_test = x[indeces_test, :], y[indeces_test]

    return x_train, y_train, x_valid, y_valid, x_test, y_test
end

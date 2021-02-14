
"""
split_traintest(path, train_size = 0.8, random_seed = 12345, return_df = true)

Split dataset from file to train and test data.
If `return_df` is `true` function returns `DataFrame`, if `false` returns `Array`.
"""
function split_traintest(
path::String;
train_size::Float64 = 0.8,
random_seed::Int = 12345,
return_df::Bool = true              #true - vrati x jako DataFrame,false - jako Array
)
df = CSV.File(path, header = true) |> DataFrame  

if(return_df)
    x = df[:,1:end-1]               #values without target col
else
    x = Array(df[:,1:end-1])
end
y = df[:,end]                       #target 1D Array
n = size(x, 1)                      #row count
n_train = round(Int, train_size*n)  #count of rows of train data
Random.seed!(random_seed)
indeces = randperm(n)               #randomly sorted indeces (numbers 1:n)
indeces_train = indeces[1:n_train]
indeces_test = indeces[n_train+1:end]

x_train = x[indeces_train, :]
y_train = y[indeces_train]
x_test = x[indeces_test, :]
y_test = y[indeces_test]

x_train, y_train, x_test, y_test
end

"""
split_trainvalidtest(path, train_size = 0.8, valid_size = 0.2, random_seed = 12345, return_df = true)

Split dataset from file to train and test data.
If `return_df` is `true` function returns `DataFrame`, if `false` returns `Array`.

Data for validation are selected from train data.
"""
function split_trainvalidtest(
path::String;
train_size::Float64 = 0.8,
valid_size::Float64 = 0.2,
random_seed::Int = 12345,
return_df::Bool = true             
)
df = CSV.File(path, header = true) |> DataFrame  
if(return_df)
    x = df[:,1:end-1]               #values
else
    x = Array(df[:,1:end-1])
end
y = df[:,end]                       #target 1D Array
n = size(x, 1)                      #row count
n_train = round(Int, train_size*n)  #count of rows of train data
Random.seed!(random_seed)
indeces = randperm(n)               #randomly sorted indeces (numbers 1:n)
indeces_train = indeces[1:n_train]
indeces_test = indeces[n_train+1:end]

#separate data for validation
n_valid = round(Int, valid_size*n_train)
indeces_valid = indeces_train[1:n_valid]
indeces_train = indeces_train[n_valid+1:end]
x_valid, y_valid = x[indeces_valid, :], y[indeces_valid]

x_train, y_train = x[indeces_train, :], y[indeces_train]
x_test, y_test = x[indeces_test, :], y[indeces_test]

x_train, y_train, x_valid, y_valid, x_test, y_test
end

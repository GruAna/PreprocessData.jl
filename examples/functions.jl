using PreprocessData
#download dataset and create a simply preprocessed csv file
#function call("name_of_dataset"), name_of_dataset.jl must be present in PreprocessData/src/datasets
call("iris")

#dataset is now downloaded and can be further used

#split dataset into train and test data
#x_ attributes, y_ target values
#by default x_ are returned as `DataFrame`, if return_df=false as `Array`
x_train, y_train, x_test, y_test = split_traintest("iris",
    train_size=0.7,
    random_seed=123,
    return_df=false
)

#split dataset into train, test data and data fro validation
#by default x is returned as `DataFrame`
x_train, y_train, x_valid, y_valid, x_test, y_test = split_trainvalidtest(
    "iris",
    train_size=0.7,
    valid_size=0.15,
    random_seed=123,
)

using PreprocessData
#to use dataset for functions, name_of_dataset.jl must be present in PreprocessData/src/datasets

#split dataset into train and test data, also download dataset and create a simply preprocessed csv file
#by default values are returned as `DataFrame`(toarray=true)
#two DataFrames returned
#targer values and attributes are not separated
train, test = split_traintest(
    PreprocessData.Iris(),
    trainSize=0.7,
    seed=123
)
#split dataset into train and test data
#toarray=false two `Tuple` variables are returned
#attributes - first index of tuple, labels - second index of tuple
train, test = split_traintest(
    PreprocessData.Iris(),
    trainSize=0.7,
    seed=123,
    toarray=true
)
train_attributes = train[1]
train_labels = train[2]
test_attributes = test[1]
test_labels = test[2]

#load column names from file header.csv
train, test = split_traintest(
    PreprocessData.Wine(),
    header = true
)

#split dataset into train, test data and data for validation
#by default `DataFrame` is returned
#load column names from function header (then file header.csv)
train, valid, test = split_trainvalidtest(
    PreprocessData.Iris(),
    trainSize=0.7,
    validSize=0.15,
    seed=123,
    header=true
)

#split dataset that already has valid and train data separated
train, valid, test = split_trainvalidtest(
    PreprocessData.Gisette(),
    trainSize=0.7,
    validSize=0.15,
    seed=123,
)

#split dataset into train, test data and data for validation
#arrays (Tuple) are returned
#attributes - first index of tuple, labels - second index of tuple
train, valid, test = split_trainvalidtest(
    PreprocessData.Iris(),
    toarray = true
)
train_attributes = train[1]
train_labels = train[2]
valid_attributes = valid[1]
valid_labels = valid[2]
test_attributes = test[1]
test_labels = test[2]

#split image data from MLDatasets
train, test = split_traintest(PreprocessData.CIFAR10())
train, valid, test = split_trainvalidtest(PreprocessData.CIFAR100())

#download multiple files where labels and data separated, downloading merges labels and attributes
call(PreprocessData.Gisette())

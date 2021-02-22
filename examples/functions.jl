using PreprocessData
#to use dataset for functions, name_of_dataset.jl must be present in PreprocessData/src/datasets

#split dataset into train and test data, also download dataset and create a simply preprocessed csv file
#by default values are returned as `DataFrame`(returnDf=true)
#two DataFrames returned
#targer values and attributes are not separated
train, test = split_traintest(
    PreprocessData.Iris(),
    trainSize=0.7,
    randomSeed=123
)
#split dataset into train and test data
#returnDf=false four `Array` variables are returned
#x is corresponding to attributes, y to target values
xTrain, yTrain, xTest, yTest = split_traintest(
    PreprocessData.Iris(),
    trainSize=0.7,
    randomSeed=123,
    returnDf=false
)

#split dataset into train, test data and data fro validation
#by default `DataFrame` is returned
split_trainvalidtest(
    PreprocessData.Iris(),
    trainSize=0.7,
    validSize=0.15,
    randomSeed=123,
)

#download multiple files where labels and data separated, downloading merges labels and attributes
call(PreprocessData.Gisette())

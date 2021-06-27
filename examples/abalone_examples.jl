# First load the package
using PreprocessData

# List all registered datasets
listdatasets()

# Looking for a classification dataset, list them.
listdatasets(Classification)

# Show information about Abalone dataset
info(PreprocessData.Abalone())

# Export Abalone dataset for easy usage
using PreprocessData: Abalone

# load dataset to see how it looks like
load(Abalone())

# show column names, if there are any
getheader(Abalone())

# split dataset
train, test = split_traintest(Abalone(), header=true)

# normalization
# compute mean and standard deviation
mean,std=meanstd(train)
normalize!(Std,train)
normalize!(Std,test,mean,std)

# show all possible classes of Abalone dataset
classes(Abalone())

# binarize labels - numbers 1 to 9 are positive labels, others are negative
bin_train=binarize(train[:,end],collect(1:9))
bin_test=binarize(test[:,end],collect(1:9))

# delete files containing Abalone dataset
remove(Abalone())

# check whether Abalone dataset is downloaded
isdownloaded(Abalone())

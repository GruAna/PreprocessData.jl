using PreprocessData
using PreprocessData: rename_cols, place_target, find_in, getpath, getdata, splits
using PreprocessData: Iris, df_to_array, df_or_array, getfilename, getpath
using Test
using DataFrames
using CSV
using DataDeps
using LinearAlgebra
using Statistics

# rename_cols
dfOrig = DataFrame(A=[1,2,3],B=["a","b","c"],C=[5,6,7])
df_renamed = rename(dfOrig, [Symbol("Column 1"), Symbol("Column 2"), :C])
@test rename_cols(dfOrig) == df_renamed

# place_target
dfOrig = DataFrame(A=[1,2,3],B=["a","b","c"],C=[5,6,7])
dfNew = DataFrame(A=[1,2,3],C=[5,6,7],B=["a","b","c"])
rename!(dfNew, [Symbol("Column 1"), Symbol("Column 2"), Symbol("Target")])
@test place_target(2,dfOrig,"") == dfNew

# place_target
dfOrig = DataFrame(A=[1,2,3],B=["a","b","c"],C=[5,6,7])
dfNew = DataFrame(A=[1,2,3],B=["a","b","c"], C=[5,6,7], Target=["first","second","third"])
typeSplit = "train"
labels = DataFrame(NO=["first","second","third"])
file = joinpath(pwd(), string("labels-", typeSplit))
CSV.write(file, labels, header=false) => file
@test place_target(PreprocessData.Labels,dfOrig,typeSplit) == dfNew

# find_in
word1 = "isthereword.valid?"
@test find_in(word1) == "valid"
word2 = "there_is_nothing.really"
@test find_in(word1) == "valid"

# extract
# The Zip archive file.csv.zip must be in the folder in order to test
# pathNotExtracted = joinpath(pwd(), string("file.csv.zip"))
# pathExtracted = joinpath(pwd(), string("file.csv"))
# @test PreprocessData.extract(pathNotExtracted) == pathExtracted

irispath = getpath(Iris())

# getdata
iris = CSV.File(joinpath(irispath, "data-train.csv"), header=true) |> DataFrame
@test getdata(Iris(), PreprocessData.Train) == iris

# load
@test PreprocessData.load(Iris()) == iris

# splits
@test splits(Iris(), iris, [1,3], [2,4]) == (iris[[1,3],:], iris[[2,4],:])

# loadheader
header = ["sepal length", "sepal width", "petal length", "petal width", "class"]
@test PreprocessData.loadheader(joinpath(irispath, "header.csv"),Iris()) == header

# getheader
@test PreprocessData.getheader(Iris()) == header

#getfilename
@test PreprocessData.getfilename(joinpath(irispath, "data-train.csv")) == "data-train"

# df_to_array
dfOrig = DataFrame(A=[1,2,3],B=["a","b","c"],C=[5,6,7], D=[1,1,1])
array1 = [1 "a";2 "b";3 "c"]
array2 = [5 1;6 1;7 1]
@test df_to_array(dfOrig, cols=2) == (array1, array2)

# df_or_array
@test PreprocessData.df_or_array(dfOrig, true, cols=2) == (array1, array2)

# labels
@test PreprocessData.labels(Iris()) == iris[:,end]

# classes
@test classes(Iris()) == ["Iris-setosa", "Iris-versicolor", "Iris-virginica"]

# binarize
dfOrig = DataFrame(A=[1,2,3],B=["a","b","c"],Target=[5,6,7])
@test binarize(dfOrig[:,:Target], [5]) == [1; 0; 0]
@test binarize(dfOrig[:,:Target], [5,6]) == [true; true; false]

# makerow
@test PreprocessData.makerow([1;2;3]) == [1 2 3]

# selectnumeric (and ignore Target)
dfOrig = DataFrame(A=[1,2,3],B=["a","b","c"],Target=[5,6,7])
@test PreprocessData.selectnumeric(dfOrig) == [1]

# selectnumeric
array = [1 "a";2 "b";3 "c"]
@test PreprocessData.selectnumeric(array) == (:,[1])

# l2norm
dfOrig = DataFrame(A=[1,2,3],B=["a","b","c"],C=[5.4,6.3,7.2],Target=[5,6,7])
array = [1 "a" 5.4;2 "b" 6.3;3 "c" 7.2]
Norm = [norm([1,2,3]); norm([5.4,6.3,7.2])]
@test l2norm(dfOrig) == Norm
@test l2norm(array) == PreprocessData.makerow(Norm)

# minmax
min, max = ([minimum([1,2,3]); minimum([5.4,6.3,7.2])], [maximum([1,2,3]); maximum([5.4,6.3,7.2])] )
@test PreprocessData.minmax(dfOrig) == (min, max)
@test PreprocessData.minmax(array) == (PreprocessData.makerow(min),PreprocessData.makerow(max))

# meanstd
Mean, Std = ([mean([1,2,3]); mean([5.4,6.3,7.2])], [std([1,2,3]); std([5.4,6.3,7.2])] )
@test PreprocessData.meanstd(dfOrig) == (Mean, Std)
@test PreprocessData.meanstd(array) == (PreprocessData.makerow(Mean),PreprocessData.makerow(Std))

# _select
dfOrig = DataFrame(A=[1,2,3],B=["a","b","c"],C=[5.4,6.3,7.2],Target=[5,6,7])
dfNew = DataFrame(A=[1,2,3],B=["a","b","c"])
@test PreprocessData._select(dfOrig, 1:2) == dfNew
array = [1 "a" 5.4;2 "b" 6.3;3 "c" 7.2]
arrayNew = [1 "a";2 "b";3 "c"]
@test PreprocessData._select(array, (:,1:2)) == arrayNew

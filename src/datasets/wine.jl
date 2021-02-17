struct Wine <: DatasetName end
url(::Wine) = "https://archive.ics.uci.edu/ml/machine-learning-databases/wine/wine.data"
checksum(::Wine) = "6be6b1203f3d51df0b553a70e57b8a723cd405683958204f96d23d7cd6aea659"
preprocess(::Wine) = path -> preprocess(path, name(Wine()), target_col = 1 )
sampleSize(::Wine) = (178,)

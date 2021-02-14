struct Adult <: DatasetName end
name(::Adult) = "adult"
url(::Adult) = "https://archive.ics.uci.edu/ml/machine-learning-databases/adult/adult.data"
checksum(::Adult) = "5b00264637dbfec36bdeaab5676b0b309ff9eb788d63554ca0a249491c86603d"
preprocess(::Adult) = path -> preprocess(path, name1(Adult()), target_col = 15, categorical_cols=[2; 4; 6:10; 14] )
sampleSize(::Adult) = (32561,)
push!(dict, "adult" => Adult())
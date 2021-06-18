struct Adult <: Tabular end
url(::Adult) = ["https://archive.ics.uci.edu/ml/machine-learning-databases/adult/adult.data", "https://archive.ics.uci.edu/ml/machine-learning-databases/adult/adult.test"]
checksum(::Adult) = ["5b00264637dbfec36bdeaab5676b0b309ff9eb788d63554ca0a249491c86603d", "a2a9044bc167a35b2361efbabec64e89d69ce82d9790d2980119aac5fd7e9c05"]
prep(::Adult) = [path -> preprocess(path, Adult(); delim=", "), path -> preprocess(path, Adult(); delim=", ", skipto=2)]
target(::Adult) = 15
categorical(::Adult) = [2; 4; 6:10; 14]
size(::Adult) = (32561, 0, 16281)
problem(::Adult) = Classification

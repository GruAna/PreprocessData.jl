module PreprocessData

using DataDeps, DataFrames, CSV, Random

function call_dataset(name::String)
    registering_dataset(name)
    @datadep_str name
end

#priklad => hodnoty (website, checksum, param pro preprocess) pro dataset iris
function registering_dataset(
    name::String,
)
    remote_path = "http://archive.ics.uci.edu/ml/machine-learning-databases/iris/iris.data"
    register(DataDep(
        name,
        """
            Dataset: $name
            Website: $remote_path
        """,
        remote_path,
        "6f608b71a7317216319b4d27b4d9bc84e6abd734eda7872b71a458569e2656c0",
        post_fetch_method = (path -> begin
            PreprocessData.preprocess(path,name,
                target_col = 5,
            )
        end)
    ))
end


function preprocess(
    path::String,
    name::String;
    header_names::Union{Vector{String}, Vector{Symbol}, Int} = 0,
    target_col::Int = 0,
    categorical_cols::Union{Int, UnitRange{Int}} = 1:0, 
    kwargs...
)
    df = CSV.File(
        path, 
        header = header_names,
        missingstrings = ["", "NA", "?", "*", "#DIV/0!"],
        truestrings = ["T", "t", "TRUE", "true", "y", "yes"],
        falsestrings = ["F", "f", "FALSE", "false", "n", "no"],
        kwargs...
        ) |> DataFrame   
        
        
    last_col_index = ncol(df)

    for i in categorical_cols
        rename!(df, i => "Categ-"*names(df)[i])
    end

    #presune target sloupec na konec, pokud tam uz neni
    if target_col > 0 && target_col < last_col_index
        df.target = df[!,target_col]
        df = df[!,1:end .!=target_col]
    end
    if target_col == last_col_index
        rename!(df, last_col_index => "Target")
    end
    
    path_for_save = joinpath(dirname(path), "data-"*name*".csv")
    println(path_for_save)
    CSV.write(path_for_save, df, delim=',', writeheader=true)

end

#train-test split
function split_traintest(
    path::String;
    train_size::Float64 = 0.8,
    random_seed::Int = 12345,
    return_df::Bool = true              #true - vrati x jako DataFrame,false - jako Array
)
    df = CSV.File(
        path, header=true,
        missingstrings=["", "NA", "?", "*", "#DIV/0!"],
        truestrings=["T", "t", "TRUE", "true", "y", "yes"],
        falsestrings=["F", "f", "FALSE", "false", "n", "no"],
        ) |> DataFrame  

    if(return_df)
        x = df[:,1:end-1]               #hodnoty bez sloupce target
    else
        x = Array(df[:,1:end-1])
    end
    y = df[:,end]                       #target 1D Array
    n = size(x, 1)                      #pocet radku
    n_train = round(Int, train_size*n)  #pocet trenovacich dat (radky)
    Random.seed!(random_seed)
    indeces = randperm(n)               #nahodne serazene indexy (cisla 1:n)
    indeces_train = indeces[1:n_train]
    indeces_test = indeces[n_train+1:end]

    x_train = x[indeces_train, :]
    y_train = y[indeces_train]
    x_test = x[indeces_test, :]
    y_test = y[indeces_test]

    x_train, y_train, x_test, y_test
end

#train-validate-test split
function split_trainvalidtest(
    path::String;
    train_size::Float64 = 0.8,
    valid_size::Float64 = 0.2,
    random_seed::Int = 12345,
    return_df::Bool = true              #true - vrati x jako DataFrame,false - jako Array
)
    df = CSV.File(
        path, header=true,
        missingstrings=["", "NA", "?", "*", "#DIV/0!"],
        truestrings=["T", "t", "TRUE", "true", "y", "yes"],
        falsestrings=["F", "f", "FALSE", "false", "n", "no"],
        ) |> DataFrame  
    if(return_df)
        x = df[:,1:end-1]               #hodnoty
    else
        x = Array(df[:,1:end-1])
    end
    y = df[:,end]                       #target 1D Array
    n = size(x, 1)                      #pocet radku
    n_train = round(Int, train_size*n)  #pocet trenovacich dat (radky)
    Random.seed!(random_seed)
    indeces = randperm(n)               #nahodne serazene indexy (cisla 1:n)
    indeces_train = indeces[1:n_train]
    indeces_test = indeces[n_train+1:end]

    #oddel validacni data
    n_valid = round(Int, valid_size*n_train)
    indeces_valid = indeces_train[1:n_valid]
    indeces_train = indeces_train[n_valid+1:end]
    x_valid, y_valid = x[indeces_valid, :], y[indeces_valid]
    
    x_train, y_train = x[indeces_train, :], y[indeces_train]
    x_test, y_test = x[indeces_test, :], y[indeces_test]

    x_train, y_train, x_valid, y_valid, x_test, y_test
end


end # module

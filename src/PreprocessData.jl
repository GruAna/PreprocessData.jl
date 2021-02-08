module PreprocessData

using DataDeps, DataFrames, CSV, Random

function registering_dataset(
    name::String,
    remote_path::String
)
    register(DataDep(
        name,
        """
            Dataset: $name
            Website: $remote_path
        """,
        remote_path
    ))
end

#nacte data z datadeps, vrati df, kde posledni sloupec je target
#header_name vector s nazvy sloupcu, =0 vygeneruji se 
#pred nazev target sloupce pripoji "Targ"
#pred sloupce s kateg. daty pripoji "Categ"
function preprocess(
    name::String;
    header_names::Union{Vector{String}, Vector{Symbol}, Int} = 0,
    target_col::Int = 0,
    categorical_cols::Union{Int, UnitRange{Int}} = 1:0, 
    kwargs...
)
    path = @datadep_str name
    df = CSV.File(
        joinpath(path, readdir(path)[1]),           #data = jediny soubor ve slozce @datadep_str name, urcite existuje nejaky lepsi zpusob ziskani cesty vcetne jmena souboru
        header=header_names,
        missingstrings=["", "NA", "?", "*", "#DIV/0!"],
        truestrings=["T", "t", "TRUE", "true", "y", "yes"],
        falsestrings=["F", "f", "FALSE", "false", "n", "no"],
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
        rename!(df, last_col_index => "Targ-"*names(df)[target_col])
    end
    df
end

#train-test split
function split_traintest(
    df::DataFrame;
    train_size::Float64 = 0.8,
    random_seed::Int = 12345,
    return_df::Bool = true              #true - vrati x jako DataFrame,false - jako Array
)
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

    x_train = x[indeces_train, :]
    y_train = y[indeces_train]
    x_test = x[indeces_test, :]
    y_test = y[indeces_test]

    x_train, y_train, x_test, y_test
end

#train-validate-test split
function split_trainvalidtest(
    df::DataFrame;
    train_size::Float64 = 0.8,
    valid_size::Float64 = 0.2,
    random_seed::Int = 12345,
    return_df::Bool = true              #true - vrati x jako DataFrame,false - jako Array
)
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

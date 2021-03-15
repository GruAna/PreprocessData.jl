struct Gisette <: Tabular end
function url(::Gisette)
    [
        "https://archive.ics.uci.edu/ml/machine-learning-databases/gisette/gisette_valid.labels",
        "https://archive.ics.uci.edu/ml/machine-learning-databases/gisette/GISETTE/gisette_valid.data",
        "https://archive.ics.uci.edu/ml/machine-learning-databases/gisette/GISETTE/gisette_train.labels",
        "https://archive.ics.uci.edu/ml/machine-learning-databases/gisette/GISETTE/gisette_train.data",
    ]
end

function checksum(::Gisette)
    [
        "a6b857a0448023f033c4dda2ef848714b4be2ae45ce598d088fb3efb406e08c5",
        "5cea897956dd172a006132738254a27a8f61ecc1ceb6f5b20639c281d2942254",
        "42bd681fe51b161f033df773df14a0116e492676555ab14616c1b72edc054075",
        "6d4c5e998afe67937b9e77a3334e03c85e545ebc65a6eb1333ffc14125cfc389"
    ]
end
function preprocess(::Gisette)
    [
        path -> preprocess(path),
        path -> preprocess(path, Gisette(), target_col="gisette_valid.labels"),
        path -> preprocess(path),
        path -> preprocess(path, Gisette(), target_col="gisette_train.labels")
    ]
end
size(::Gisette) = (6000, 1000, 0)

"""
    When dataset does not lead to a valid file dataset.jl
"""
struct DatasetNotFoundErr <: Exception
    msg::String
end
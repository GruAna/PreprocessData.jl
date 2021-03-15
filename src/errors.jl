"""
    When `size(dataset)[1] == 0`.
"""
struct noTrainData <: Exception
    msg::String = "No train data in $call(dataset)"
end

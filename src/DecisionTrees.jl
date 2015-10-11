module DecisionTrees

using MacroTools, DataFrames

Base.call{T<:Number}(x::T, y) = x*y

include("data.jl")
include("typeddicts.jl")
include("datasets.jl")
include("impurity.jl")
include("tree.jl")

end # module

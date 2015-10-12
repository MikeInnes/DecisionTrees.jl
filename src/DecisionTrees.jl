module DecisionTrees

using MacroTools, DataFrames

Base.call{T<:Number}(x::T, y) = x*y

include("typeddicts.jl")
include("datasets.jl")
include("impurity.jl")
include("tree.jl")
include("bench.jl")

end # module

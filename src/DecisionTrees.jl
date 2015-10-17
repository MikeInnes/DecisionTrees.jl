module DecisionTrees

using MacroTools, Data, Lazy, StatsBase

include("impurity.jl")
include("training.jl")
include("integrations.jl")
include("meta.jl")
include("bench.jl")

end # module

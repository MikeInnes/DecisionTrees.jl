module DecisionTrees

using MacroTools, Data, Lazy, StatsBase

include("impurity.jl")
include("training.jl")
include("tree.jl")

include("forests/bagging.jl")
include("forests/forests.jl")

include("integrations.jl")
include("meta.jl")

end # module

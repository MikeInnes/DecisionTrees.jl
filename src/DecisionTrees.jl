module DecisionTrees

using MacroTools, Data, Lazy

include("impurity.jl")
include("tree.jl")
include("integrations.jl")
include("meta.jl")
include("bench.jl")

end # module

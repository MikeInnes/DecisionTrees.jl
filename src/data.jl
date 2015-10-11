type Categorical end
type Ordinal end
type Continuous end

vartype(::DataType) = Categorical()
vartype{T<:Number}(::Type{T}) = Continuous()
vartype(x) = vartype(typeof(x))

using RDatasets

data = dataset("datasets", "iris")

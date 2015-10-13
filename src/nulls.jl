import Data: vartype

vartype{T}(::Type{Nullable{T}}) = vartype(T)

isleft(::Categorical, x::Nullable, z::Nullable) = isequal(x, z)

isleft(::Continuous, x::Nullable, z::Nullable) =
  isequal(x, z) || (!(isnull(x) || isnull(z)) && get(x) ≤ get(z))

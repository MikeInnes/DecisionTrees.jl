import Data: vartype

vartype{T}(::Type{Nullable{T}}) = vartype(T)

isleft(::Categorical, x::Nullable, y::Nullable) = isequal(x, y)

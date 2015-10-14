# Nullable Arrays

import Data: vartype

vartype{T}(::Type{Nullable{T}}) = vartype(T)

isleft(::Categorical, x::Nullable, z::Nullable) = isequal(x, z)

isleft(::Continuous, x::Nullable, z::Nullable) =
  isequal(x, z) || (!(isnull(x) || isnull(z)) && get(x) ≤ get(z))

# Pooled Data

function pcat(xs::PooledVector)
  counts = zeros(length(xs.values))
  for x in xs.data
    @inbounds counts[x] += 1
  end
  return scale!(counts, 1/length(xs))
end

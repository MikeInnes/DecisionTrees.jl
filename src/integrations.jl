# Nullable Arrays

isleft(::Categorical, x::Nullable, z::Nullable) = isequal(x, z)

isleft(::Continuous, x::Nullable, z::Nullable) =
  isequal(x, z) || (!(isnull(x) || isnull(z)) && get(x) ≤ get(z))

# Pooled Data

import Data: @static

function pcat(xs::PooledVector)
  counts = zeros(length(names(xs)))
  for x in xs.data
    @inbounds counts[x] += 1
  end
  return scale!(counts, 1/length(xs))
end

function score_inner!(xs, ys::PooledVector, z, left, right)
  for i = 1:length(xs)
    @fastmath @inbounds isleft(xs[i], z) ? left[ys.data[i]] += 1 : right[ys.data[i]] += 1
  end
end

function score_inner!(xs::PooledVector, ys::PooledVector, z, left, right)
  lefts = @static Array(Bool, length(names(xs)))
  fill!(lefts, false)
  @fastmath @inbounds for i = 1:length(names(xs))
    lefts[i] = isleft(names(xs)[i], z)
  end
  for i = 1:length(xs)
    @fastmath @inbounds lefts[xs.data[i]] ? left[ys.data[i]] += 1 : right[ys.data[i]] += 1
  end
end

function score(xs, ys::PooledVector, z;
               orig = score(ys))
  @fastmath begin
    left  = @static zeros(length(names(ys)))
    right = @static zeros(length(names(ys)))
    score_inner!(xs, ys, z, left, right)
    n, nleft, nright = length(ys), sum(left), sum(right)
    (nleft ≤ 10 || nright ≤ 10) && return 0.
    pleft, pright = nleft/n, nright/n
    scale!(left, 1/nleft); scale!(right, 1/nright)
    return orig - pleft*gini(left) - pright*gini(right)
  end
end

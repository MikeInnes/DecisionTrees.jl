# Nullable Arrays

isleft(::Categorical, x::Nullable, z::Nullable) = isequal(x, z)

isleft(::Continuous, x::Nullable, z::Nullable) =
  isequal(x, z) || (!(isnull(x) || isnull(z)) && get(x) ≤ get(z))

# Pooled Data

import Data: getdata

typealias Pooled Union{PooledVector, SubPooledVector}

function pcat(xs::Pooled)
  counts = zeros(length(names(xs)))
  for x in getdata(xs)
    @inbounds counts[x] += 1
  end
  return scale!(counts, 1/length(xs))
end

function score_inner!(xs, ys_::Pooled, z, left, right)
  ys = getdata(ys_)
  for i = 1:length(xs)
    @inbounds (isleft(xs[i], z) ? left : right)[ys[i]] += 1
  end
end

function score_inner!(xs::Pooled, ys::Pooled, z, left, right)
  xs_, ys_ = getdata(xs), getdata(ys)
  nx = length(names(xs))
  lefts = Array(Bool, nx)
  for i = 1:nx
    lefts[i] = isleft(names(xs)[i], z)
  end
  for i = 1:length(xs)
    @inbounds (lefts[xs_[i]] ? left : right)[ys_[i]] += 1
  end
end

function score(xs, ys::Pooled, z)
  left, right = zeros(length(names(ys))), zeros(length(names(ys)))
  score_inner!(xs, ys, z, left, right)
  n, nleft, nright = length(ys), sum(left), sum(right)
  pleft, pright = nleft/n, nright/n
  scale!(left, 1/nleft); scale!(right, 1/nright)
  return gini(pcat(ys)) - pleft*gini(left) - pright*gini(right)
end

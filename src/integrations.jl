# Nullable Arrays

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

function score_inner!(xs, ys::PooledVector, z, left, right)
  for i = 1:length(xs)
    @inbounds (isleft(xs[i], z) ? left : right)[ys.data[i]] += 1
  end
end

function score_inner!(xs::PooledVector, ys::PooledVector, z, left, right)
  nx = length(unique(xs))
  lefts = Array(Bool, nx)
  for i = 1:nx
    lefts[i] = isleft(unique(xs)[i], z)
  end
  for i = 1:length(xs)
    @inbounds (lefts[xs.data[i]] ? left : right)[ys.data[i]] += 1
  end
end

function score(xs, ys::PooledVector, z)
  left, right = zeros(length(unique(ys))), zeros(length(unique(ys)))
  score_inner!(xs, ys, z, left, right)
  n, nleft, nright = length(ys), sum(left), sum(right)
  pleft, pright = nleft/n, nright/n
  scale!(left, 1/nleft); scale!(right, 1/nright)
  return gini(pcat(ys)) - pleft*gini(left) - pright*gini(right)
end

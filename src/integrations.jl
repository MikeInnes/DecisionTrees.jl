# Nullable Arrays

isleft(::Categorical, x::Nullable, z::Nullable) = isequal(x, z)

isleft(::Continuous, x::Nullable, z::Nullable) =
  isequal(x, z) || (!(isnull(x) || isnull(z)) && get(x) ≤ get(z))

# Pooled Data

function pcat(xs::PooledVector)
  counts = zeros(length(names(xs)))
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
  lefts = Array(Bool, length(names(xs)))
  for i = 1:length(names(xs))
    lefts[i] = isleft(names(xs)[i], z)
  end
  for i = 1:length(xs)
    @inbounds (lefts[xs.data[i]] ? left : right)[ys.data[i]] += 1
  end
end

function score(xs, ys::PooledVector, z;
               orig = gini(pcat(ys)))
  left, right = zeros(length(names(ys))), zeros(length(names(ys)))
  score_inner!(xs, ys, z, left, right)
  n, nleft, nright = length(ys), sum(left), sum(right)
  pleft, pright = nleft/n, nright/n
  scale!(left, 1/nleft); scale!(right, 1/nright)
  return orig - pleft*gini(left) - pright*gini(right)
end

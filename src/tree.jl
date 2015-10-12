# x: independent variable
# y: dependent variable
# z: value to split x on

isleft(x, z) = isleft(vartype(x), x, z)

isright(args...) = !isleft(args...)

isleft(::Continuous, x, z) = x ≤ z

isleft(::Ordinal, x, z) = x ≤ z

isleft(::Categorical, x, z) = x == z

function split(xs, ys, z)
  left = eltype(ys)[]
  right = eltype(ys)[]
  for (i, x) in enumerate(xs)
    push!(isleft(vartype(eltype(xs)), x, z) ? left : right, ys[i])
  end
  return left, right
end

split(xs, z) = split(xs, 1:length(xs), z)::NTuple{2, Vector{Int}}

function score(xs, ys, z)
  left, right = split(xs, ys, z)
  improvement(ys, left, right)
end

function bestsplit(xs, ys)
  best, imp = first(xs), 0.
  for x in unique(xs)
    if (i = score(xs, ys, x)) > imp
      best = x
      imp = i
    end
  end
  return best, imp
end

function bestsplit(data::DataSet, y)
  ys = data[y]
  col, z, score = :nothing, nothing, 0.
  for name in names(data)
    name == Symbol(y) && break
    z′, score′ = bestsplit(data[name], ys)
    score′ > score && ((col, z, score) = (name, z′, score′))
  end
  return col, z, score
end

function split(data::DataSet, x, z)
  left, right = split(data[x], z)
  return data[left], data[right]
end

immutable Branch
  col::Symbol
  val
  left::Nullable{Branch}
  right::Nullable{Branch}
end

isstop(data) = length(data) < 10

function tree(data, y)
  isstop(data) && return
  col, val, imp = bestsplit(data, y)
  imp ≤ 0 && return
  left, right = split(data, col, val)
  return Branch(col, val, tree(left, y), tree(right, y))
end

@time tree(data, f"Species")

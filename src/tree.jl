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

split(xs, z) = split(xs, 1:length(xs), z)

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

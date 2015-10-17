# x: independent variable
# y: dependent variable
# z: value to split x on

isleft(x, z) = isleft(vartype(x), x, z)

isright(args...) = !isleft(args...)

isleft(::Continuous, x, z) = x ≤ z

isleft(::Categorical, x, z) = x == z

function split(xs, ys, z)
  left = eltype(ys)[]
  right = eltype(ys)[]
  for (i, x) in enumerate(xs)
    push!(isleft(vareltype(xs), x, z) ? left : right, ys[i])
  end
  return left, right
end

split(xs, z) = split(xs, 1:length(xs), z)::NTuple{2, Vector{Int}}

function score(xs, ys, z; orig = nothing)
  left, right = split(xs, ys, z)
  improvement(ys, left, right)
end

splitters(xs) = splitters(vareltype(xs), xs)

splitters(::Categorical, xs) = unique(xs)

groups(i, n = 10) = i ≤ n ? collect(1:i) : (g = i/(n+1); [round(Int, x) for x in g:g:n*g])

splitters(::Continuous, xs) = sort(xs)[groups(length(xs))]

function bestsplit(xs::AbstractVector, ys::AbstractVector)
  best, imp = first(xs), -Inf
  orig = gini(pcat(ys))
  for x in splitters(xs)
    if (i = score(xs, ys, x, orig = orig)) > imp
      best = x
      imp = i
    end
  end
  return best, imp
end

function bestsplit(data::Table, y)
  ys = data[y]
  col, z, score = nothing, nothing, -Inf
  for name in names(data)
    name == Symbol(y) && continue
    z′, score′ = bestsplit(data[name], ys)
    score′ > score && ((col, z, score) = (name, z′, score′))
  end
  return col, z, score
end

function split(data::Table, x, z)
  left, right = split(data[x], z)
  view(data, left), view(data, right)
end

@defonce immutable Branch
  col::Symbol
  val
  left::Nullable{Branch}
  right::Nullable{Branch}
end

left(b::Branch) = get(b.left)
right(b::Branch) = get(b.right)

@gensym leaf

Leaf(val) = Branch(leaf, val, nothing, nothing)

isleaf(b::Branch) = b.col == leaf

isstop(ys) = length(ys) ≤ 100

final(xs) = final(vareltype(xs), xs)

final(::Categorical, xs) = mode(xs)

final(::Continuous, xs) = mean(xs)

function tree(data, y)
  isstop(data[y]) && @goto leaf
  col, val, imp = bestsplit(data, y)
  imp ≤ 0 && @goto leaf
  left, right = split(data, col, val)
  return Branch(col, val, tree(left, y), tree(right, y))

  @label leaf
  return Leaf(final(data[y]))
end

function classify(tree::Branch, data::Table, row::Integer)
  isleaf(tree) && return tree.val
  next = isleft(data[tree.col, row], tree.val) ? left(tree) : right(tree)
  return classify(data::Table, next, row)
end

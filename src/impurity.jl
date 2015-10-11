function pcat(cats)
  counts = Dict{eltype(cats), Float64}()
  for cat in cats
    counts[cat] = get(counts, cat, 0.) + 1
  end
  cs = collect(values(counts))
  return scale!(cs, 1/sum(cs))
end

macro sumby(f, xs)
  @capture(f, x_ -> fx_) || error("@sumby: invalid summation function")
  quote
    sum = 0.
    for $(esc(x)) in $(esc(xs))
      sum += $(esc(fx))
    end
    sum
  end
end

gini(ps) = @sumby(p -> p(1-p), ps)

entropy(ps) = -@sumby(p -> p*log(p), ps)

score(xs) = score(vartype(eltype(xs)), xs)

# TODO: don't hard-code gini
score(::Categorical, xs) = gini(pcat(xs))

score(::Ordinal, xs) = score(Categorical(), xs)

function improvement(ys, left, right)
  pleft = length(left)/length(ys)
  pright = length(right)/length(ys)
  return score(ys) - pleft*score(left) - pright*score(right)
end

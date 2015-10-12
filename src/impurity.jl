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

function variance(xs)
  sum = 0.
  for i = 1:length(xs), j = 1:length(xs)
    sum += (xs[i]-xs[j])^2
  end
  return sum/2length(xs)^2
end

score(xs) = score(vareltype(xs), xs)

# TODO: don't hard-code gini
score(::Categorical, xs) = gini(pcat(xs))

score(::Continuous, ys) = variance(ys)

improvement(ys, left, right) = improvement(vareltype(ys), ys, left, right)

function improvement(vt::Categorical, ys, left, right)
  pleft = length(left)/length(ys)
  pright = length(right)/length(ys)
  return score(vt, ys) - pleft*score(vt, left) - pright*score(vt, right)
end

improvement(vt::Continuous, ys, left, right) =
  score(vt, ys) - score(vt, left) - score(vt, right)

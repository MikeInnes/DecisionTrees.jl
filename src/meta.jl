using Lazy
import MacroTools: postwalk

isleftexpr(x, z) = isleftexpr(vartype(z), x, z)

isleftexpr(::Categorical, x, z) = :($x == $z)
isleftexpr(::Continuous, x, z) = :($x ≤ $z)

function expr(b::Branch)
  isleaf(b) && return b.val
  :(if isleft($(b.col), $(b.val))
      $(expr(get(b.left)))
    else
      $(expr(get(b.right)))
    end)
end

function simplify_if(ex)
  postwalk(ex) do ex
    @match ex begin
      (c_ ? t_ : t_) => t
      (c_ ? (c′_ ? t_ : f_) : f_) => :($c && $c′ ? $t : $f)
      (c_ ? (c′_ ? f_ : t_) : f_) => :($c && !$c′ ? $t : $f)
      (c_ ? t_ : (c′_ ? t_ : f_)) => :($c && $c′ ? $t : $f)
      (c_ ? t_ : (c′_ ? f_ : t_)) => :($c && !$c′ ? $t : $f)
      x_ => x
    end
  end
end

function simplify_cond(ex)
  postwalk(ex) do ex
    @match ex begin
      !(a_ && b_) => :($a || $b)
      x_ => x
    end
  end
end

simplify(ex) = @> ex simplify_if simplify_cond

function humanify(ex)
  postwalk(simplify(ex)) do ex
    @match ex begin
      isleft(args__) => isleftexpr(args...)
      x_ => x
    end
  end
end

function addwidths!(xs, ys)
  length(xs) < length(ys) && return addwidths!(ys, xs)
  for i = 1:length(ys)
    xs[i] += ys[i]
  end
  return xs
end

Base.size(b::Branch) =
  isleaf(b) ? [1] : [1, addwidths!(size(left(b)), size(right(b)))...]

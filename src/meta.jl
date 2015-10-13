function expr(b::Branch)
  isleaf(b) && return b.val
  :(if isleft(data[Field{$(Expr(:quote, b.col))}()], $(b.val))
      $(expr(get(b.left)))
    else
      $(expr(get(b.right)))
    end)
end

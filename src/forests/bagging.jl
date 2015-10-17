typealias AFloat AbstractFloat

immutable Bagger{NC, NR}
  cols::NC
  rows::NR
end

Bagger() = Bagger(sqrt, n->0.1n)

bag(cols::Vector{Symbol}, n′::Integer) =
  sample(cols, n′, replace = false, ordered = true)

bag(cols::Vector{Symbol}, n::AFloat) = bag(cols, round(Int, n))
bag(cols::Vector{Symbol}, f::Function) = bag(cols, f(length(cols)))
bag(cols::Vector{Symbol}, b::Bagger) = bag(cols, b.cols)

bag(n::Int, n′::Integer) = rand(1:n, n′)
bag(n::Int, n′::AFloat) = bag(n, round(Int, n′))
bag(n::Int, f::Function) = bag(n, f(n))
bag(n::Int, b::Bagger) = bag(n, b.rows)

bag(b::Bagger, d::Table) = view(d, bag(names(d), b), bag(length(d), b))

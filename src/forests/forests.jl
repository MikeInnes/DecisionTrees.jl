immutable Forest{T}
  model::T
  size::Int
  bagger
  trees::Vector{T}
end

Forest(model = DecisionTree(), n = 100, b = Bagger()) =
  Forest(model, n, b, typeof(model)[])

train(f::Forest, d::Table, y) =
  with(f, f"trees" => [train(f.model, bag(f.bagger, d), y) for i = 1:f.size])

classify(f::Forest, d::Table, y) =
  mode([classify(model, d, y) for model in f.trees])

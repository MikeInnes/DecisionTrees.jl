export Forest

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

# Cross validation

export class_act

function accuracy(model, data::Table, y)
  labels = classify(model, data)
  ys = data[y]
  sum(ys .== labels) / length(labels)
end

splitrange(n, p = 0.7) = 1:round(Int, n*p), round(Int, n*p)+1:n

function class_act(model, data, y)
  trainrange, testrange = splitrange(length(data))
  traind, testd = data[trainrange], data[testrange]
  model = train(model, traind, y)
  accuracy(model, testd, y)
end

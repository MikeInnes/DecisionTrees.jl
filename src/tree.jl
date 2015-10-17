immutable DecisionTree
  tree::Nullable{Branch}
end

DecisionTree() = DecisionTree(nothing)

train(d::DecisionTree, data::Table, y) = with(d, f"tree" => tree(data, y))

classify(d::DecisionTree, data::Table, row) =
  classify(get(d.tree), data, row)

classify(model, data::Table) =
  map(row -> classify(model, data, row), 1:length(data))

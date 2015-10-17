immutable DecisionTree
  tree::Nullable{Branch}
end

DecisionTree() = DecisionTree(nothing)

train(d::DecisionTree, data::Table, y) = with(d, f"tree" => tree(data, y))

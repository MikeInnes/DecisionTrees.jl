export DecisionTree, train, classify

immutable DecisionTree
  tree::Nullable{Branch}
end

DecisionTree() = DecisionTree(nothing)

train(d::DecisionTree, data::Table, y) = with(d, f"tree" => tree(data, y))

function classify(tree::Branch, data::Table, row::Integer)
  isleaf(tree) && return tree.val
  next = isleft(data[tree.col, row], tree.val) ? left(tree) : right(tree)
  return classify(next, data, row)
end

classify(d::DecisionTree, data::Table, row) =
  classify(get(d.tree), data, row)

classify(model, data::Table) =
  map(row -> classify(model, data, row), 1:length(data))

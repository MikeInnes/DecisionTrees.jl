using DataFrames

data = DataSet(readtable("/Users/mike/Downloads/adult.csv"))

@time class_act(DecisionTree(), data, :Earnings)

@time class_act(Forest(DecisionTree()), data, :Earnings)

@time class_act(Forest(Forest(DecisionTree())), data, :Earnings)

using RDatasets

data = dataset("datasets", "iris")
data = DataSet(data)

splitrange(n, p = 0.7) = 1:round(Int, n*p), round(Int, n*p)+1:n

int(150*0.7)
int(150*(1-0.7))

function class_act(data, y)
  trainrange, testrange = splitrange(length(data))
  train, test = data[trainrange], data[testrange]
  t = tree(train, y)
  accuracy(test, y, t)
end

class_act(data, f"Species")

import random

# UDF 1: Read CSV file and display data as a 2D array
def readCSV(file_path):
    data = []
    with open(file_path, 'r') as file:
        for line in file:
            # Ignore lines starting with non-numeric characters
            if line[0].isdigit():
                row = list(map(int, line.strip().split(',')))
                data.append(row)
    return data

# UDF 2: Split data into training and test sets (80-20 split)
def test_train_data(data):
    total_rows = len(data)
    train_size = int(0.8 * total_rows)
    
    # Randomly shuffle the data
    random.shuffle(data)
    
    # Split into training and test sets
    train_data = data[:train_size]
    test_data = data[train_size:]
    
    return train_data, test_data

# UDF 3: Linear Regression - Compute weights
def linRegression(train_data):
    # Get the number of predictors
    num_predictors = len(train_data[0]) - 1

    # Initialize weights with zeros
    weights = [0] * (num_predictors + 1)
    
    # Extract features (predictors) and response variable from training data
    X = []
    Y = []
    for row in train_data:
        X.append([1] + row[1:])  # Add a 1 for the intercept term
        Y.append([row[0]])
    
    # Compute mean values for independent and dependent variables
    Xbar = [0] * (num_predictors + 1)
    for j in range(num_predictors + 1):
        total = 0
        for i in range(len(X)):
            total += X[i][j]
        Xbar[j] = total / len(X)

    
    total = 0
    for i in range(len(Y)):
        total += Y[i][0]
    Ybar = total / len(Y)
    
    print("\nAvg: ",Ybar,Xbar[1:])

    # Calculate the weights using the least squares method
    numerator = [0] * (num_predictors + 1)
    denominator = [0] * (num_predictors + 1)
    
    for i in range(len(X)):
        for j in range(num_predictors + 1):
            # For Numm
            Y_diff = train_data[i][0] - Ybar
            X_diff = train_data[i][j] - Xbar[j]
            product = X_diff * Y_diff
            numerator[j] += product
            #numerator[j] += (X[i][j] - Xbar[j]) * (Y[i][0] - Ybar)
            
            # For Dumm
            X_diff_squared = X_diff * X_diff
            denominator[j] += X_diff_squared
            # denominator[j] += (X[i][j] - Xbar[j]) ** 2

            # print(f'{i} {j+1} -> {Y_diff} = {train_data[i][0]} - {Ybar} || {X_diff} = {train_data[i][j]} - {Xbar[j]}')
            # print(f'{i} {j+1} -> {product} -> "{numerator[j]}" || {X_diff_squared} -> "{denominator[j]}"')
    
    print("Nummi:",numerator)
    print("Demmi:",denominator)

    for j in range(num_predictors + 1):
        if denominator[j] != 0:
            weights[j] = numerator[j] / denominator[j]
            print(f'{j} -> {weights[j]} = {numerator[j]} / {denominator[j]}')
        else:
            weights[j] = 0

    print('shh')
    # Calculate intercept (b0) separately
    weights[0] = Ybar
    for i in range(1, num_predictors + 1):
        weight = weights[i] * Xbar[i]
        weights[0] -= weight
        print(f'{i} -> {Ybar} -> {weights[0]} -= {weight} = {weights[i]} * {Xbar[i]}')
    
    return weights


# UDF 4: Test the Linear Regression model
def testModel(test_data, weights):
    # Extract features (predictors) and response variable from test data
    X_test = []
    Y_test_actual = []
    for row in test_data:
        X_test.append([1] + row[1:])  # Add a 1 for the intercept term
        Y_test_actual.append(row[0])
    
    # Predict the response variable using the computed weights
    Y_test_predicted = [0] * len(X_test)
    for j in range(len(X_test)):
        for i in range(len(weights)):
            value = weights[i] * X_test[j][i]
            Y_test_predicted[j] += value

            # print(f"{j} {i} -> {Y_test_predicted[j]} += {value} => {weights[i]} * {X_test[j][i]}")
    
    # Formula Display
    print(f"\nFormula:\nY = b0 + x1 * b1 + x2 * b2 . . . xn * bn\nY = {weights[0]}",end='')
    for i in range(1,len(weights)):
        print(f" + X{i} * {weights[i]}",end="")

    # Display actual vs predicted values
    print("\n\nTesting the Model:")
    for i in range(len(test_data)):
        print(f"Actual: {Y_test_actual[i]}, Predicted: {Y_test_predicted[i]}")



# OUTPUT Interface
if __name__ == "__main__":
    # Example usage
    file_path = "data/test.csv"
    
    # UDF 1: Read CSV file
    data = readCSV(file_path)
    print("Data from CSV file:")
    for row in data:
        print(row)
    
    # UDF 2: Split data into training and test sets
    train_data, test_data = test_train_data(data[1:])
    print("\nTraining Data:")
    for row in train_data:
        print(row)
    print("\nTest Data:")
    for row in test_data:
        print(row)
    
    # UDF 3: Linear Regression - Compute weights
    weights = linRegression(train_data)
    print("\nLinear Regression Weights:")
    print(weights)
    
    # UDF 4: Test the Linear Regression model
    testModel(test_data, weights)

    print("\n\nProject Complete - Goodbye!\n\n̿̿ ̿̿ ̿̿ ̿'̿'\̵͇̿̿\з= ( ▀ ͜͞ʖ▀) =ε▄︻̷̿┻̿═━一")
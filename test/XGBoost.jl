module TestXGBoost

using MLJBase
using Test
import MLJModels
import XGBoost
using CategoricalArrays
using MLJModels.XGBoost_


@test_logs (:warn,"\n objective function is not valid and has been changed to reg:linear") XGBoostRegressor(objective="wrong")
@test_logs (:warn,"\n objective function is not valid and has been changed to count:poisson") XGBoostCount(objective="wrong")
@test_logs (:warn,"\n objective function is more suited to :automatic") XGBoostClassifier(objective="wrong")

using Random: seed!
seed!(0)
plain_regressor = XGBoostRegressor()
n,m = 10^3, 5 ;
features = rand(n,m);
weights = rand(-1:1,m);
labels = features * weights;
features = MLJBase.table(features)
fitresultR, cacheR, reportR = MLJBase.fit(plain_regressor, 1, features, labels);
rpred = predict(plain_regressor, fitresultR, features);
@test fitresultR isa MLJBase.fitresult_type(plain_regressor)
info(XGBoostRegressor)


count_regressor = XGBoostCount()
using Random: seed!
using Distributions

seed!(0)

X = randn(100, 3) .* randn(3)'
Xtable = table(X)

α = 0.1
β = [-0.3, 0.2, -0.1]
λ = exp.(α .+ X * β)
y = [rand(Poisson(λᵢ)) for λᵢ ∈ λ]

fitresultC, cacheC, reportC = MLJBase.fit(count_regressor, 1, Xtable, y);
cpred = predict(count_regressor, fitresultC, Xtable);
@test fitresultC isa MLJBase.fitresult_type(count_regressor)
info(XGBoostCount)




plain_classifier = XGBoostClassifier()
task = load_iris();
X, y = X_and_y(task)
train, test = partition(eachindex(y), 0.6) # levels of y are split across split



fitresultCl, cacheCl, reportCl = MLJBase.fit(plain_classifier, 1,
                                            selectrows(X, train), y[train];)

println(fitresultCl)
clpred = predict(plain_classifier, fitresultCl, selectrows(X, test));
@test sort(levels(clpred[1])) == sort(levels(y[train]))

@test fitresultCl isa MLJBase.fitresult_type(plain_regressor)
info(XGBoostClassifier)

end
true

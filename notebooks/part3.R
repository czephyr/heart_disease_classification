library(pROC)
dfAugmented <- read.csv('agumented.csv', stringsAsFactors = T)

dfAugmented$HeartDisease = as.factor(dfAugmented$HeartDisease)

str(dfAugmented)

library(ranger)

set.seed(420)
split_full <- initial_split(dfAugmented, prop = 0.80,strata =HeartDisease)
train_full <- training(split_full)
test_full  <-  testing(split_full)

aucs = c()

for(i in 1:12){
  pred <- predict(model,data=test_full)
  
  pred <- predict(model,data=test_full)
  
  roc_obj <- roc(as.numeric(test_full$HeartDisease), as.numeric(pred$predictions))
  currentAUC <- auc(roc_obj)
  
  aucs <- append(aucs,currentAUC)
}

aucs

x <- c(1:12)
graph <- data.frame(x, aucs)

library(ggplot2)
ggplot(data=graph, aes(x=x, y=aucs, group=1)) +
  geom_line()+
  geom_point() +
  scale_x_continuous(breaks=seq(1:12))


model2 <- ranger(HeartDisease ~ .-BMI-PhysicalHealth-MentalHealth-SleepTime-nBadHabits-nCommorbs-AlcoholDrinking,data=train_full,mtry=2,importance="impurity",class.weights = c(8,92),num.trees=500)
model2$prediction.error

errors <- c()
treenums <- c(100,300,500,700,900)
for(i in treenums){
  model2 <- ranger(HeartDisease ~ .-BMI-PhysicalHealth-MentalHealth-SleepTime-nBadHabits-nCommorbs-AlcoholDrinking,data=train_full,mtry=2,importance="impurity",class.weights = c(8,92),num.trees=i)
  
  errors <- append(errors,model2$prediction.error)
}

errors

mtryerrors <- c()
mtrynums <- c(2:10)
for(i in mtrynums){
  model2 <- ranger(HeartDisease ~ .-BMI-PhysicalHealth-MentalHealth-SleepTime-nBadHabits-nCommorbs-AlcoholDrinking,data=train_full,mtry=i,importance="impurity",class.weights = c(8,92),num.trees=100)
  
  mtryerrors <- append(mtryerrors,model2$prediction.error)
}
mtryerrors

model2 <- ranger(HeartDisease ~ .-BMI-PhysicalHealth-MentalHealth-SleepTime-nBadHabits-nCommorbs-AlcoholDrinking,data=train_full,mtry=2,importance="impurity",class.weights = c(8,92),num.trees=100)
model2$confusion.matrix
pred <- predict(model2,data=test_full)
roc_obj <- roc(as.numeric(test_full$HeartDisease), as.numeric(pred$predictions))
currentAUC <- auc(roc_obj)
currentAUC

conf_matrix<-table(pred$predictions,test_full$HeartDisease)
conf_matrix



aucss <- c()
treenums <- c(100,300,500,700,900,1200)
for(i in treenums){
  model2 <- ranger(HeartDisease ~ .-BMI-PhysicalHealth-MentalHealth-SleepTime-nBadHabits-nCommorbs-AlcoholDrinking,data=train_full,mtry=2,importance="impurity",class.weights = c(8,92),num.trees=i)
  pred <- predict(model2,data=test_full)
  roc_obj <- roc(as.numeric(test_full$HeartDisease), as.numeric(pred$predictions))
  currentAUC <- auc(roc_obj)
  aucss <- append(aucss,currentAUC)
}
aucss

x <- c(1:12)
graph <- data.frame(treenums, aucss)

library(ggplot2)
ggplot(data=graph, aes(x=treenums, y=aucss, group=1)) +
  geom_line()+
  geom_point() +
  scale_x_continuous(breaks=c(100,300,500,700,900,1200))+
  ylim(0.25,1)

pred <- predict(model2,data=test_full)
conf_matrix<-table(pred$predictions,test_full$HeartDisease)
conf_matrix

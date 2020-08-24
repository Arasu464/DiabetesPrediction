# Dataset = DS

#Start section 1: Load Data & Clean/Inspect
#Import Dateset
diab <- read.csv("diabetes.csv", header=T, stringsAsFactors=F)

#Inspect Dataset
summary(diab)

#check any null data
is.na(diab)

#Rename Var
colnames(diab)[9] <- "diabetes"

#Reshape the Dataset Diabetes? => 0: NO/ 1:Yes
diab$diabetes <- as.factor(diab$diabetes)
levels(diab$diabetes) <- c("No","Yes")

#View Dataset (structure)
str(diab)

#View DS (Dimmension) Row/col
dim(diab)

#View DS (Head)
library(knitr)
kable(head(diab))

#End section 1
#Start section 2: Analyze correlation between variable
#Correlation Between each var
library(PerformanceAnalytics)
chart.Correlation(diab[,-9], histogram=TRUE, col="grey10", pch=1, main="Chart Correlation of Variance")

#Relation between each var (diabetes included)
#By ggpairs, the figure Pregnancies, Glucose, Age seems different according to diabetes outcome.
library(ggplot2)
library(GGally)
ggpairs(diab, aes(color=diabetes, alpha=0.75), lower=list(continuous="smooth"))+
  theme_bw()+
  
  labs(title="Correlation Plot of Variance(diabetes)")+
  
  theme(plot.title=element_text(face='bold',color='black',hjust=0.5,size=12))

#GGCORR Plot
#By ggcorr, we can see high correlation in below variance
#Pregnancies & Age : 0.5 => About 50% correlated to each other
#SkinThickness - &Insulin, &BMI : 0.4 => About 40% correlated to each other
ggcorr(diab[,-9], name = "corr", label = TRUE)+
theme(legend.position="none")+
labs(title="Correlation Plot of Variance")+
theme(plot.title=element_text(face='bold',color='black',hjust=0.5,size=12))

#END Section 2
#Start Section 3: ML Methods
#3.1 Make test & train dataset
# Shuffle the diab data(100%) & Make train dataset(70%), test dataset(30%)
nrows <- NROW(diab)
set.seed(218)                           # fix random value
index <- sample(1:nrows, 0.7 * nrows)   # shuffle and divide

# train <- diab                         # 768 test data (100%)
train <- diab[index,]                   # 537 test data (70%)
test <- diab[-index,]                   # 231 test data (30%)

#3.2 Check the proportion of diabetes(Benign/Malignat)
prop.table(table(train$diabetes)) #train ds
prop.table(table(test$diabetes))  #test ds

#3.3 Apple ML Algo Methods
# This library is for confusionMatrix
library(caret)
#SVM: Choose ‘gamma, cost’ which shows best predict performance in SVM
library(e1071)
gamma <- seq(0,0.1,0.005)
cost <- 2^(0:5)
parms <- expand.grid(cost=cost, gamma=gamma)    # 231
acc_test <- numeric()
accuracy1 <- NULL; accuracy2 <- NULL

for(i in 1:NROW(parms)){        
  
  learn_svm <- svm(diabetes~., data=train, gamma=parms$gamma[i], cost=parms$cost[i])
  pre_svm <- predict(learn_svm, test[,-9])
  accuracy1 <- confusionMatrix(pre_svm, test$diabetes)
  accuracy2[i] <- accuracy1$overall[1]
  
}

acc <- data.frame(p= seq(1,NROW(parms)), cnt = accuracy2)
opt_p <- subset(acc, cnt==max(cnt))[1,]
sub <- paste("Optimal number of parameter is", opt_p$p, "(accuracy :", opt_p$cnt,") in SVM")

library(highcharter)
hchart(acc, 'line', hcaes(p, cnt)) %>%
hc_title(text = "Accuracy With Varying Parameters (SVM)") %>%
hc_subtitle(text = sub) %>%
hc_add_theme(hc_theme_google()) %>%
hc_xAxis(title = list(text = "Number of Parameters")) %>%
hc_yAxis(title = list(text = "Accuracy"))

#SVM:Show best gamma and cost values
print(paste("Best Cost :",parms$cost[opt_p$p],", Best Gamma:",parms$gamma[opt_p$cnt]))

#SVM: Apply optimal parameters(gamma, cost) to show best predict performance in SVM
learn_imp_svm <- svm(diabetes~., data=train, cost=parms$cost[opt_p$p], gamma=parms$gamma[opt_p$p])
pre_train_imp_svm <- predict(learn_imp_svm, train[,-9]) #train
cm_train_imp_svm <- confusionMatrix(pre_train_imp_svm, train$diabetes) #train
cm_train_imp_svm
pre_imp_svm <- predict(learn_imp_svm, test[,-9])
cm_imp_svm <- confusionMatrix(pre_imp_svm, test$diabetes)
cm_imp_svm

#C5.0 Method
# This library is for confusionMatrix
library(caret)
#Choose ‘trials’ which shows best predict performance in C5.0
library(C50)
acc_test <- numeric()
accuracy1 <- NULL; accuracy2 <- NULL

for(i in 1:50){
  
  learn_imp_c50 <- C5.0(train[,-9],train$diabetes,trials = i)      
  p_c50 <- predict(learn_imp_c50, test[,-9]) 
  accuracy1 <- confusionMatrix(p_c50, test$diabetes)
  accuracy2[i] <- accuracy1$overall[1]
  
}

acc <- data.frame(t= seq(1,50), cnt = accuracy2)
opt_t <- subset(acc, cnt==max(cnt))[1,]
sub <- paste("Optimal number of trials is", opt_t$t, "(accuracy :", opt_t$cnt,") in C5.0")


library(highcharter)
hchart(acc, 'line', hcaes(t, cnt)) %>%
hc_title(text = "Accuracy With Varying Trials (C5.0)") %>%
hc_subtitle(text = sub) %>%
hc_add_theme(hc_theme_google()) %>%
hc_xAxis(title = list(text = "Number of Trials")) %>%
hc_yAxis(title = list(text = "Accuracy"))

#Apply optimal trials to show best predict performance in C5.0
learn_imp_c50 <- C5.0(train[,-9],train$diabetes,trials=opt_t$t) 
preTrain_imp_c50 <- predict(learn_imp_c50, train[,-9])#train data
cmTrain_imp_c50 <- confusionMatrix(preTrain_imp_c50, train$diabetes)#train Data
cmTrain_imp_c50# train Data confusion matrix
pre_imp_c50 <- predict(learn_imp_c50, test[,-9])
cm_imp_c50 <- confusionMatrix(pre_imp_c50, test$diabetes)
cm_imp_c50
#Summary/Compare both ML
col <- c("#ed3b3b", "#0099ff")
par(mfrow=c(1,2))
fourfoldplot(cm_imp_svm$table, color = col, conf.level = 0, margin = 1, main=paste("Tune SVM (",round(cm_imp_svm$overall[1]*100),"%)",sep=""))
fourfoldplot(cm_imp_c50$table, color = col, conf.level = 0, margin = 1, main=paste("Tune C5.0 (",round(cm_imp_c50$overall[1]*100),"%)",sep=""))
#Select the best prediction model according to higher accuracy.
opt_predict <- c(cm_imp_c50$overall[1], cm_imp_svm$overall[1])

names(opt_predict) <- c("tune_c50","tune_svm")

best_predict_model <- subset(opt_predict, opt_predict==max(opt_predict))

best_predict_model

#End Section 3

#Start Section 4: Test Dataset Prediction
#4.1 Predict 1 patient data's Diabetes
#4.1.1 Prepare Patient data for testing function
#4.1.1.1 Picked one row for testing. since is common to diagnosis only one patient at once.
Y <- test[1,]                   ## 5th patient

kable(Y)                        ## Diabetes: Yes
N <- test[2,]                   ## 18th patient          

kable(N)                        ## Diabetes: No
#4.1.1.2 Since done with testing/ shall remove the diabetes column for testing.
Y$diabetes <- NULL

N$diabetes <- NULL
#4.1.2 Patient Diabetes Fucntion
#4.1.2.1 Create a function
patient_diabetes_predict <- function(new, method=learn_imp_svm) {
  
  new_pre <- predict(method, new)
  
  new_res <- as.character(new_pre)
  
  return(paste("Result: ", new_res, sep=""))
  
}
#4.1.2.2 Testing the function
#Use ‘Tuned SVM Algorithm’ as default, Since it’s rated as the best predict_model.
#But not always best_predict_model is good. I think in real situation, it’s more important to reduce the (diabetes: Yes -> Predict: No) faulty prediction.
#With default Model: SVM
patient_diabetes_predict(Y) 
patient_diabetes_predict(N) 
#With C5.0
patient_diabetes_predict(Y,learn_imp_c50)
patient_diabetes_predict(N,learn_imp_c50)

#4.2 Predict Test dataset’s Diabetes
#using Tuned C5.0 Model
sub <- data.frame(orgin_result = test$diabetes, predict_result = pre_imp_c50, correct = ifelse(test$diabetes == pre_imp_c50, "True", "False"))

kable(head(sub,10))
prop.table(table(sub$correct))
#End Section 4

#Start Section 5
#Visualize (Probabilty Density Function Graph)
# plot for doctors who diagnosis diabetes for patients.
#From the patient’s point of view, I visualized the diabetes results in probability density graph with patients diagnosis strong line included, so that they can check their status at once.
#If patient’s factor of diabetes is above diabetes:yes factor average, I colored it with red line.
#5.1 Create Vis Function
diabetes_summary <- function(new,data) {
  
  
  
  ## [a] Reshape the new dataset for ggplot
  
  library(reshape2)
  
  m_train <- melt(data, id="diabetes")
  
  m_new <- melt(new)
  
  ## [b] Save mean of Malignant value
  
  library(dplyr)
  
  mal_mean <- subset(data, diabetes=="Yes", select=-9)
  
  mal_mean <- apply(mal_mean,2,mean)
  
  ## [c] highlight with red colors line
  
  library(stringr)
  
  mal_col <- ifelse((round(m_new$value,3) > mal_mean), "red", "black")
  

  ## [d] Save titles : Main title, Patient Diagnosis
  
  title <- paste("Diabetes Diagnosis Plot (", patient_diabetes_predict(new),")",sep="")
  
  ## ★[f] View plots highlighting values above average of malignant patient
  
  res_mean <- ggplot(m_train, aes(x=value,color=diabetes, fill=diabetes))+
    
    geom_histogram(aes(y=..density..), alpha=0.5, position="identity", bins=50)+
    
    geom_density(alpha=.2)+
    
    scale_color_manual(values=c("#15c3c9","#f87b72"))+
    
    scale_fill_manual(values=c("#61d4d6","#f5a7a1"))+
    
    geom_vline(data=m_new, aes(xintercept=value), 
               
               color=mal_col, size=1.5)+
    
    geom_label(data=m_new, aes(x=Inf, y=Inf, label=round(value,3)), nudge_y=2,  
               
               vjust = "top", hjust = "right", fill="white", color="black")+
    
    labs(title=title)+
    
    theme(plot.title = element_text(face='bold', colour='black', hjust=0.5, size=15))+
    
    theme(plot.subtitle=element_text(lineheight=0.8, hjust=0.5, size=12))+
    
    labs(caption="[Training 537 Pima Indians Diabetes Data]")+
    
    facet_wrap(~variable, scales="free", ncol=4)
  
  ## [g] output graph
  res_mean

}
#5.2 Test the created fucntion above
diabetes_summary(Y, diab) #Diabetes
diabetes_summary(N, diab) #Normal

#Extra
#plot c5.0 Tree
plot(learn_imp_c50, type="s")




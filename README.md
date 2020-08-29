### Diabetes Prediction Project


### Introduction:

The goal of this project is to predict the diabetes for PIIMA Women Indians by using attributes like Insulin, Blood Pressure, Pregnancy, Skin Thickness, Age etc., Target variable(Output) is considered as “0” and “1” as  yes and no respectively.
    
One dataset in csv format is considered for this project to train and test the models. The dataset contains 9 variables which 768 observations. The dataset is segregated into 70% and 30% for training and testing. 

The tool used is R along with its libraires and packages such as dplyr,e1071,c50,ggplot2 and Performance Analytics for data wrangling, data cleaning, data visualization, building predictive model and finding the correlation between the attributes.

### Data Cleaning:

The data was checked for missing and duplicate values. The dataset was cleaned with no missing and unidentified values.

### Exploratory data analysis(EDA):

Numerical and categorical variables were identified and summarised to get an overview of the dataset. In this case, 8 numerical variables and one categorical variables are considered. Numerical variables are Pregnancies, Glucose, Blood Pressure, Skin Thickness, Insulin, BMI, Diabetes Pedigree Function and Age. 

Output attribute is the categorical variable. Here, Output is renamed as  “diabetes” for better understanding.

### Relationship between variables

The below figure depicts explains the correlation value of each and every attributes in the dataset when compared to the target variable. This shows that every attributes has its own dependency with the target variable. Age, glucose and pregnancies are different according to the target variable outcome.

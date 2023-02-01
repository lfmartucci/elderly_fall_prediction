
# Elderly fall risk prediction
LF Martucci

date: 2023-01-31



## Introduction

This project aims to predict if an elderly has fallen in the past six months by using information about his gait pattern.

The data used in this project is from the work of Noh, B., Youm, C., Goh, E., et al. (2021), published in Nature Scientific Reports. The dataset contains 746 observations, and the target variable "History of Falls" is highly unbalanced. Therefore we will need to optimize our models to deal with this challenge.



![](Main_files/figure-html/unnamed-chunk-1-1.png)<!-- -->

## Preparing our data
Before training any model, we need to check for outliers and skews in data. Otherwise, those outliers can influence our model and scaling parameters. Even so, in this first version, we will train our first model on raw data to highlight how each step improves our model. As a first model, we will use logistic regression with lasso, ridge, and elastic net regularization.

To train and later evaluate our model, we will split the data into two sets: training and testing. The training set will contain 80% of the data, and the remaining 20% will be used as a testing set


```r
(\(data){
  set.seed(44)
  index_trainData <- caret::createDataPartition(data$History_of_fall,
                                                times=1,
                                                p=.8,
                                                list=FALSE)

  train_data <<- data[index_trainData,] 
  test_data <<- data[-index_trainData,]
})(df_full)
```

Next, with the data split, we will scale our values using the min-max approach. We will store the min-max values of training data and use them to normalize the testing data, avoiding data leakage at this step.


```r
scale_parameters <- (\(df){

  
  
 vars_max <- df %>% summarise(across(where(is.numeric), max))
 vars_min <- df %>% summarise(across(where(is.numeric), min))


 scale_params <- rbind(vars_max, vars_min) %>% as.data.frame()

 rownames(scale_params) <- c("max", "min")

 return(scale_params)
  
})(train_data)


train_scl <- train_data %>% 
  mutate(across(where(is.numeric), scale_min_max))


test_scl <- map2(test_data %>% select(where(is.numeric)),
                 scale_parameters, 
                 function(x, y) (x - y[2]) / (y[1] - y[2])
                 ) %>%
  as.data.frame() %>% 
  cbind(test_data %>% select(- where(is.numeric)))
```

## Machine learning algorithms

Now, we are ready to train our first model! We will do it using 5-fold cross-validation and searching for the best alpha and lambda parameters at the 0-1 range. 


```r
glm_model <- (\(data){

  
  train_control <- trainControl(method          = "repeatedcv", 
                                number          = 5,
                                repeats         = 3,
                                savePredictions = "final",
                                classProbs      = TRUE,
                                summaryFunction = twoClassSummary,
                                allowParallel   = FALSE,
                                sampling        = "smote")

  set.seed(44)  
  model <- caret::train(History_of_fall ~ .,
               data      = data,
               trControl = train_control,
               method    = "glmnet",
               family    = "binomial",
               metric    = "ROC",
               tuneGrid  = expand.grid(
                  .lambda= seq(0, 1, length.out = 6),
                  .alpha = seq(0, 1, length.out = 5))) # to get area under the ROC curve

  

  
  perf_eval <-  model$results$Youden %>% max()
  print(perf_eval)
  
  system("say terminei")
  
  return(model)
         
})(train_scl %>% select(-No_of_fall))
```

```
## [1] -Inf
```

```r
glm_model$results$ROC %>% max()
```

```
## [1] 0.5916373
```

```r
pROC::auc(train_scl$History_of_fall, predict(glm_model, train_scl, type= "prob")[,2])
```

```
## Area under the curve: 0.6608
```

```r
pROC::auc(test_scl$History_of_fall, predict(glm_model, test_scl, type= "prob")[,2])
```

```
## Area under the curve: 0.5664
```

Our basic trained model averaged an auROC of **0.59** on cross-validation. While the auROC achieved on training data was **0.66** and on testing data **0.55**.




## References 
Noh, B., Youm, C., Goh, E., et al. XGBoost-based machine learning approach to predict the risk of fall in older adults using gait outcomes. Sci Rep 11, 12183 (2021). https://doi.org/10.1038/s41598-021-91797-w


Walk the walk: Does this elder has fallen?
================
Luiz Felipe Martucci
2023-01-31

## Introduction

Is it possible to know if an elderly has fallen in the past six months
using information about his gait? We will discover this using the data
from 746 elderly from Noh et al. (2021), published in Nature Scientific
Reports (2021). The dataset contains gait information at three speeds:
preferred, -20% slow, and 20% faster than the preferred speed.
Furthermore, the dataset has some general info like age, body mass index
(BMI), and physical activity levels of each elder.

Our target variable, History of Falls, is highly unbalanced. We will
predict it using data about the three speeds to give our models
information on how gait strategy changes with speed.

<img src="README_files/figure-gfm/data_balance-1.png" style="display: block; margin: auto;" />

## Data split

Before exploring our data, let’s split it into train and test sets to
avoid data leakage during our modeling. The split will stratify the data
by the target variable and allocate 80% for training and the remaining
(20%) for testing our models. Taking advantage of the moment, we will
also create 10-cross-validation folds with two repeats.

``` r
set.seed(44)
elder_split <- 
  elder_adj %>% 
  mutate(History_of_fall = factor(History_of_fall, levels = c("Yes", "No"))) %>% 
  initial_split(strata = History_of_fall, prop = .8)
elder_train <- training(elder_split)
elder_test <- testing(elder_split)

#cv folds
set.seed(46)
elder_folds <- vfold_cv(elder_train, v=10, repeats = 2)
```

## Looking at our data - EDA

Skimming through numeric variables about elderly general and preferred
gait info, we can see that physical activity, MMSE score, gait
asymmetry, and all variables of coefficient of variation (CV) are highly
skewed, and outliers can be the culprits. However, we will not need to
care about this now, as we will use models resilient to this.

<img src="elder_numeric_vars_table.png" width="100%" style="display: block; margin: auto;" />

Exploring further our data, we can make some interesting observations:

- Faster walker elderly with long strides have fallen in the past six
  months. This pattern has some overlap with high BMI values;
- High levels of physical activity protect from falls, as high values of
  physical activity do not superimpose the fall pattern.

<img src="README_files/figure-gfm/EDA-1.png" style="display: block; margin: auto;" />

## Feature engineering

To train our models, we need to prepare the data. As the data doesn’t
have missing values, we need only to hot-encode our categorical vars.
Additionally, we will remove all variables with zero variance and
downsample the no-fall observations.

## Models

Our first model will be the Amazonian Helldom Forest, a Random Forest,
trained with 10k small trees. We will try 20 combinations of the number
of random variables tried before splitting a node (mtry) and the minimum
samples necessary to split a node. We will race these models against
each other and compare their performance on cross-validation folds with
ANOVA. Models with significantly lower performance will be out of the
race.
<img src="README_files/figure-gfm/ranger-1.png" style="display: block; margin: auto;" />
As we can see in the race plot, five models survived until the last
round with similar performances. And how about the performance of the
best of these on the test set?

<div id="rf_perf" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#rf_perf .gt_table {
  display: table;
  border-collapse: collapse;
  margin-left: auto;
  margin-right: auto;
  color: #FFFFFF;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #0D1117;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #0D1117;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#rf_perf .gt_heading {
  background-color: #0D1117;
  text-align: left;
  border-bottom-color: #0D1117;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#rf_perf .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}

#rf_perf .gt_title {
  color: #FFFFFF;
  font-size: 125%;
  font-weight: bold;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #0D1117;
  border-bottom-width: 0;
}

#rf_perf .gt_subtitle {
  color: #FFFFFF;
  font-size: 85%;
  font-weight: initial;
  padding-top: 0;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #0D1117;
  border-top-width: 0;
}

#rf_perf .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#rf_perf .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#rf_perf .gt_col_heading {
  color: #FFFFFF;
  background-color: #0D1117;
  font-size: 100%;
  font-weight: bold;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#rf_perf .gt_column_spanner_outer {
  color: #FFFFFF;
  background-color: #0D1117;
  font-size: 100%;
  font-weight: bold;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#rf_perf .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#rf_perf .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#rf_perf .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#rf_perf .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #FFFFFF;
  background-color: #0D1117;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}

#rf_perf .gt_empty_group_heading {
  padding: 0.5px;
  color: #FFFFFF;
  background-color: #0D1117;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#rf_perf .gt_from_md > :first-child {
  margin-top: 0;
}

#rf_perf .gt_from_md > :last-child {
  margin-bottom: 0;
}

#rf_perf .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #0D1117;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#rf_perf .gt_stub {
  color: #FFFFFF;
  background-color: #0D1117;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}

#rf_perf .gt_stub_row_group {
  color: #FFFFFF;
  background-color: #0D1117;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}

#rf_perf .gt_row_group_first td {
  border-top-width: 2px;
}

#rf_perf .gt_summary_row {
  color: #FFFFFF;
  background-color: #0D1117;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#rf_perf .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#rf_perf .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#rf_perf .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#rf_perf .gt_grand_summary_row {
  color: #FFFFFF;
  background-color: #0D1117;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#rf_perf .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#rf_perf .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#rf_perf .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#rf_perf .gt_footnotes {
  color: #FFFFFF;
  background-color: #0D1117;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#rf_perf .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-left: 4px;
  padding-right: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#rf_perf .gt_sourcenotes {
  color: #FFFFFF;
  background-color: #0D1117;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#rf_perf .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#rf_perf .gt_left {
  text-align: left;
}

#rf_perf .gt_center {
  text-align: center;
}

#rf_perf .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#rf_perf .gt_font_normal {
  font-weight: normal;
}

#rf_perf .gt_font_bold {
  font-weight: bold;
}

#rf_perf .gt_font_italic {
  font-style: italic;
}

#rf_perf .gt_super {
  font-size: 65%;
}

#rf_perf .gt_footnote_marks {
  font-style: italic;
  font-weight: normal;
  font-size: 75%;
  vertical-align: 0.4em;
}

#rf_perf .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#rf_perf .gt_indent_1 {
  text-indent: 5px;
}

#rf_perf .gt_indent_2 {
  text-indent: 10px;
}

#rf_perf .gt_indent_3 {
  text-indent: 15px;
}

#rf_perf .gt_indent_4 {
  text-indent: 20px;
}

#rf_perf .gt_indent_5 {
  text-indent: 25px;
}

#rf_perf .gt_table {
  background-color: #0D1117;
  width: 100%;
}
</style>
<table class="gt_table">
  <thead class="gt_header">
    <tr>
      <td colspan="2" class="gt_heading gt_title gt_font_normal gt_bottom_border" style>Amazonian Helldom Forest</td>
    </tr>
    
  </thead>
  <thead class="gt_col_headings">
    <tr>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="Metric">Metric</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="Performance">Performance</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="Metric" class="gt_row gt_left">MCC</td>
<td headers="Performance" class="gt_row gt_center">0.20</td></tr>
    <tr><td headers="Metric" class="gt_row gt_left gt_striped">Accuracy</td>
<td headers="Performance" class="gt_row gt_center gt_striped">0.59</td></tr>
    <tr><td headers="Metric" class="gt_row gt_left">J-Index</td>
<td headers="Performance" class="gt_row gt_center">0.25</td></tr>
    <tr><td headers="Metric" class="gt_row gt_left gt_striped">Sensitivity</td>
<td headers="Performance" class="gt_row gt_center gt_striped">0.69</td></tr>
    <tr><td headers="Metric" class="gt_row gt_left">Specificity</td>
<td headers="Performance" class="gt_row gt_center">0.56</td></tr>
  </tbody>
  
  
</table>
</div>

The performance of our model was not stellar but still better than
random chance. The most important variables for our model predictions
were:

<img src="README_files/figure-gfm/rf_vip-1.png" style="display: block; margin: auto;" />

## Conclusions

Our present results show that we can not identify with superb
performance an elderly who has fallen based on their gait pattern at
different speeds. However, the most important variable for our model,
gait asymmetry at preferred velocity, highlights two things. First, more
variables linked to gait asymmetry could improve our model predictions.
Two, **an elderly who relies more on one leg can be more prone to fall
when this leg fails upon then.**

## References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-noh" class="csl-entry">

Noh, Byungjoo, Changhong Youm, Eunkyoung Goh, Myeounggon Lee, Hwayoung
Park, Hyojeong Jeon, and Oh Yoen Kim. 2021. “XGBoost Based Machine
Learning Approach to Predict the Risk of Fall in Older Adults Using Gait
Outcomes.” Journal Article. *Scientific Reports* 11 (1): 12183.
<https://doi.org/10.1038/s41598-021-91797-w>.

</div>

</div>

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
predict it using mainly information about preferred speed gait patterns.
However, we will also construct and use some variables to reflect
changes in gait strategy with speed.

<img src="README_files/figure-gfm/data_balance-1.png" style="display: block; margin: auto;" />

## Data split

Before exploring our data, we will split it into train and test sets to
avoid data leakage during our modeling. The split will stratify the data
by the target variable and allocate 80% for training and the remaining
(20%) for testing our models. Taking advantage of the moment, we will
also create 10-cross-validation folds with three repeats.

``` r
set.seed(44)
elder_split <- initial_split(elder_adj, strata = History_of_fall, prop = .8)
elder_train <- training(elder_split)
elder_test <- testing(elder_split)

#cv folds
set.seed(44)
elder_folds <- vfold_cv(elder_train, v=10, repeats = 3)
```

## Looking at our data - EDA

Skimming through numeric variables about elderly general and preferred
gait info, we can see that physical activity, MMSE score, gait
asymmetry, and all variables of coefficient of variation (CV) are highly
skewed, and outliers can be the culprits. Therefore, we will need to act
upon them.

<div id="vuofjgudmd" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>html {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
}

#vuofjgudmd .gt_table {
  display: table;
  border-collapse: collapse;
  margin-left: auto;
  margin-right: auto;
  color: #EEEEEE;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: rgba(255, 255, 255, 0);
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: rgba(255, 255, 255, 0);
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

#vuofjgudmd .gt_heading {
  background-color: rgba(255, 255, 255, 0);
  text-align: left;
  border-bottom-color: rgba(255, 255, 255, 0);
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#vuofjgudmd .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}

#vuofjgudmd .gt_title {
  color: #EEEEEE;
  font-size: 125%;
  font-weight: bold;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: rgba(255, 255, 255, 0);
  border-bottom-width: 0;
}

#vuofjgudmd .gt_subtitle {
  color: #EEEEEE;
  font-size: 85%;
  font-weight: initial;
  padding-top: 0;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: rgba(255, 255, 255, 0);
  border-top-width: 0;
}

#vuofjgudmd .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#vuofjgudmd .gt_col_headings {
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

#vuofjgudmd .gt_col_heading {
  color: #EEEEEE;
  background-color: rgba(255, 255, 255, 0);
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

#vuofjgudmd .gt_column_spanner_outer {
  color: #EEEEEE;
  background-color: rgba(255, 255, 255, 0);
  font-size: 100%;
  font-weight: bold;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#vuofjgudmd .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#vuofjgudmd .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#vuofjgudmd .gt_column_spanner {
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

#vuofjgudmd .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #EEEEEE;
  background-color: rgba(255, 255, 255, 0);
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

#vuofjgudmd .gt_empty_group_heading {
  padding: 0.5px;
  color: #EEEEEE;
  background-color: rgba(255, 255, 255, 0);
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

#vuofjgudmd .gt_from_md > :first-child {
  margin-top: 0;
}

#vuofjgudmd .gt_from_md > :last-child {
  margin-bottom: 0;
}

#vuofjgudmd .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: rgba(255, 255, 255, 0);
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#vuofjgudmd .gt_stub {
  color: #EEEEEE;
  background-color: rgba(255, 255, 255, 0);
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}

#vuofjgudmd .gt_stub_row_group {
  color: #EEEEEE;
  background-color: rgba(255, 255, 255, 0);
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

#vuofjgudmd .gt_row_group_first td {
  border-top-width: 2px;
}

#vuofjgudmd .gt_summary_row {
  color: #EEEEEE;
  background-color: rgba(255, 255, 255, 0);
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#vuofjgudmd .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#vuofjgudmd .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#vuofjgudmd .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#vuofjgudmd .gt_grand_summary_row {
  color: #EEEEEE;
  background-color: rgba(255, 255, 255, 0);
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#vuofjgudmd .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#vuofjgudmd .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#vuofjgudmd .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#vuofjgudmd .gt_footnotes {
  color: #EEEEEE;
  background-color: rgba(255, 255, 255, 0);
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

#vuofjgudmd .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-left: 4px;
  padding-right: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#vuofjgudmd .gt_sourcenotes {
  color: #EEEEEE;
  background-color: rgba(255, 255, 255, 0);
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

#vuofjgudmd .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#vuofjgudmd .gt_left {
  text-align: left;
}

#vuofjgudmd .gt_center {
  text-align: center;
}

#vuofjgudmd .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#vuofjgudmd .gt_font_normal {
  font-weight: normal;
}

#vuofjgudmd .gt_font_bold {
  font-weight: bold;
}

#vuofjgudmd .gt_font_italic {
  font-style: italic;
}

#vuofjgudmd .gt_super {
  font-size: 65%;
}

#vuofjgudmd .gt_footnote_marks {
  font-style: italic;
  font-weight: normal;
  font-size: 75%;
  vertical-align: 0.4em;
}

#vuofjgudmd .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#vuofjgudmd .gt_indent_1 {
  text-indent: 5px;
}

#vuofjgudmd .gt_indent_2 {
  text-indent: 10px;
}

#vuofjgudmd .gt_indent_3 {
  text-indent: 15px;
}

#vuofjgudmd .gt_indent_4 {
  text-indent: 20px;
}

#vuofjgudmd .gt_indent_5 {
  text-indent: 25px;
}
</style>
<table class="gt_table">
  <thead class="gt_header">
    <tr>
      <td colspan="10" class="gt_heading gt_title gt_font_normal gt_bottom_border" style>General and preferred gait description</td>
    </tr>
    
  </thead>
  <thead class="gt_col_headings">
    <tr>
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="Variable">Variable</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="Complete rate">Complete rate</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="Mean">Mean</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="Sd">Sd</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="P0">P0</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="P25">P25</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="P50">P50</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="P75">P75</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="P100">P100</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="Hist">Hist</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="Variable" class="gt_row gt_left">Age</td>
<td headers="Complete rate" class="gt_row gt_center">1</td>
<td headers="Mean" class="gt_row gt_center">73.01</td>
<td headers="Sd" class="gt_row gt_center">5.21</td>
<td headers="P0" class="gt_row gt_center">63.00</td>
<td headers="P25" class="gt_row gt_center">69.00</td>
<td headers="P50" class="gt_row gt_center">73.00</td>
<td headers="P75" class="gt_row gt_center">77.00</td>
<td headers="P100" class="gt_row gt_center">89.00</td>
<td headers="Hist" class="gt_row gt_center">▅▇▇▃▁</td></tr>
    <tr><td headers="Variable" class="gt_row gt_left gt_striped">BMI</td>
<td headers="Complete rate" class="gt_row gt_center gt_striped">1</td>
<td headers="Mean" class="gt_row gt_center gt_striped">24.71</td>
<td headers="Sd" class="gt_row gt_center gt_striped">2.90</td>
<td headers="P0" class="gt_row gt_center gt_striped">16.10</td>
<td headers="P25" class="gt_row gt_center gt_striped">22.72</td>
<td headers="P50" class="gt_row gt_center gt_striped">24.75</td>
<td headers="P75" class="gt_row gt_center gt_striped">26.40</td>
<td headers="P100" class="gt_row gt_center gt_striped">36.90</td>
<td headers="Hist" class="gt_row gt_center gt_striped">▁▇▇▁▁</td></tr>
    <tr><td headers="Variable" class="gt_row gt_left">Physical Activity</td>
<td headers="Complete rate" class="gt_row gt_center">1</td>
<td headers="Mean" class="gt_row gt_center">1874.34</td>
<td headers="Sd" class="gt_row gt_center">1789.15</td>
<td headers="P0" class="gt_row gt_center">0.00</td>
<td headers="P25" class="gt_row gt_center">693.00</td>
<td headers="P50" class="gt_row gt_center">1386.00</td>
<td headers="P75" class="gt_row gt_center">2706.75</td>
<td headers="P100" class="gt_row gt_center">17622.00</td>
<td headers="Hist" class="gt_row gt_center" style="color: #00589B;">▇▁▁▁▁</td></tr>
    <tr><td headers="Variable" class="gt_row gt_left gt_striped">MMSE score</td>
<td headers="Complete rate" class="gt_row gt_center gt_striped">1</td>
<td headers="Mean" class="gt_row gt_center gt_striped">26.47</td>
<td headers="Sd" class="gt_row gt_center gt_striped">2.94</td>
<td headers="P0" class="gt_row gt_center gt_striped">13.00</td>
<td headers="P25" class="gt_row gt_center gt_striped">25.00</td>
<td headers="P50" class="gt_row gt_center gt_striped">27.00</td>
<td headers="P75" class="gt_row gt_center gt_striped">29.00</td>
<td headers="P100" class="gt_row gt_center gt_striped">30.00</td>
<td headers="Hist" class="gt_row gt_center gt_striped" style="color: #00589B;">▁▁▂▃▇</td></tr>
    <tr><td headers="Variable" class="gt_row gt_left">Walking Speed</td>
<td headers="Complete rate" class="gt_row gt_center">1</td>
<td headers="Mean" class="gt_row gt_center">1.19</td>
<td headers="Sd" class="gt_row gt_center">0.21</td>
<td headers="P0" class="gt_row gt_center">0.56</td>
<td headers="P25" class="gt_row gt_center">1.06</td>
<td headers="P50" class="gt_row gt_center">1.19</td>
<td headers="P75" class="gt_row gt_center">1.33</td>
<td headers="P100" class="gt_row gt_center">2.00</td>
<td headers="Hist" class="gt_row gt_center">▁▅▇▂▁</td></tr>
    <tr><td headers="Variable" class="gt_row gt_left gt_striped">Stride Length</td>
<td headers="Complete rate" class="gt_row gt_center gt_striped">1</td>
<td headers="Mean" class="gt_row gt_center gt_striped">1.23</td>
<td headers="Sd" class="gt_row gt_center gt_striped">0.17</td>
<td headers="P0" class="gt_row gt_center gt_striped">0.65</td>
<td headers="P25" class="gt_row gt_center gt_striped">1.13</td>
<td headers="P50" class="gt_row gt_center gt_striped">1.24</td>
<td headers="P75" class="gt_row gt_center gt_striped">1.34</td>
<td headers="P100" class="gt_row gt_center gt_striped">1.81</td>
<td headers="Hist" class="gt_row gt_center gt_striped">▁▃▇▃▁</td></tr>
    <tr><td headers="Variable" class="gt_row gt_left">Stance Phase Pct</td>
<td headers="Complete rate" class="gt_row gt_center">1</td>
<td headers="Mean" class="gt_row gt_center">57.50</td>
<td headers="Sd" class="gt_row gt_center">1.73</td>
<td headers="P0" class="gt_row gt_center">52.17</td>
<td headers="P25" class="gt_row gt_center">56.35</td>
<td headers="P50" class="gt_row gt_center">57.42</td>
<td headers="P75" class="gt_row gt_center">58.55</td>
<td headers="P100" class="gt_row gt_center">66.10</td>
<td headers="Hist" class="gt_row gt_center">▁▇▆▁▁</td></tr>
    <tr><td headers="Variable" class="gt_row gt_left gt_striped">Cvstride Length Pct</td>
<td headers="Complete rate" class="gt_row gt_center gt_striped">1</td>
<td headers="Mean" class="gt_row gt_center gt_striped">2.05</td>
<td headers="Sd" class="gt_row gt_center gt_striped">1.09</td>
<td headers="P0" class="gt_row gt_center gt_striped">0.44</td>
<td headers="P25" class="gt_row gt_center gt_striped">1.37</td>
<td headers="P50" class="gt_row gt_center gt_striped">1.81</td>
<td headers="P75" class="gt_row gt_center gt_striped">2.40</td>
<td headers="P100" class="gt_row gt_center gt_striped">10.42</td>
<td headers="Hist" class="gt_row gt_center gt_striped" style="color: #00589B;">▇▂▁▁▁</td></tr>
    <tr><td headers="Variable" class="gt_row gt_left">Cv Stancephase Pct</td>
<td headers="Complete rate" class="gt_row gt_center">1</td>
<td headers="Mean" class="gt_row gt_center">3.00</td>
<td headers="Sd" class="gt_row gt_center">1.70</td>
<td headers="P0" class="gt_row gt_center">0.68</td>
<td headers="P25" class="gt_row gt_center">1.95</td>
<td headers="P50" class="gt_row gt_center">2.57</td>
<td headers="P75" class="gt_row gt_center">3.47</td>
<td headers="P100" class="gt_row gt_center">17.00</td>
<td headers="Hist" class="gt_row gt_center" style="color: #00589B;">▇▂▁▁▁</td></tr>
    <tr><td headers="Variable" class="gt_row gt_left gt_striped">Gait Asymmetry Pct</td>
<td headers="Complete rate" class="gt_row gt_center gt_striped">1</td>
<td headers="Mean" class="gt_row gt_center gt_striped">2.04</td>
<td headers="Sd" class="gt_row gt_center gt_striped">2.04</td>
<td headers="P0" class="gt_row gt_center gt_striped">0.00</td>
<td headers="P25" class="gt_row gt_center gt_striped">0.74</td>
<td headers="P50" class="gt_row gt_center gt_striped">1.66</td>
<td headers="P75" class="gt_row gt_center gt_striped">2.66</td>
<td headers="P100" class="gt_row gt_center gt_striped">23.69</td>
<td headers="Hist" class="gt_row gt_center gt_striped">▇▁▁▁▁</td></tr>
    <tr><td headers="Variable" class="gt_row gt_left">Cadence Beats</td>
<td headers="Complete rate" class="gt_row gt_center">1</td>
<td headers="Mean" class="gt_row gt_center">115.96</td>
<td headers="Sd" class="gt_row gt_center">10.26</td>
<td headers="P0" class="gt_row gt_center">85.00</td>
<td headers="P25" class="gt_row gt_center">110.00</td>
<td headers="P50" class="gt_row gt_center">116.00</td>
<td headers="P75" class="gt_row gt_center">123.00</td>
<td headers="P100" class="gt_row gt_center">156.00</td>
<td headers="Hist" class="gt_row gt_center">▁▆▇▂▁</td></tr>
    <tr><td headers="Variable" class="gt_row gt_left gt_striped">Stride Time</td>
<td headers="Complete rate" class="gt_row gt_center gt_striped">1</td>
<td headers="Mean" class="gt_row gt_center gt_striped">1.04</td>
<td headers="Sd" class="gt_row gt_center gt_striped">0.10</td>
<td headers="P0" class="gt_row gt_center gt_striped">0.77</td>
<td headers="P25" class="gt_row gt_center gt_striped">0.98</td>
<td headers="P50" class="gt_row gt_center gt_striped">1.03</td>
<td headers="P75" class="gt_row gt_center gt_striped">1.10</td>
<td headers="P100" class="gt_row gt_center gt_striped">1.42</td>
<td headers="Hist" class="gt_row gt_center gt_striped">▁▇▇▂▁</td></tr>
    <tr><td headers="Variable" class="gt_row gt_left">Cv Stride Time Pct</td>
<td headers="Complete rate" class="gt_row gt_center">1</td>
<td headers="Mean" class="gt_row gt_center">2.06</td>
<td headers="Sd" class="gt_row gt_center">1.09</td>
<td headers="P0" class="gt_row gt_center">0.44</td>
<td headers="P25" class="gt_row gt_center">1.37</td>
<td headers="P50" class="gt_row gt_center">1.81</td>
<td headers="P75" class="gt_row gt_center">2.40</td>
<td headers="P100" class="gt_row gt_center">10.42</td>
<td headers="Hist" class="gt_row gt_center" style="color: #00589B;">▇▂▁▁▁</td></tr>
    <tr><td headers="Variable" class="gt_row gt_left gt_striped">Height</td>
<td headers="Complete rate" class="gt_row gt_center gt_striped">1</td>
<td headers="Mean" class="gt_row gt_center gt_striped">157.38</td>
<td headers="Sd" class="gt_row gt_center gt_striped">8.13</td>
<td headers="P0" class="gt_row gt_center gt_striped">133.00</td>
<td headers="P25" class="gt_row gt_center gt_striped">151.25</td>
<td headers="P50" class="gt_row gt_center gt_striped">156.00</td>
<td headers="P75" class="gt_row gt_center gt_striped">163.00</td>
<td headers="P100" class="gt_row gt_center gt_striped">180.00</td>
<td headers="Hist" class="gt_row gt_center gt_striped">▁▅▇▃▁</td></tr>
    <tr><td headers="Variable" class="gt_row gt_left">Weight</td>
<td headers="Complete rate" class="gt_row gt_center">1</td>
<td headers="Mean" class="gt_row gt_center">61.27</td>
<td headers="Sd" class="gt_row gt_center">8.80</td>
<td headers="P0" class="gt_row gt_center">35.80</td>
<td headers="P25" class="gt_row gt_center">55.00</td>
<td headers="P50" class="gt_row gt_center">60.75</td>
<td headers="P75" class="gt_row gt_center">67.07</td>
<td headers="P100" class="gt_row gt_center">85.90</td>
<td headers="Hist" class="gt_row gt_center">▁▅▇▅▁</td></tr>
  </tbody>
  
  
</table>
</div>

Exploring further our data, we can make some observations:

- Faster walker elderly with long strides have fallen in the past six
  months. This pattern has some overlap with high BMI values;
- High levels of physical activity protect from falls, as high values of
  physical activity do not superimpose the fall pattern;
- At last, a moderate variation in cadence between fast and slow speeds
  is the strategy of an elderly who has fallen. Therefore, more
  conservative or riskier approaches do not identify who fell. Probably
  because those who take a more conservative approach are more careful,
  and the riskier ones are confident in their walking ability.

<img src="README_files/figure-gfm/EDA-1.png" style="display: block; margin: auto;" />

## Preparing our data - EDA

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

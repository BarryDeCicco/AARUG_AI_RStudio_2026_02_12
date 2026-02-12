# Dataset Explorer and Analysis App

A Shiny application for interactive exploration and analysis of R datasets.

## 📍 Location

This app is located at:
```
C:\Users\bdeci\OneDrive\Documents\RStudio Projects\AARUG_AI_RStudio_2026_02_12\dataset_explorer_app\
```

## 🚀 How to Run the App

### Method 1: From R Console
```r
shiny::runApp('dataset_explorer_app')
```

### Method 2: From RStudio (Recommended)
1. In RStudio, navigate to the **Files** pane
2. Open the `dataset_explorer_app` folder
3. Click on `app.R` to open it in the editor
4. Click the **"Run App"** button at the top of the editor

### Method 3: Direct File Path
```r
shiny::runApp('C:/Users/bdeci/OneDrive/Documents/RStudio Projects/AARUG_AI_RStudio_2026_02_12/dataset_explorer_app')
```

## 📊 Available Datasets

The app includes the following built-in R datasets:
- **airquality** - Daily air quality measurements (NYC, May-Sep 1973)
- **mtcars** - Motor car road tests
- **iris** - Iris flower measurements
- **faithful** - Old Faithful geyser eruptions
- **ChickWeight** - Chick weights over time
- **ToothGrowth** - Tooth growth in guinea pigs
- **PlantGrowth** - Plant growth results from experiment

## 🔍 App Features

### 1. Data Preview Tab
- View the first 10 rows of the selected dataset
- Summary statistics for all variables
- Quick overview of data structure

### 2. Missing Data Tab
- Table showing missing value counts and percentages
- Visualization of missing values by variable
- Identifies data quality issues

### 3. Distributions Tab
- Histograms for up to 6 numeric variables
- Visual distribution analysis
- Identify skewness and outliers

### 4. Relationships Tab
- Scatter plots showing relationships between variables
- Explore correlations visually
- Multiple relationship plots displayed simultaneously

### 5. Time Series Tab
- **Special feature for airquality dataset**: Interactive time series plots
- Choose which variable to plot over time
- Visualize temporal patterns and trends
- Available for datasets with date/time columns

## 🎯 Example Usage

### Exploring Air Quality Data
1. Launch the app using one of the methods above
2. Select **airquality** from the dropdown (default)
3. Navigate through tabs to see:
   - Missing data in Ozone and Solar.R variables
   - Distribution patterns showing summer ozone peaks
   - Strong relationship between Temperature and Ozone
   - Time series showing seasonal patterns

### Comparing Datasets
1. Switch between datasets using the sidebar dropdown
2. Observe how different datasets have different characteristics
3. Note which datasets have missing values
4. Compare distribution shapes across datasets

## 💡 Tips

- The app automatically adapts to the structure of each dataset
- For datasets without time series data, the Time Series tab will indicate this
- All visualizations are generated dynamically based on the selected dataset
- Use the sidebar to see quick dataset information (rows, columns, variable names)

## 🛠️ Requirements

The app requires the following R packages:
- `shiny`
- `tidyverse` (includes ggplot2, dplyr, tidyr, etc.)
- `patchwork`

If any packages are missing, install them with:
```r
install.packages(c("shiny", "tidyverse", "patchwork"))
```

## 📝 Notes

- The app runs locally on your computer
- Default URL: `http://127.0.0.1:6174` (or similar port)
- To stop the app, press **Esc** in the R console or close the browser window and stop the R process
- All analyses are performed in real-time as you switch between datasets

---

**Created:** February 11, 2026  
**Version:** 1.0

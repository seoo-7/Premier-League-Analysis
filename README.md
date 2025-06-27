# Premier League Analysis (2011/12 - 2021/22) ⚽🏆

This repository contains an analysis of Premier League data from the 2011/12 to 2021/22 seasons, focusing on match scores, transfers, and injuries.

## Table of Contents

- Introduction
- Data Sources
- Methodology
- Insights
- Accessing the Report

## Introduction

This project dives into a decade of Premier League data (2011/12 to 2021/22), analyzing match scores, transfers, and injuries to uncover trends in team performance, transfer market dynamics, and injury impacts on clubs and players. 📊🔍

## Data Sources

Data was gathered from:

- Transfer Market 🌐
- Football Goalco UK ⚽

## Methodology

### Data Warehouse Architecture

A three-layer data warehouse was built to manage the data:

1. **Staging Layer**: Raw data from sources was loaded here. 📥
2. **Transformation Layer**: Data underwent cleansing, standardization, normalization, and custom logic for missing values. 🔄
3. **Reporting Layer**: Processed data was structured for analysis and reporting. 📈

### Data Processing

Key transformation steps included:

- **Data Cleansing**: Removed inconsistencies and errors. 🧹
- **Standardization**: Ensured uniform data formats. 📏
- **Normalization**: Reduced data redundancy. 🗂️
- **Missing Value Handling**: Applied custom logic to address gaps. 🛠️

## Insights

🌟 The analysis is presented in an interactive report with three pages, each highlighting unique aspects of the data.

### League Analysis

This page explores team performance with insights like:

- Club rankings 🏅
- Percentage statistics for wins, losses, and draws 📊
- Home vs. away points balance 🏟️
- Overall points earned by clubs per month in each season 📅
- Total red cards received 🟥
- Total losses and draws ⚖️
- Additional metrics

Filters (slicers) allow exploration by club and season. 🔎

### Transfers Analysis

This section dives into transfer market trends, including:

- Most common age for player signings 👶
- Annual transfer market costs 💰
- Transfers by player position 🧑‍🤝‍🧑
- Player sales revenue by club 💸
- Total signing costs by club 🏧

These insights reveal financial and strategic transfer patterns.

### Injuries Analysis

This page examines injury impacts, featuring:

- Cumulative days injured and games missed per club ⏳
- Total injuries per season 📉
- Proportion of injury severities 😷
- Injury duration and match absences per player 🏥
- Overall injuries per month 🗓️
- Most frequent injuries by season 🤕

These findings highlight injury trends and their effects on performance.

## Accessing the Report
The interactive report is included in this repository as [`Premier League Analysis.pbix`](https://github.com/seoo-7/Premier-League-Analysis/blob/master/Dashboard/Premier%20League%20Analysis.pbix) Open it with compatible software (e.g., Power BI, Tableau) to explore the insights and visualizations. 📊✨


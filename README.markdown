# Premier League Analysis (2011/12 - 2021/22)

This repository contains an analysis of Premier League data from the 2011/12 to 2021/22 seasons, focusing on match scores, transfers, and injuries.

## Table of Contents

- [Introduction](#introduction)
- [Data Sources](#data-sources)
- [Methodology](#methodology)
- [Insights](#insights)
- [Accessing the Report](#accessing-the-report)
## Introduction

This project explores Premier League data over a decade, from the 2011/12 to 2021/22 seasons. It analyzes three key areas: match scores, transfers, and injuries, aiming to reveal trends in team performance, transfer market dynamics, and the impact of injuries on clubs and players.

## Data Sources

Data was collected from the following sources:

- [Transfer Market](https://www.transfermarkt.com)
- [Football Goalco UK](https://www.footballgoalco.co.uk)

## Methodology

### Data Warehouse Architecture

A three-layer data warehouse was built to manage the data:

1. **Staging Layer**: Raw data from the sources was loaded here.
2. **Transformation Layer**: Data was processed through cleansing, standardization, normalization, and custom logic for missing values.
3. **Reporting Layer**: Processed data was structured for analysis and reporting.

### Data Processing

Key transformation steps included:

- **Data Cleansing**: Eliminated inconsistencies and errors.
- **Standardization**: Ensured uniform data formats.
- **Normalization**: Reduced data redundancy.
- **Missing Value Handling**: Applied custom logic to address gaps.

## Insights

The analysis is delivered through an interactive report with three pages, each highlighting a different aspect of the data.

### League Analysis

This page examines team performance with insights such as:

- Club rankings
- Percentage statistics for wins, losses, and draws
- Home vs. away points balance
- Overall points earned by clubs per month in each season
- Total red cards received
- Total losses and draws
- Additional metrics

### Transfers Analysis

This section focuses on transfer market trends, including:

- Most common age for player signings
- Annual transfer market costs
- Transfers by player position
- Player sales revenue by club
- Total signing costs by club

These insights illuminate financial and strategic transfer patterns.

### Injuries Analysis

This page assesses injury impacts, featuring:

- Cumulative days injured and games missed per club
- Total injuries per season
- Proportion of injury severities
- Injury duration and match absences per player
- Overall injuries per month
- Most frequent injuries per season

These findings highlight injury trends and their effects on performance.

## Accessing the Report

The interactive report is included in this repository as `[Dashboard]`. Open it with compatible software (e.g., Power BI, Tableau) to explore the insights and visualizations.
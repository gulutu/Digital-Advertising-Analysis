# Digital Advertising Performance Analytics  
**End-to-end SQL → Python → Tableau pipeline for campaign intelligence, audience insights and funnel optimization.**

> **Status:** Actively developed – currently working on audience & segment insights in Python.

<p align="center">
  <img width="750" alt="image" src="https://github.com/user-attachments/assets/6f9bdde0-9beb-4a35-94e3-5807a8f89a26" />
</p>


---

## Project Overview

This project builds a complete analytics workflow for a fictional digital advertising agency running campaigns on Facebook and Instagram.  
The goal is to understand campaign performance, audience behavior, funnel dynamics and opportunities for commercial optimization.

Key questions investigated include:
- Which campaigns perform well - and why?  
- Which audiences respond best?  
- Which platforms, formats and creatives drive results?  
- Where does users drop off in the funnel?  
- How should budgets be reallocated to improve ROI?  
<p align="center">
<img width="750"  alt="image" src="https://github.com/user-attachments/assets/08df89f6-099d-4bec-bc96-4b2a5b046276" />
</p>

To answer these questions, the project integrates an SQL → Python → Tableau workflow:

<p align="center">
<img width="750" alt="image" src="https://github.com/user-attachments/assets/2a5cabd0-60e0-4075-bf73-359165d5fcd9" />
</p>  

---

## Core Metrics & KPIs

### Funnel Metrics
- **Impressions** – how often ads were shown
- **Clicks** – engagement events
- **Purchases** – final conversion

### Rate KPIs
- **CTR** (click-through rate) - Measures attention and engagement quality  
- **CVR (view-based)** - Overall conversion effectiveness  
- **CVR (click-based)** - Post-click quality: landing page relevance & high-intent behavior  

### Cost KPIs
- **CPM** – cost per 1000 impressions  
- **CPC** – cost per click  
- **CPA** – cost per purchase  

These KPIs form the analytical foundation for understanding campaign value and optimization opportunities.


---

## Data Model
*Dataset source: [Social Media Advertisement Performance (Kaggle)](https://www.kaggle.com/datasets/alperenmyung/social-media-advertisement-performance/data)*

The dataset is fully synthetic and designed to mirror real digital advertising systems.  
It consists of four linked tables that together represent users, campaigns, creatives and full-funnel behavioral data.

### Raw Tables
- **Audience Profiles** (`users.csv`) — Demographics, location and interest categories  
- **Campaign Metadata** (`campaigns.csv`) — budgets, timelines and campaign types  
- **Creative & Placement** (`ads.csv`) — format (video/image/carousel), platform and targeting settings  
- **Behaviorals** (`ad_events.csv`) — Impressions, clicks and purchases with timestamps  


### Row Counts

| Table      | Rows    |
|------------|---------|
| users      | 10,000  |
| campaigns  | 50      |
| ads        | 200     |
| ad_events  | 400,000 |

### Raw Table Schema Overview 

| Table       | Key Columns | Description |
|-------------|-------------|-------------|
| **users** | `user_id`, `user_gender`, `user_age`, `age_group`, `country`, `interests` | Demographics and interests used for audience segmentation. |
| **campaigns** | `campaign_id`, `name`, `start_date`, `end_date`, `total_budget` | Campaign metadata and budget context. |
| **ads** | `ad_id`, `campaign_id`, `ad_platform`, `ad_type`, `target_gender`, `target_age_group`, `target_interests` | Creative details and targeting configuration. |
| **ad_events** | `event_id`, `ad_id`, `user_id`, `timestamp`, `event_type` | Full behavioral funnel: impressions, clicks and purchases. |


---

## Project Pipeline Overview  
Click to expand each layer.


<details>
  <summary><strong>SQL Layer — Data Modeling & KPI Engineering</strong></summary>
  <br>

The SQL layer establishes the analytical foundation.

**Includes:**
- Data cleaning and validation  
- Joins across users × ads × campaigns × events  
- Fact/dimension style structures  
- Materialized tables (`*_tbl`) for performance  
- KPI engineering (CTR, CVR, CPM, CPC, CPA)  
- Funnel and timestamp consistency checks  

SQL-script ➡️ <a href="./marketing_analysis_script.sql">marketing_analysis_script.sql</a>
</details>


<details>
  <summary><strong>Python Layer — EDA, Insights & Modeling (ongoing)</strong></summary>
  <br>

### Completed
- Campaign-level overview  
- KPI distribution analysis  
- Outlier detection  
- Mapping performance heterogeneity across campaigns  

### In Progress
- Audience insights & segmentation  
- CTR/CVR by gender, age, country, interests  
- Segment-level cost efficiency  
- Funnel drop-off analysis  

### Planned
- Time-based performance patterns  
- User × campaign modeling    
</details>

<details>
  <summary><strong>Tableau Layer — Dashboards (upcoming)</strong></summary>
  <br>

Planned dashboards:
- Campaign Performance Overview  
- Audience & Segment Insights  
- Funnel Drop-Off Explorer  
- Cost & ROI Dashboard  
- Time-based Trends  
</details>

---

## Completed Work

### **Data Engineering & Validation**
- Cleaning and profiling of all raw sources  
- Construction of analytic SQL views and materialized tables  
- Demographic and KPI-range validation  

### **Campaign Performance Analysis**
- Distribution of budgets and funnel volumes  
- Log-scale outlier detection  
- KPI variability analysis (rate + cost KPIs)  
- Identification of high-/low-performing campaigns  

---

## Current Focus: Audience Insights & Segments

Using `segment_performance_kpis_tbl` and enriched event data, the analysis now focuses on:

- Demographic response patterns  
- CTR/CVR differences across audience groups  
- Cost efficiency per segment  
- Identifying high-intent vs low-intent users  
- Segment-level optimization opportunities  


---



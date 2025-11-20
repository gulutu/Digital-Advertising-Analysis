# Digital Advertising Performance Analytics  
**End-to-end SQL → Python → Tableau pipeline for campaign intelligence, audience insights and funnel optimization.**

> **Status:** Actively developed – currently working on audience & segment insights (Python).

<img width="912" height="516" alt="image" src="https://github.com/user-attachments/assets/6f9bdde0-9beb-4a35-94e3-5807a8f89a26" />

---

## 🔎 Project Overview

This project simulates a complete analytics environment for a fictitious digital advertising agency running paid campaigns on Facebook and Instagram.  
The agency invests significant budgets but lacks the analytical infrastructure needed to answer key questions:

<img width="912" height="615" alt="image" src="https://github.com/user-attachments/assets/08df89f6-099d-4bec-bc96-4b2a5b046276" />

- Which campaigns actually perform – and why?  
- Which audiences respond best?  
- Which formats, platforms and creatives deliver the strongest results?  
- Where in the funnel do users drop off?  
- How should budgets be reallocated to maximize ROI?  

To solve this, the project builds a **analytics workflow** combining:

<img width="912" height="516" alt="image" src="https://github.com/user-attachments/assets/2a5cabd0-60e0-4075-bf73-359165d5fcd9" />

---

## 📊 Core Metrics & KPIs

### Funnel Metrics
- **Impressions** – how often ads were shown  
- **Clicks** – engagement events  
- **Purchases** – final conversion  

### Rate KPIs
- **CTR** (click-through rate)  
  Measures attention and engagement quality  
- **CVR (view-based)**  
  Overall conversion effectiveness  
- **CVR (click-based)**  
  Post-click quality: landing page relevance & high-intent behavior  



### Cost KPIs
- **CPM** – cost per 1000 impressions  
- **CPC** – cost per click  
- **CPA** – cost per purchase (commercial efficiency)  



These KPIs form the analytical foundation for understanding campaign value and optimization opportunities.


---

## 🧱 Data Model
*Dataset source: [Social Media Advertisement Performance (Kaggle)](https://www.kaggle.com/datasets/alperenmyung/social-media-advertisement-performance/data)*

The dataset is fully synthetic and structured to mirror real digital advertising systems (e.g., Meta Ads Manager), consisting of four linked tables.

### `users.csv` — Audience Profiles  
Demographics, location and interest categories used for segmentation.

### `campaigns.csv` — Campaign Metadata  
Budgets, timelines, campaign types and strategic context.

### `ads.csv` — Creative & Placement  
Format (video/image/carousel), platform and targeting configuration.

### `ad_events.csv` — Behavioral Funnel  
Impressions, clicks and purchases with timestamps — core for funnel analysis.

---

## ⚙️ Project Pipeline Overview  
Click to expand each layer.

---

<details>
  <summary><strong>🧩 SQL Layer – Data Modeling & KPI Engineering</strong></summary>
  <br>

The SQL layer builds the analytical backbone of the project.  
Full pipeline:  
➡️ <a href="./marketing_analysis_script.sql">marketing_analysis_script.sql</a>

**Contains:**
- Data cleaning and sanity checks  
- Join logic between users, ads, campaigns and events  
- Fact and dimension structures  
- Materialized analytical tables (`*_tbl`) for performance  
- KPI engineering for funnel, cost and segment metrics  
- Funnel validation and timestamp standardization  

All Python and Tableau analysis relies on this validated, reproducible SQL layer.

</details>

---

<details>
  <summary><strong>🐍 Python Layer – EDA, Insights & Modeling ( **Ongoing Work** ) </strong></summary>
  <br>

The Python layer transforms SQL outputs into insights.

### Completed:
- Campaign overview (budget, volume, funnel exploration)  
- KPI distributions (CTR, CVR, CPC, CPM, CPA)  
- Outlier detection  
- High-budget campaign profiling  
- Establishing performance heterogeneity across campaigns  

### In progress:
- Audience insights & segmentation  
- KPI performance by age, gender, country and interest groups  
- Identifying high-intent segments  
- Funnel drop-off patterns across audiences  

### Planned:
- Trend analysis (time-based performance)  
- User × campaign modeling  
- Predictive modeling for purchase likelihood (optional)

</details>

---

<details>
  <summary><strong>📊 Tableau Layer – Dashboards & Storytelling</strong></summary>
  <br>

The Tableau layer will deliver stakeholder-ready dashboards.

### Planned dashboards:
- Campaign Performance Overview  
- Audience & Segment Insights  
- Funnel Breakdown & Drop-Off Explorer  
- Cost Efficiency & ROI Dashboard  
- Time-based Trends and Pacing  

These dashboards summarize the entire analytics pipeline in a format suitable for marketing, commercial and leadership teams.

</details>

---

## 📈 Completed Work

### **Data Engineering & Validation**
- Cleaning and profiling of all raw sources  
- Construction of analytic SQL views and materialized tables  
- Funnel logic verification (impressions ≥ clicks ≥ purchases)  
- Demographic consistency checks  
- KPI-range validation for CTR, CVR and cost metrics  

### **Campaign Performance Analysis**
- Distribution of budgets and funnel volumes  
- Log-scale outlier detection  
- KPI variability analysis (rate + cost KPIs)  
- Identification of high- and low-performing campaigns  

This phase establishes the overall performance landscape and prepares the ground for deeper audience-level insights.

---

## 👥 Current Focus: Audience Insights & Segments

Using `segment_performance_kpis_tbl` and enriched event data, the project now focuses on:

- How different demographics respond to campaigns  
- Which segments have strong or weak CTR/CVR  
- Cost efficiency across audience groups  
- Identifying high-intent vs low-intent audiences  
- Segment-level optimization opportunities  

This step connects campaign performance to audience behavior — crucial for targeting, budgeting and creative strategy.

---

## 🔮 Next Steps

### Upcoming analysis
- Deeper user-level insights (repeat engagement, multi-touch behavior)  
- User × campaign modeling  
- Temporal insights (daily performance, early/late campaign behavior)  

### Upcoming deliverables
- Full Tableau dashboards  
- Commercial recommendations & optimization scenarios  
- Optional predictive modeling for conversion drivers  

---

## 🎯 What does this project intent to demonstrate?

This project demonstrates how to:

- Build a scalable analytics pipeline from scratch  
- Transform raw event data into actionable insights  
- Combine SQL, Python and Tableau in one unified workflow  
- Evaluate campaign, funnel and audience performance with depth  
- Generate insights that support real commercial decision-making  


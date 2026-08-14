# Video Analysis Report: Think Like a Senior Data Analyst

**Video Title:** Think Like a Senior Data Analyst: Data to Insight in 15 Minutes  
**Creator:** Christine Jiang  
**Published:** August 12, 2026  
**URL:** [https://youtu.be/s8zpxuJ788o](https://youtu.be/s8zpxuJ788o)

---

## 1. Executive Summary
In this video, former Data Director and hiring manager Christine Jiang presents a structured, high-level framework that experienced data analysts use to turn ambiguous business questions and messy datasets into clear, actionable insights for stakeholders. The core problem addressed is a common insecurity among junior or transitioning analysts: knowing how to go "beyond the numbers" to explain the "so what" and avoid aimless data exploration.

## 2. The Core Problem
Many analysts fall into the trap of analyzing all metrics by all dimensions simultaneously when faced with open-ended stakeholder questions (e.g., "How is our new loyalty program performing?"). This results in overwhelmed spreadsheets or complex SQL queries that fail to answer the core business question. Jiang's methodology aims to fix this through a 4-step structured framework.

## 3. The 4-Step Analytical Framework

### Step 1: Identify Northstar Metrics and Dimensions
Before touching any data, an analyst must narrow the scope to prevent getting overwhelmed. 
*   **Rule of Thumb:** Identify roughly **three Northstar metrics** and **three dimensions**.
*   **Metrics:** The numbers that measure performance (e.g., Total Revenue, Average Order Value (AOV), Repeat Purchase Rate).
*   **Dimensions:** Qualitative categories used to slice the metrics and diagnose changes (e.g., Loyalty Program Status, Region, Purchase Date, Product Category). 
*   *Insight:* Domain knowledge is critical here to select the most impactful metrics for the specific industry.

### Step 2: Break Ambiguous Questions into Smaller Questions
Translate the primary business question into smaller queries that can be directly answered using technical tools (Excel, SQL, PowerBI). Jiang categorizes 80% of stakeholder questions into **Four Key Buckets**:
1.  **Overall Trends:** Evaluating seasonality, patterns, dimensional segmentation, and summary statistics (min/max/avg) of sales or other key metrics.
2.  **Growth Rates:** Treating growth rate as a metric itself, evaluating MoM or YoY changes, and analyzing distribution and seasonality of growth.
3.  **Performance Measurement:** Comparing metrics and trends between segments (e.g., Loyalty vs. Non-Loyalty members).
4.  **KPI Reporting:** Not just reporting the static number (e.g., "Refund Rate"), but breaking it down by dimensions to explain *why* it is at that level.

### Step 3: Investigate the "Why" using Technical Tools
Each of the "smaller questions" essentially boils down to looking at a **metric sliced by a dimension**, either as a snapshot in time or as a trend over time. 
*   *Example Application:* Using line charts to visualize AOV for loyalty vs. non-loyalty members over several years to see if the loyalty program actually drives higher cart sizes.

### Step 4: Surface Insights and Recommendations
This step "makes or breaks" the analysis. An analyst must effectively communicate the findings to the stakeholder in a business context.
*   **Weak Insight:** "Loyalty members have a higher AOV. The program is working." (Lacks depth, context, and actionable advice).
*   **Strong Insight:** "Loyalty members had a 34% higher AOV and repeat purchase rate nearly 3x last year, showing program value. However, the gap has shrunk recently, driven entirely by a slowdown in the US. We should sync with the US sales team to understand context."
*   **How to construct a strong insight:** Summarize trends, describe overall fluctuations, highlight anomalies/outliers, dig one dimension deeper to find the root cause, and calibrate the technical detail to your specific audience.

## 4. Pro-Tip: The Running Log
Jiang's top tip for preventing overwhelm when compiling the final report is to keep a **Running Log**. As you explore the data, continuously document:
1.  The big question.
2.  The smaller derived questions.
3.  The immediate findings.
4.  The root cause (going one layer deeper). 
This builds your final summary organically as you work.

---
*Analysis generated automatically based on the video transcript provided.*

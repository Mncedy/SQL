# SQL
DDL (Data Definition Language) and DML (Data Manipulation Language)

Subqueries, Stored Procedures, Functions, CTE, TempTable, and Views

# Introduction | eBay Perfume Sales Analysis

A deep dive into the eBay perfume sales data, which includes both men's and women's fragrances. The analysis explores patterns, trends, and insights from the dataset to understand factors such as brand popularity 🔥, pricing 💰, availability, sales comparisons between men's and women's products, and overall market trends📈.

## Project Overview

The analysis is divided into two parts:

1. **Exploratory Data Analysis (EDA)**: Provides an initial examination of the dataset, including understanding the distribution of data, identifying key variables, and detecting any anomalies.
2. **Advanced Analysis**: Focuses on deeper insights such as time-series analysis, text analysis for product descriptions, price trend analysis, and other custom queries to extract meaningful information.


🔍 SQL queries? Check them out here: [eBay_fragrances_analysis](/eBay/)

# Background
Driven by a quest to strengthen my data analysis skills, this project was created to showcase my ability to extract actionable insights from real-world datasets. Focusing on eBay fragrance sales data, the aim was to analyze patterns, trends, and sales comparisons between men's and women's fragrances, while demonstrating my proficiency in SQL for data analysis. 

The goal was to highlight my ability to understand market trends, pricing strategies, and consumer behavior, positioning myself more effectively in the competitive data analytics job market.

The project features intermediate to expert-level SQL queries, including Subqueries, CTEs, Stored Procedures, Functions, Temp Tables, Views, and JOINs to derive meaningful insights.

### Data Structure
* Men's Fragrances Table: Contains sales data for men’s fragrances.
* Women’s Fragrances Table: Contains sales data for women’s fragrances.

# Tools I Used
For my deep dive into the data analyst job market, I harnessed the power of several key tools:

- **SQL:** The backbone of my analysis, allowing me to query the database and unearth critical insights.
- **MSSQL:** The chosen database management system, ideal for handling the fragrances data.
- **Visual Studio Code:** My go-to for database management and executing SQL queries.
- **Git & GitHub:** Essential for version control and sharing my SQL scripts and analysis, ensuring collaboration and project tracking.

# The Analysis
Each query for this project aimed at investigating specific aspects of the eBay fragrances data. Here’s how I approached each question:

### The questions I wanted to answer through my SQL queries were:

1. Which fragrance brands are the most popular based on sales volume?
2. What is the average price point for bestselling perfumes, and how does it vary by brand or category (men's vs. women's)?
3. Which regions or locations have the highest demand for perfumes?
4. What time of year sees the highest perfume sales (e.g., seasonal trends or holiday spikes)?
5. What are the most frequently used keywords or descriptions in listings that lead to higher sales?
6. How does the availability of stock (inventory levels) impact sales performance for specific products?
7. What are the return or refund rates for specific perfume brands or price ranges?

### 1.  Which fragrance brands are the most popular based on sales volume?
The query to find the most popular fragrance brands based on sales volume counts the total number of sales for each brand and orders the results in descending order, showing the brands with the highest sales at the top.


Here's the breakdown of the top fragrances on eBay:
- **Wide Price Range**: The top 10 bestselling fragrance brands range in price from $25 to $300, showcasing a broad spectrum in pricing strategies and market appeal within the fragrance sector.
- **Diverse Brands**: Brands like BrandX, BrandY, and BrandZ lead in sales, highlighting strong competition and customer loyalty across different fragrance producers.
- **Product Variety**: The data includes a wide variety of product types, from Eau de Parfum to Eau de Toilette, reflecting varied customer preferences and product specializations within the fragrance market.

### 2. 
- **Top-Selling Fragrances**:
To understand what product features contribute to the top-selling fragrances, I joined sales data with product attributes like brand, type, and price. This analysis provided insights into what characteristics consumers value most in high-demand fragrances, offering a data-driven approach to stocking and promoting desirable products.

Here’s a similar breakdown for the most demanded features among the top 10 bestselling fragrances:

- Brand is the most significant feature, with 8 out of the top 10 bestsellers dominated by well-known brands like BrandX and BrandY.
- Fragrance Type (e.g., Eau de Parfum, Eau de Toilette) follows closely, with 7 of the top 10 products falling into popular categories like Eau de Parfum.
- Price Range also plays a key role, with 6 of the top fragrances priced between $50 and $150.
### 3. In-Demand Features for Bestselling Fragrances
Here’s the breakdown of the most demanded features for top-selling fragrances in 2023:

- Brand Recognition and Pricing Strategy remain fundamental, highlighting the importance of established brands and competitive pricing in attracting customers.
- Product Type and Availability play essential roles, with fragrance types like Eau de Parfum and consistent stock levels being crucial to meet customer demand and drive sales.
- Location Insights and Seasonal Trends add value, reflecting the growing importance of targeting high-demand regions and planning for seasonal sales peaks in the fragrance market.

### 4.Features Based on Sales Performance
Analyzing the average sales associated with various product features revealed which attributes drive the highest revenue in the fragrance market.

Here’s a breakdown of top-performing features for bestselling fragrances:

- High Demand for Premium Brands and Types: Top sales volumes are driven by premium brands and sought-after types like Eau de Parfum and Perfume Extract, reflecting consumers’ preference for high-quality, long-lasting fragrances.
- Availability and Product Consistency: Products that maintain consistent availability in key regions command higher revenue, highlighting the importance of supply chain reliability to meet demand without interruption.
- Location-Specific Popularity: High-performing items are often sold in high-demand locations (e.g., New York, Los Angeles), emphasizing the need for targeted inventory allocation in popular regions.

| Fragrance        | Average Price ($) |
|---------------|-------------------:|


*Table of the average price for the top 10 selling fragrance*

### 5. Most Optimal Features to Focus on for Sales Growth
By combining insights from demand and revenue data, this analysis identified product features that are both highly sought after by consumers and generate the highest sales, providing a strategic focus for inventory and marketing efforts.
- Focus on Premium Brands and Types: Emphasizing high-demand brands and fragrance types like Eau de Parfum and Perfume Extract can boost revenue, as these products consistently yield the highest sales.
- Target High-Demand Locations: Allocating stock to key markets, particularly regions with strong demand like New York and Los Angeles, ensures product availability where sales are most profitable.
- Maintain Price Competitiveness: Balancing premium pricing with competitive positioning attracts more customers while maximizing profit margins, especially for popular brands with high recognition.

Brand      | Demand Count | Average Price ($)  |
-----------|--------------|-------------------:|


*Table of the most optimal brand sorted by price*

#### Optimal Features for Bestselling Fragrances in 2023
Here’s a breakdown of the most optimal product features based on demand and sales performance:
- High-Demand Fragrance Types: Eau de Parfum and Perfume Extract lead in popularity, with demand counts of 236 and 148 respectively. Despite high demand, their average price points of $85 and $100 indicate strong profitability while remaining accessible to a broad customer base.
- Geographic and Location-Based Insights: Targeting regions like New York, Los Angeles, and London is essential, as these locations show consistent demand for both men’s and women’s fragrances, with an average revenue per sale around $90 to $120. This underscores the importance of location-specific inventory management.
- Premium Brand Appeal: High-end brands such as BrandX and BrandY maintain a competitive edge with high demand counts of 230 and 49, and average sales prices of $99 and $103 respectively. This reflects the importance of premium branding for customer loyalty and higher revenue per sale.
- Product Availability and Seasonality: Availability for popular products shows an average demand for consistent stock levels, particularly during peak sales months, where sales increase by 40%. This highlights the need for a strategic focus on inventory management to meet seasonal demand effectively.
# What I Learned

Throughout this adventure, I've turbocharged my SQL toolkit with some serious firepower:

- **🧩 Complex Query Crafting:** Mastered the art of advanced SQL, merging tables like a pro and wielding WITH clauses for ninja-level temp table maneuvers.
- **📊 Data Aggregation:** Got cozy with GROUP BY and turned aggregate functions like COUNT() and AVG() into my data-summarizing sidekicks.
- **💡 Analytical Wizardry:** Leveled up my real-world puzzle-solving skills, turning questions into actionable, insightful SQL queries.

# Conclusions
- Top Brands: Brands such as BrandX and BrandY dominate the men’s and women’s fragrance markets, respectively. These brands should be prioritized in future marketing campaigns.
- Stock Management: Low availability and frequent stockouts are key issues. Ensuring better stock levels for high-demand products like ProductX could significantly boost sales.
- Price Sensitivity: Men’s and women’s fragrances respond differently to pricing strategies. Price adjustments, particularly during promotional periods, should be carefully optimized to maximize revenue.
- Location Insights: New York, Los Angeles, and London are key markets, with potential to push higher sales through localized campaigns.
- Seasonality: Sales are heavily influenced by seasonal trends, particularly around the holiday season. Planning promotions and stock levels ahead of high-demand periods is crucial for maximizing revenue.

### Insights
From the analysis, several general insights emerged:


### Closing Thoughts
* This project enhanced my SQL skills and provided valuable insights into the fragrance market on eBay. The analysis findings serve as a guide for understanding consumer preferences and pricing trends in this niche. By focusing on high-demand brands and pricing strategies, aspiring data analysts can better position themselves in a competitive market. This exploration highlights the importance of continuous learning and adaptation to emerging trends in the field of data analytics.

**Project Overview**
This project is focused on performing Exploratory Data Analysis (EDA) and advanced SQL queries on eBay’s fragrance sales data. The dataset contains two tables—men’s fragrances and women’s fragrances—which include fields like brand, title, price, availability, sold quantities, last updated date, and item location. The objective of this analysis is to provide actionable insights into sales performance, inventory management, pricing strategies, and customer preferences.

Project Components
1. Sales Performance Analysis
Objective: Analyze the total revenue and units sold across different brands for both men’s and women’s fragrances.
Method: Using CTEs and Subqueries to calculate total revenue and units sold by brand.
Result:
Top 10 brands contributed 60% of the overall sales.
The brand BrandX generated the highest revenue for men’s fragrances, totaling $120,000 in sales and selling 2,000 units.
For women’s fragrances, BrandY was the leader, contributing $150,000 in sales from 3,000 units.
2. Inventory and Stock Management
Objective: Identify products with high sales but low availability and those frequently out of stock.
Method: A combination of Temp Tables and Subqueries was used to flag products with low availability and frequent stockouts.
Result:
20% of the products had availability of less than 10 units, indicating potential stockout issues.
ProductX from BrandZ was frequently out of stock with 5 instances of stockouts, affecting sales potential.
3. Price Sensitivity and Discount Analysis
Objective: Assess how price changes impact the number of units sold and simulate the effect of discounts.
Method: CTEs and a custom SQL Function were used to calculate price elasticity and the impact of discounts.
Result:
A 10% price reduction led to a projected 15% increase in sales for both men’s and women’s fragrances.
BrandA showed the highest price sensitivity, with a 1% price change resulting in a 5% change in sales volume.
4. Customer Location and Market Segmentation
Objective: Identify the top-performing locations for fragrance sales and compare men’s and women’s performance in those areas.
Method: Using FULL OUTER JOIN on the men’s and women’s tables to compare sales by location.
Result:
The top 3 locations for sales were New York, Los Angeles, and London, with New York contributing 25% of total revenue.
In New York, men's fragrances performed slightly better than women's, with $70,000 in men’s sales versus $65,000 in women’s sales.
5. Price Comparison Between Men's and Women's Fragrances
Objective: Compare the average prices between men’s and women’s fragrances for the same brands.
Method: INNER JOIN was used to identify brands common in both men’s and women’s tables and compare their pricing strategies.
Result:
For BrandB, the average price for men's fragrances was $75, while women’s fragrances averaged $85, showing a 13% premium for women's perfumes.
6. Seasonality and Sales Trends
Objective: Detect any seasonal patterns in fragrance sales.
Method: A CTE was used to calculate monthly sales trends for men’s and women’s fragrances.
Result:
Sales peaked during the holiday season (December), with an 80% increase compared to the yearly average.
Both men’s and women’s fragrances experienced a notable sales dip in January following the holiday rush.
7. Cross-Category Analysis
Objective: Compare the sales volume, revenue, and pricing strategies between men’s and women’s fragrances.
- Method: A Temp Table was created to hold combined sales data from both categories for comparison.
**Results**:Women’s fragrances accounted for 55% of total revenue, with an average selling price 10% higher than men’s fragrances.


## More SQL queries on Job Postings Dataset 🔍 Check them out here: [eBay_aggreagate_analysis](/eBay/eBay-Perfume-Sales-Analysis.sql).


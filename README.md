# 📊 Credit Risk Analysis & Scorecard Dashboard

An end-to-end **Credit Risk Scorecard** project built using **MS SQL Server** and **Microsoft Excel**, demonstrating how raw borrower and payment data can be transformed into actionable credit risk insights.

---

## 🎯 Project Objective
To evaluate borrower creditworthiness by:
- Engineering meaningful risk features
- Applying a transparent, rule-based scoring model
- Segmenting borrowers into **Low**, **Medium**, and **High** risk categories
- Visualizing insights through an executive-ready Excel dashboard

---

## 🗂️ Data Overview
The project uses three core datasets:

| Dataset | Description |
|------|-------------|
| **Borrowers** | Demographic details and income information |
| **Loans** | Loan amount, tenure, and interest rate |
| **Payments** | Payment behavior including delays and late payments |

---

## 🛠️ SQL Implementation
SQL Server was used for the complete data engineering and scoring workflow:

✔️ Data cleaning and validation  
✔️ Feature engineering:
- Loan-to-Income Ratio  
- Average Payment Delay (days)  
- Late Payment Count  

✔️ Rule-based credit score calculation  
✔️ Risk segmentation:
- **Low Risk**
- **Medium Risk**
- **High Risk**

Final outputs were stored in structured tables for reporting and dashboard integration.

---

## 📈 Excel Dashboard
An interactive **Credit Risk Analysis Dashboard** was built in Excel to support business decision-making.

**Dashboard highlights:**
- Key KPIs (Total Borrowers, High-Risk %, Avg Loan-to-Income, Late Payment %)
- Borrower risk distribution
- Average delay days by risk segment
- Loan-to-Income ratio comparison across risk segments
- Clear written insights for stakeholders

---

## 🧰 Tools & Technologies
- 🗄️ MS SQL Server  
- 📊 Microsoft Excel  

---

## 📁 Repository Structure

- Credit-Risk-Analysis-and-Scorecard-Dashboard/
- ├── SQL/
- │ └── credit_risk_scorecard.sql
- ├── Excel/
- │ └── Credit_Risk_Dashboard.xlsx
- ├── Screenshots/
- │ └── Dashboard and SQL output images
- └── README.md



---

## 🔍 Key Insights
- Medium-risk borrowers form the largest segment of the portfolio
- Payment delays strongly influence risk classification
- Higher loan-to-income ratios are associated with increased credit risk
- Rule-based scorecards offer strong interpretability for credit decisions

---

## 📝 Notes
This project is created as a practical demonstration of credit risk analytics using simplified data for assessment and learning purposes.



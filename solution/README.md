Note 1: To manage dependencies in dbt, I packaged the project using Poetry. To run the dbt project, ensure Poetry is installed on your computer, then run 'poetry install' to install necessary dependencies.

Note 2: Additionally, I created a Dockerfile (excluding profiles.yml) for future use.

Note 3: The solution ignores mutability, so reports might change retroactively. To prevent this, we should:
a. Ensure data is immutable (e.g., event-based Snowplow).
b. Consume models from snapshots.

3. The data is available as CSV files in the `data/` directory, or as a SQLite database `data.sqlite` with the data already pre-populated into tables.

   You can choose to directly use the SQLite database, or load the CSV files into a database of your choice, e.g. BigQuery or PostgreSQL. 

### Solution:
I had limited experience with SQLite, and encountered an issue when attempting to connect with dbt. Specifically, the problem arose in the following files:
macros/materializations/models/table/table.sql
macros/materializations/models/table.sql

To save time, I opted to connect to Snowflake instead and uploaded given csvs as seeds.

1. Using dbt, create a project with the necessary transformations to create the following models:

   1. A transactional fact table for sales, with the grain set at the product level, and the following additional dimensions and metrics:
      1. new or returning customer
      2. number of days between first purchase and last purchase      
### Solution: sales/fct_sales.sql


   2. A dimension table for “customers”, with the grain set at the customer_id, and the following additional dimensions and metrics:
      1. number of orders
      2. value of most expensive order
      3. whether it’s one of the top 10 customers (by revenue generated)
### Solution: sales/dim_customer.sql


   3. A dimension table for monthly cohorts, with the grain set at country leveland the following additional dimensions and metrics:
      1. Number of customers in the monthly cohort (customers are assigned in cohorts based on date of their first purchase)
      2. Cohort's total order value
   * Note: Every cohort should be available, even when the business didn't acquire a new customer that month (for the full timerange of order dates).
### Solution: sales/dim_monthly_conhorts.sql

For simplicity, I extracted the outputs as CSV files and stored them near the models.

otherwise:
1) create snowflake account
2) create database and schema

Create ~/.dbt/profiles.yml file for local development and testing:

```yml
default:
  target: dev
  outputs: 
    dev:
      type: snowflake
      account: ACCOUNT_ID.REGION (e.g. as3124.eu-central-1)
      user: YOUR_USERNAME
      password: YOUR_PASSWORD
      role: YOUR_ROLE (e.g. for case study ACCOUNTADMIN)
      database: YOUR_DATABASE (e.g. ANALYTICS_DB)
      schema: YOUR_SCHEMA (e.g. ANALYTICS)
      warehouse: YOUR_WAREHOUSE (e.g. COMPUTE_WH)
```

to execute dbt:

```sh
poetry run dbt clean && poetry run dbt deps && poetry run dbt seed && poetry run dbt run
```
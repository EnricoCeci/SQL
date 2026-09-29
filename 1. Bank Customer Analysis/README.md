# Bank Customer Analysis

## Overview

This project uses SQL to transform a relational banking database into a customer-level analytical table. Customer information, account ownership, and transaction records are combined to describe each customer's banking activity through demographic, account, and transaction indicators.

The final output contains one row per customer and **26 derived features**, covering age, account holdings, and incoming and outgoing transaction counts and amounts, both overall and by account type. This structure provides a foundation for customer profiling, segmentation, and further statistical or machine learning analysis.

The project focuses on SQL data preparation and feature engineering; predictive models and customer segmentation are potential downstream applications.

---

## Technologies

- **SQL / MySQL** for querying, aggregating, and transforming relational data.

---

## Project Requirements

Create a denormalized table in the `banca` database, using `id_cliente` as the customer identifier and calculating the following indicator groups:

| # | Indicator | Features |
| --- | --- | ---: |
| 1 | Customer age | 1 |
| 2 | Number of outgoing transactions across all accounts | 1 |
| 3 | Number of incoming transactions across all accounts | 1 |
| 4 | Total outgoing transaction amount across all accounts | 1 |
| 5 | Total incoming transaction amount across all accounts | 1 |
| 6 | Total number of accounts held | 1 |
| 7 | Number of accounts held by account type | 4 |
| 8 | Number of outgoing transactions by account type | 4 |
| 9 | Number of incoming transactions by account type | 4 |
| 10 | Outgoing transaction amount by account type | 4 |
| 11 | Incoming transaction amount by account type | 4 |

All customers must be retained in the final table, including those without accounts or transactions. Account counts must remain accurate after joining accounts to their transaction records.

---

## Dataset

Download the database script from [Google Drive](https://drive.google.com/file/d/1l54AQ2xGgP-1X6AU8nF53IOCt83I_h88/view).

The database is supplied in `db_bancario.sql`, which creates and populates the `banca` schema with five tables:

| Table | Content | Rows |
| --- | --- | ---: |
| `cliente` | Customer identifiers, names, and dates of birth | 200 |
| `conto` | Account identifiers, owners, and account types | 240 |
| `tipo_conto` | Account type descriptions | 4 |
| `tipo_transazione` | Transaction type descriptions and direction signs | 8 |
| `transazioni` | Transaction dates, types, amounts, and associated accounts | 14,685 |

Transaction dates range from **June 10, 2019, to June 8, 2022**.

### Table Relationships

- `cliente.id_cliente` links customers to `conto.id_cliente`.
- `conto.id_conto` links accounts to `transazioni.id_conto`.
- `conto.id_tipo_conto` corresponds to `tipo_conto.id_tipo_conto`.
- `transazioni.id_tipo_trans` corresponds to `tipo_transazione.id_tipo_transazione`.

These are logical relationships used to interpret and query the data; the supplied creation script does not declare primary or foreign key constraints. The final aggregation joins `cliente`, `conto`, and `transazioni`, using the type identifiers directly in its conditions.

### Account Types

| ID | Original description | English description |
| --- | --- | --- |
| 0 | Conto Base | Base account |
| 1 | Conto Business | Business account |
| 2 | Conto Privati | Private Customer account |
| 3 | Conto Famiglie | Family account |

### Transaction Direction

- **Incoming transactions:** type IDs `0–2`, representing salary, pension, and dividends.
- **Outgoing transactions:** type IDs `3–7`, representing Amazon purchases, mortgage instalments, hotels, airline tickets, and supermarket purchases.

Incoming amounts are positive and outgoing amounts are negative in the source data. The analysis preserves this sign convention when summing amounts.

SQL identifiers remain in Italian to match the original database. The [Italian SQL Identifiers — English Glossary](#italian-sql-identifiers--english-glossary) below explains table names, columns, aliases, and derived features, matching the glossary in the analysis script.


## Italian SQL Identifiers — English Glossary

### Database / Schema

| Italian SQL identifier | English meaning |
| --- | --- |
| `banca` | bank |

### Tables

| Italian SQL identifier | English meaning |
| --- | --- |
| `cliente` | customer |
| `conto` | account |
| `tipo_conto` | account type |
| `tipo_transazione` | transaction type |
| `transazioni` | transactions |
| `tab_denormalizzata` | denormalized table |

### Main Columns

| Italian SQL identifier | English meaning |
| --- | --- |
| `id_cliente` | customer ID |
| `nome` | first name |
| `cognome` | last name |
| `data_nascita` | date of birth |
| `id_conto` | account ID |
| `id_tipo_conto` | account type ID |
| `desc_tipo_conto` | account type description |
| `id_tipo_transazione` | transaction type ID |
| `desc_tipo_trans` | transaction type description |
| `segno` | sign |
| `data` | date |
| `id_tipo_trans` | transaction type ID |
| `importo` | amount |

### Derived Variables / Features

| Italian SQL identifier | English meaning |
| --- | --- |
| `eta` | age |
| `num_transazioni_uscita` | number of outgoing transactions |
| `num_transazioni_entrata` | number of incoming transactions |
| `importi_uscita` | total outgoing transaction amount |
| `importi_entrata` | total incoming transaction amount |
| `num_tot_conti` | total number of accounts |
| `num_conto_base` | number of Base accounts |
| `num_conto_business` | number of Business accounts |
| `num_conto_privati` | number of Private Customer accounts |
| `num_conto_famiglie` | number of Family accounts |
| `num_trans_uscita_c_base` | number of outgoing transactions on Base accounts |
| `num_trans_uscita_c_business` | number of outgoing transactions on Business accounts |
| `num_trans_uscita_c_privati` | number of outgoing transactions on Private Customer accounts |
| `num_trans_uscita_c_famiglie` | number of outgoing transactions on Family accounts |
| `num_trans_entrata_c_base` | number of incoming transactions on Base accounts |
| `num_trans_entrata_c_business` | number of incoming transactions on Business accounts |
| `num_trans_entrata_c_privati` | number of incoming transactions on Private Customer accounts |
| `num_trans_entrata_c_famiglie` | number of incoming transactions on Family accounts |
| `importo_uscita_c_base` | total outgoing amount on Base accounts |
| `importo_uscita_c_business` | total outgoing amount on Business accounts |
| `importo_uscita_c_privati` | total outgoing amount on Private Customer accounts |
| `importo_uscita_c_famiglie` | total outgoing amount on Family accounts |
| `importo_entrata_c_base` | total incoming amount on Base accounts |
| `importo_entrata_c_business` | total incoming amount on Business accounts |
| `importo_entrata_c_privati` | total incoming amount on Private Customer accounts |
| `importo_entrata_c_famiglie` | total incoming amount on Family accounts |

### Sign Convention

Outgoing transaction amounts are stored as negative values in the source data.
Incoming transaction amounts are stored as positive values in the source data.

### Table Aliases

| Italian SQL identifier | English meaning |
| --- | --- |
| `cl` | cliente (customer) |
| `cont` | conto (account) |
| `trans` | transazioni (transactions) |

### Abbreviations Used in Feature Names

| Italian SQL identifier | English meaning |
| --- | --- |
| `num` | number |
| `tot` | total |
| `trans` | transaction(s) |
| `uscita` | outgoing |
| `entrata` | incoming |
| `c` | conto (account) |


---

## Methodology

### 1. Database Inspection

Preview the five source tables to understand their contents and relationships. Count customers and accounts, then group accounts by customer to examine account ownership.

### 2. Individual Indicator Queries

Develop separate queries for each indicator group:

- Calculate age in completed years from `data_nascita` using `TIMESTAMPDIFF()`.
- Join transactions to accounts to associate each transaction with its customer.
- Calculate transaction counts and total amounts by customer and direction.
- Use conditional aggregation to break down account holdings and transaction activity by account type.

The standalone queries use direction filters through `WHERE`. Overall transaction indicators use `id_tipo_trans > 2` for outgoing transactions and `< 3` for incoming transactions; the standalone account-type transaction queries use explicit `IN (...)` lists.

### 3. Customer-Level Aggregation

Combine the indicators in a single query starting from `cliente`:

- **`LEFT JOIN`** retains every customer, even when no matching accounts or transactions exist.
- **Conditions inside `CASE WHEN`** calculate incoming and outgoing indicators together without a global direction filter removing rows needed by other indicators.
- **`COUNT(DISTINCT cont.id_conto)`** prevents accounts from being counted repeatedly after the join to transactions.
- **`COUNT(DISTINCT CASE WHEN ... END)`** applies the same protection to account counts by type.
- **`GROUP BY cl.id_cliente, cl.data_nascita`** produces one row per customer in the supplied dataset.
- **`ROUND(..., 2)`** rounds aggregated monetary amounts to two decimal places in the final table.

### 4. Final Table Creation

Store the results in `banca.tab_denormalizzata` using `CREATE TABLE ... AS SELECT`.

The table contains `id_cliente` plus 26 derived features. Customers without accounts receive zero account and transaction indicators. Age is calculated at execution time, while transaction indicators summarize all available transaction records without a date filter.

The final query classifies transactions using `< 3` and `> 2`. These conditions match the incoming and outgoing type ranges in the supplied dataset; they would need reviewing if the transaction type coding changed.

---

## Project Structure

Keep the following files in the project directory:

| File | Purpose |
| --- | --- |
| `README.md` | Project overview, methodology, findings, and execution instructions |
| `db_bancario.sql` | Source script that creates and populates the banking database |
| `Bank customer analysis.sql` | Analysis queries, English comments and glossary, and final table creation |

---

## Main Findings

### Customer and Account Coverage

The source data contains **200 customers** and **240 accounts**. Of these customers, **142 hold at least one account**, **66 hold more than one account**, and **58 have no associated account**.

Retaining the complete customer population therefore matters in this dataset: an inner join from customers to accounts would exclude those 58 customers from the analytical table.

### Analytical Output

The final query is designed to produce **200 rows and 27 columns**: one customer identifier and **26 features** derived from the 11 indicator groups.

The resulting table brings together demographic information, account ownership, transaction frequency, and transaction amounts. Distinct account counts prevent transaction volume from inflating the number of accounts attributed to a customer.

### Business Relevance

The features can support comparisons of customer activity, account usage, and incoming and outgoing flows. They can also serve as inputs for later segmentation or predictive modelling. These applications would require additional analysis and validation beyond the scope of this project.

---

## How to Run

1. Connect to a MySQL server using a SQL client, such as MySQL Workbench.
2. Open and execute `db_bancario.sql` to create and populate the `banca` database.
3. Open and execute `Bank customer analysis.sql`. The initial queries display source data and individual indicators; the final statement creates `banca.tab_denormalizzata`.
4. Inspect the output:

```sql
SELECT *
FROM banca.tab_denormalizzata
ORDER BY id_cliente;

SELECT COUNT(*) AS num_customers
FROM banca.tab_denormalizzata;
```

With the supplied dataset, the customer count should be **200**.

The setup script expects the `banca` database to be absent, and the final analysis statement expects `tab_denormalizzata` to be absent. For subsequent runs, use a fresh environment or deliberately manage the existing objects before rerunning their creation statements.

The output is a stored table, not a live view: changes to source data or the execution date are reflected only when the table is rebuilt.

```sql

/*BANK CUSTOMER ANALYSIS*/



/*
ITALIAN SQL IDENTIFIERS - ENGLISH GLOSSARY

DATABASE / SCHEMA
banca = bank


TABLES
cliente = customer
conto = account
tipo_conto = account type
tipo_transazione = transaction type
transazioni = transactions
tab_denormalizzata = denormalized table


MAIN COLUMNS
id_cliente = customer ID
nome = first name
cognome = last name
data_nascita = date of birth
id_conto = account ID
id_tipo_conto = account type ID
desc_tipo_conto = account type description
id_tipo_transazione = transaction type ID
desc_tipo_trans = transaction type description
segno = sign
data = date
id_tipo_trans = transaction type ID
importo = amount


DERIVED VARIABLES / FEATURES
eta = age

num_transazioni_uscita = number of outgoing transactions
num_transazioni_entrata = number of incoming transactions

importi_uscita = total outgoing transaction amount
importi_entrata = total incoming transaction amount

num_tot_conti = total number of accounts

num_conto_base = number of Base accounts
num_conto_business = number of Business accounts
num_conto_privati = number of Private Customer accounts
num_conto_famiglie = number of Family accounts

num_trans_uscita_c_base = number of outgoing transactions on Base accounts
num_trans_uscita_c_business = number of outgoing transactions on Business accounts
num_trans_uscita_c_privati = number of outgoing transactions on Private Customer accounts
num_trans_uscita_c_famiglie = number of outgoing transactions on Family accounts

num_trans_entrata_c_base = number of incoming transactions on Base accounts
num_trans_entrata_c_business = number of incoming transactions on Business accounts
num_trans_entrata_c_privati = number of incoming transactions on Private Customer accounts
num_trans_entrata_c_famiglie = number of incoming transactions on Family accounts

importo_uscita_c_base = total outgoing amount on Base accounts
importo_uscita_c_business = total outgoing amount on Business accounts
importo_uscita_c_privati = total outgoing amount on Private Customer accounts
importo_uscita_c_famiglie = total outgoing amount on Family accounts

importo_entrata_c_base = total incoming amount on Base accounts
importo_entrata_c_business = total incoming amount on Business accounts
importo_entrata_c_privati = total incoming amount on Private Customer accounts
importo_entrata_c_famiglie = total incoming amount on Family accounts


SIGN CONVENTION
Outgoing transaction amounts are stored as negative values in the source data.
Incoming transaction amounts are stored as positive values in the source data.


TABLE ALIASES
cl = cliente (customer)
cont = conto (account)
trans = transazioni (transactions)


ABBREVIATIONS USED IN FEATURE NAMES
num = number
tot = total
trans = transaction(s)
uscita = outgoing
entrata = incoming
c = conto (account)
*/



/*

Table preview

*/



select *

from banca.cliente;



select *

from banca.conto;



select *

from banca.tipo_conto;



select *

from banca.tipo_transazione;



select *

from banca.transazioni;



/*---------------------------------------------------------------------------------*/



/*BASIC INDICATORS*/



/*1. Customer age

DERIVED VARIABLES / FEATURES
eta = age

*/



select

id_cliente,

timestampdiff(YEAR, data_nascita, current_date()) as eta

from banca.cliente;



/*----------------------------------------------------------------------------------*/



/* TRANSACTION INDICATORS*/



/*2. Number of outgoing transactions across all accounts

DERIVED VARIABLES / FEATURES
num_transazioni_uscita = number of outgoing transactions

*/

/*

The 'conto' and 'transazioni' tables were joined through id_conto, after which a filter was applied to count only transactions with id_tipo_trans > 2 (types 3 through 7 in this dataset), which were finally grouped by customer.

*/



select

cont.id_cliente,

count(*) as num_transazioni_uscita

from banca.transazioni trans

join banca.conto cont

on trans.id_conto = cont.id_conto

where trans.id_tipo_trans>2

group by cont.id_cliente;





/*3. Number of incoming transactions across all accounts

DERIVED VARIABLES / FEATURES
num_transazioni_entrata = number of incoming transactions

*/

/*

The 'conto' and 'transazioni' tables were joined through id_conto, after which a filter was applied to count only transactions with id_tipo_trans < 3 (types 0 through 2 in this dataset), 
which were finally grouped by customer.

*/



select

cont.id_cliente,

count(*) as num_transazioni_entrata

from banca.transazioni trans

join banca.conto cont

on trans.id_conto = cont.id_conto

where trans.id_tipo_trans < 3

group by cont.id_cliente;





/*4. Total outgoing transaction amount across all accounts

DERIVED VARIABLES / FEATURES
importi_uscita = total outgoing transaction amount

*/

/*

The 'conto' and 'transazioni' tables were joined through id_conto, after which a filter was applied to sum only transaction amounts with id_tipo_trans > 2 (types 3 through 7 in this dataset), 
which were finally grouped by customer.

*/



select

cont.id_cliente,

sum(importo) as importi_uscita

from banca.transazioni trans

join banca.conto cont

on trans.id_conto = cont.id_conto

where trans.id_tipo_trans > 2

group by cont.id_cliente;





/*5. Total incoming transaction amount across all accounts

DERIVED VARIABLES / FEATURES
importi_entrata = total incoming transaction amount

*/

/*

The 'conto' and 'transazioni' tables were joined through id_conto, after which a filter was applied to sum only transaction amounts with id_tipo_trans < 3 (types 0 through 2 in this dataset), 
which were finally grouped by customer.

*/

select

cont.id_cliente,

sum(importo) as importi_entrata

from banca.transazioni trans

join banca.conto cont

on trans.id_conto = cont.id_conto

where trans.id_tipo_trans < 3

group by cont.id_cliente;



/*------------------------------------------------------------------------------------*/



/*ACCOUNT INDICATORS*/

/*6. Total number of accounts held*/



select

count(id_cliente)

from banca.cliente;



select

count(id_conto)

from banca.conto;



/*

The count of 'id_cliente' in the 'cliente' table returns 200 customers, while the count of 'id_conto' in the 'conto' table equals 240.

This means that the bank has a total of 240 accounts and that some customers hold more than one account.

*/



/* Count the accounts held by each customer through grouping*/

select

       id_cliente,

    count(id_conto)

from banca.conto

group by id_cliente;





/* 7. Number of accounts held by account type (one indicator for each account type).

DERIVED VARIABLES / FEATURES
num_conto_base = number of Base accounts
num_conto_business = number of Business accounts
num_conto_privati = number of Private Customer accounts
num_conto_famiglie = number of Family accounts

*/



/*

For each id_cliente, the number of accounts held for each account type was counted.

This was done by checking, for each customer, how many occurrences of each id_tipo_conto were associated in the 'conto' table.

*/



select

    id_cliente,



    sum(case when id_tipo_conto = 0 then 1 else 0 end) as num_conto_base,

    sum(case when id_tipo_conto = 1 then 1 ELSE 0 end) as num_conto_business,

    sum(case when id_tipo_conto = 2 then 1 ELSE 0 end) as num_conto_privati,

    sum(case when id_tipo_conto = 3 then 1 ELSE 0 end) as num_conto_famiglie



from banca.conto

group by id_cliente;



/*------------------------------------------------------------------------------------*/



/* TRANSACTION INDICATORS BY ACCOUNT TYPE

DERIVED VARIABLES / FEATURES
num_trans_uscita_c_base = number of outgoing transactions on Base accounts
num_trans_uscita_c_business = number of outgoing transactions on Business accounts
num_trans_uscita_c_privati = number of outgoing transactions on Private Customer accounts
num_trans_uscita_c_famiglie = number of outgoing transactions on Family accounts

*/

/* 8. Number of outgoing transactions by account type (one indicator for each account type)*/

/*

The 'transazioni' and 'conto' tables were joined so that each transaction could be associated with the corresponding account type and account owner.

Outgoing transactions were then selected by filtering on the transaction type (types 3 through 7).

Finally, for each customer, the number of outgoing transactions was counted for each account type.

*/



select

 cont.id_cliente,



    sum(case when cont.id_tipo_conto = 0 then 1 else 0 end) as num_trans_uscita_c_base,

    sum(case when cont.id_tipo_conto = 1 then 1 else 0 end) as num_trans_uscita_c_business,

    sum(case when cont.id_tipo_conto = 2 then 1 else 0 end) as num_trans_uscita_c_privati,

    sum(case when cont.id_tipo_conto = 3 then 1 else 0 end) as num_trans_uscita_c_famiglie

from

banca.transazioni trans

inner join banca.conto cont

on trans.id_conto = cont.id_conto

where id_tipo_trans in (3,4,5,6,7)

group by cont.id_cliente;



/*---------------------------------------------------------------------------------------------*/



/* 9. Number of incoming transactions by account type (one indicator for each account type)

DERIVED VARIABLES / FEATURES
num_trans_entrata_c_base = number of incoming transactions on Base accounts
num_trans_entrata_c_business = number of incoming transactions on Business accounts
num_trans_entrata_c_privati = number of incoming transactions on Private Customer accounts
num_trans_entrata_c_famiglie = number of incoming transactions on Family accounts

*/

/*

The 'transazioni' and 'conto' tables were joined so that each transaction could be associated with the corresponding account type and account owner.

Incoming transactions were then selected by filtering on the transaction type (types 0 through 2).

Finally, for each customer, the number of incoming transactions was counted for each account type.

*/



select

 cont.id_cliente,



    sum(case when cont.id_tipo_conto = 0 then 1 else 0 end) as num_trans_entrata_c_base,

    sum(case when cont.id_tipo_conto = 1 then 1 else 0 end) as num_trans_entrata_c_business,

    sum(case when cont.id_tipo_conto = 2 then 1 else 0 end) as num_trans_entrata_c_privati,

    sum(case when cont.id_tipo_conto = 3 then 1 else 0 end) as num_trans_entrata_c_famiglie

from

banca.transazioni trans

inner join banca.conto cont

on trans.id_conto = cont.id_conto

where trans.id_tipo_trans in (0,1,2)

group by cont.id_cliente;







/* 10. Outgoing transaction amount by account type (one indicator for each account type)

DERIVED VARIABLES / FEATURES
importo_uscita_c_base = total outgoing amount on Base accounts
importo_uscita_c_business = total outgoing amount on Business accounts
importo_uscita_c_privati = total outgoing amount on Private Customer accounts
importo_uscita_c_famiglie = total outgoing amount on Family accounts

*/

/*

The 'transazioni' and 'conto' tables were joined so that each transaction

containing an amount could be associated with the corresponding account type and account owner.

Outgoing amounts were then selected by filtering on the transaction type

(types 3 through 7).

Finally, for each customer, the total outgoing amount was calculated for each account type.

*/



select

    cont.id_cliente,



    sum(case when cont.id_tipo_conto = 0 then trans.importo else 0 end) as importo_uscita_c_base,

    sum(case when cont.id_tipo_conto = 1 then trans.importo else 0 end) as importo_uscita_c_business,

    sum(case when cont.id_tipo_conto = 2 then trans.importo else 0 end) as importo_uscita_c_privati,

    sum(case when cont.id_tipo_conto = 3 then trans.importo else 0 end) as importo_uscita_c_famiglie



from banca.transazioni trans

inner join banca.conto cont

    on trans.id_conto = cont.id_conto

where trans.id_tipo_trans in (3,4,5,6,7)

group by cont.id_cliente;







/* 11. Incoming transaction amount by account type (one indicator for each account type)

DERIVED VARIABLES / FEATURES
importo_entrata_c_base = total incoming amount on Base accounts
importo_entrata_c_business = total incoming amount on Business accounts
importo_entrata_c_privati = total incoming amount on Private Customer accounts
importo_entrata_c_famiglie = total incoming amount on Family accounts

*/

/*

The 'transazioni' and 'conto' tables were joined so that each transaction containing an amount could be associated with the corresponding account type and account owner.

Incoming amounts were then selected by filtering on the transaction type (types 0 through 2).

Finally, for each customer, the total incoming amount was calculated for each account type.

*/



select

    cont.id_cliente,



    sum(case when cont.id_tipo_conto = 0 then trans.importo else 0 end) as importo_entrata_c_base,

    sum(case when cont.id_tipo_conto = 1 then trans.importo else 0 end) as importo_entrata_c_business,

    sum(case when cont.id_tipo_conto = 2 then trans.importo else 0 end) as importo_entrata_c_privati,

    sum(case when cont.id_tipo_conto = 3 then trans.importo else 0 end) as importo_entrata_c_famiglie



from banca.transazioni trans

inner join banca.conto cont

    on trans.id_conto = cont.id_conto

where trans.id_tipo_trans in (0,1,2)

group by cont.id_cliente;



/*-------------------------------------------------------------------------------------------------*/



/*DENORMALIZED TABLE*/

/*

The query used to build the denormalized table differs from the individual indicator queries in several ways:



1) Use of LEFT JOIN

This query starts from the 'cliente' table and uses LEFT JOINs to retain all customers,

including those without accounts or transactions, who would otherwise be excluded from the final table by INNER JOINs.



2) Moving filters inside CASE WHEN expressions

Since incoming and outgoing transactions, counts, and amounts must be calculated simultaneously, a single global WHERE filter cannot be used to separate the different transaction categories
without excluding rows needed for other indicators. The filtering conditions are therefore moved inside the CASE WHEN expressions, allowing multiple indicators to be calculated within the same query.



3) Single final GROUP BY

Only one final grouping operation is required: GROUP BY cl.id_cliente, cl.data_nascita



4) Use of COUNT(DISTINCT ...)

COUNT(DISTINCT id_conto) is used for account-related indicators to avoid counting the same account multiple times, since joining with the 'transazioni' table can generate multiple rows associated with the same account.

*/



/*==============================================================
       BASIC INDICATORS
==============================================================*/

create table banca.tab_denormalizzata as



-- Indicator 1: customer age

select

    cl.id_cliente,

    timestampdiff(year, cl.data_nascita, current_date()) as eta,



/*==============================================================
       TRANSACTION INDICATORS 2 - 5
==============================================================*/

-- Indicator 2: # outgoing transactions across all accounts

       sum(case when trans.id_tipo_trans > 2 then 1 else 0 end) as num_transazioni_uscita,



-- Indicator 3: # incoming transactions across all accounts

       sum(case when trans.id_tipo_trans < 3 then 1 else 0 end) as num_transazioni_entrata,



-- Indicator 4: total outgoing transaction amount across all accounts

       round(sum(case when trans.id_tipo_trans > 2 then trans.importo else 0 end),2) as importi_uscita,



-- Indicator 5: total incoming transaction amount across all accounts

       round(sum(case when trans.id_tipo_trans < 3 then trans.importo else 0 end),2) as importi_entrata,



/*==============================================================
       ACCOUNT INDICATORS 6 - 7
==============================================================*/

/* 

DERIVED VARIABLES / FEATURES
num_tot_conti = total number of accounts

*/

-- Indicator 6: total number of accounts held

    count(distinct cont.id_conto) as num_tot_conti,



-- Indicator 7: number of accounts held by account type (one indicator for each account type).

    count(distinct case when cont.id_tipo_conto = 0 then cont.id_conto end) as num_conto_base,

    count(distinct case when cont.id_tipo_conto = 1 then cont.id_conto end) as num_conto_business,

    count(distinct case when cont.id_tipo_conto = 2 then cont.id_conto end) as num_conto_privati,

    count(distinct case when cont.id_tipo_conto = 3 then cont.id_conto end) as num_conto_famiglie,



/*==============================================================
       TRANSACTION INDICATORS BY ACCOUNT TYPE 8 - 11
==============================================================*/

-- Indicator 8: number of outgoing transactions by account type (one indicator for each account type)

    sum(case when cont.id_tipo_conto = 0 and trans.id_tipo_trans > 2 then 1 else 0 end) as num_trans_uscita_c_base,

    sum(case when cont.id_tipo_conto = 1 and trans.id_tipo_trans > 2 then 1 else 0 end) as num_trans_uscita_c_business,

    sum(case when cont.id_tipo_conto = 2 and trans.id_tipo_trans > 2 then 1 else 0 end) as num_trans_uscita_c_privati,

    sum(case when cont.id_tipo_conto = 3 and trans.id_tipo_trans > 2 then 1 else 0 end) as num_trans_uscita_c_famiglie,



-- Indicator 9: number of incoming transactions by account type (one indicator for each account type)

    sum(case when cont.id_tipo_conto = 0 and trans.id_tipo_trans < 3 then 1 else 0 end) as num_trans_entrata_c_base,

    sum(case when cont.id_tipo_conto = 1 and trans.id_tipo_trans < 3 then 1 else 0 end) as num_trans_entrata_c_business,

    sum(case when cont.id_tipo_conto = 2 and trans.id_tipo_trans < 3 then 1 else 0 end) as num_trans_entrata_c_privati,

    sum(case when cont.id_tipo_conto = 3 and trans.id_tipo_trans < 3 then 1 else 0 end) as num_trans_entrata_c_famiglie,



-- Indicator 10: outgoing transaction amount by account type (one indicator for each account type)

    round(sum(case when cont.id_tipo_conto = 0 and trans.id_tipo_trans > 2 then trans.importo else 0 end),2) as importo_uscita_c_base,

    round(sum(case when cont.id_tipo_conto = 1 and trans.id_tipo_trans > 2 then trans.importo else 0 end),2) as importo_uscita_c_business,

    round(sum(case when cont.id_tipo_conto = 2 and trans.id_tipo_trans > 2 then trans.importo else 0 end),2) as importo_uscita_c_privati,

    round(sum(case when cont.id_tipo_conto = 3 and trans.id_tipo_trans > 2 then trans.importo else 0 end),2) as importo_uscita_c_famiglie,



-- Indicator 11: Incoming transaction amount by account type (one indicator for each account type)

    round(sum(case when cont.id_tipo_conto = 0 and trans.id_tipo_trans < 3 then trans.importo else 0 end),2) as importo_entrata_c_base,

    round(sum(case when cont.id_tipo_conto = 1 and trans.id_tipo_trans < 3 then trans.importo else 0 end),2) as importo_entrata_c_business,

    round(sum(case when cont.id_tipo_conto = 2 and trans.id_tipo_trans < 3 then trans.importo else 0 end),2) as importo_entrata_c_privati,

    round(sum(case when cont.id_tipo_conto = 3 and trans.id_tipo_trans < 3 then trans.importo else 0 end),2) as importo_entrata_c_famiglie



from banca.cliente cl



left join banca.conto cont

    on cl.id_cliente = cont.id_cliente



left join banca.transazioni trans

    on cont.id_conto = trans.id_conto



group by cl.id_cliente, cl.data_nascita;

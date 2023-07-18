<!-- Project Title -->
<h1 align="center"> Data Mart - Clique Bait </h1>

<p align="center">
  <img src="logo-week6.png" alt="isolated" width="500"/>
</p>

<!-- Table of Contents -->
## Table of Contents

- [Introduction](#introduction)
- [Dataset](#dataset)
- [Entity Relationship Diagram](#entity-relationship)


<!-- Introduction -->
# Introduction:

Clique Bait isn't your typical online seafood retailer - it's the brainchild of founder and CEO, Danny, who leverages his experience from working in digital data analytics, aiming to bring new insights into the seafood sector!

For this case study, the task is to help Danny's ambition by assessing his dataset. Your objective is to conjure inventive methods to determine the funnel dropout rates for the Clique Bait online store.

<!-- Dataset -->
# Dataset:

### Table 1: Users

Customers who visit the Clique Bait website are tagged via their cookie_id

- Short overview: 

| user_id | cookie_id | start_date            |
|---------|-----------|-----------------------|
| 397     | 3759ff    | 2020-03-30 00:00:00   |
| 215     | 863329    | 2020-01-26 00:00:00   |
| 191     | eefca9    | 2020-03-15 00:00:00   |
| 89      | 764796    | 2020-01-07 00:00:00   |
| 127     | 17ccc5    | 2020-01-22 00:00:00   |
| 81      | b0b666    | 2020-03-01 00:00:00   |
| 260     | a4f236    | 2020-01-08 00:00:00   |
| 203     | d1182f    | 2020-04-18 00:00:00   |
| 23      | 12dbc8    | 2020-01-18 00:00:00   |
| 375     | f61d69    | 2020-01-03 00:00:00   |


### Table2 : Events

Customer visits are logged in this events table at a cookie_id level and the event_type and page_id values can be used to join onto relevant satellite tables to obtain further information about each event.

The sequence_number is used to order the events within each visit.

- Short overview: 

| visit_id | cookie_id | page_id | event_type | sequence_number | event_time                |
|----------|-----------|---------|------------|-----------------|---------------------------|
| 719fd3   | 3d83d3    | 5       | 1          | 4               | 2020-03-02 00:29:09.975502 |
| fb1eb1   | c5ff25    | 5       | 2          | 8               | 2020-01-22 07:59:16.761931 |
| 23fe81   | 1e8c2d    | 10      | 1          | 9               | 2020-03-21 13:14:11.745667 |
| ad91aa   | 648115    | 6       | 1          | 3               | 2020-04-27 16:28:09.824606 |
| 5576d7   | ac418c    | 6       | 1          | 4               | 2020-01-18 04:55:10.149236 |
| 48308b   | c686c1    | 8       | 1          | 5               | 2020-01-29 06:10:38.702163 |
| 46b17d   | 78f9b3    | 7       | 1          | 12              | 2020-02-16 09:45:31.926407 |
| 9fd196   | ccf057    | 4       | 1          | 5               | 2020-02-14 08:29:12.922164 |
| edf853   | f85454    | 1       | 1          | 1               | 2020-02-22 12:59:07.652207 |
| 3c6716   | 02e74f    | 3       | 2          | 5               | 2020-01-31 17:56:20.777383 |

### Table 3: Event Identifier

The event_identifier table shows the types of events which are captured by Clique Bait’s digital data systems.

- Short overview: 

| event_type | event_name   |
|------------|--------------|
| 1          | Page View    |
| 2          | Add to Cart  |
| 3          | Purchase     |
| 4          | Ad Impression|
| 5          | Ad Click     |


### Table 4: Campaign Identifier

This table shows information for the 3 campaigns that Clique Bait has ran on their website so far in 2020.

- Short overview: 

| campaign_id | products | campaign_name                  | start_date            | end_date              |
|-------------|----------|--------------------------------|-----------------------|-----------------------|
| 1           | 1-3      | BOGOF - Fishing For Compliments| 2020-01-01 00:00:00   | 2020-01-14 00:00:00   |
| 2           | 4-5      | 25% Off - Living The Lux Life  | 2020-01-15 00:00:00   | 2020-01-28 00:00:00   |
| 3           | 6-8      | Half Off - Treat Your Shellf(ish)| 2020-02-01 00:00:00 | 2020-03-31 00:00:00   |


### Table 5: Page Hierarchy

This table lists all of the pages on the Clique Bait website which are tagged and have data passing through from user interaction events.

- Short overview: 

| page_id | page_name    | product_category | product_id |
|---------|--------------|------------------|------------|
| 1       | Home Page    | null             | null       |
| 2       | All Products | null             | null       |
| 3       | Salmon       | Fish             | 1          |
| 4       | Kingfish     | Fish             | 2          |
| 5       | Tuna         | Fish             | 3          |
| 6       | Russian Caviar | Luxury         | 4          |
| 7       | Black Truffle | Luxury          | 5          |
| 8       | Abalone      | Shellfish       | 6          |
| 9       | Lobster      | Shellfish       | 7          |
| 10      | Crab         | Shellfish       | 8          |
| 11      | Oyster       | Shellfish       | 9          |
| 12      | Checkout     | null             | null       |
| 13      | Confirmation | null             | null       |

<!-- Entity Relationship Diagram -->
# Entity Relationship Diagram: 

![Diagram](data-model-week6.png "Entity Relationship Diagram!")
import pandas as pd
import mysql.connector

#==========================================
# Load dataset
#==========================================

df = pd.read_csv("Superstore.csv", encoding="latin1")

#==========================================
# Data Cleaning
#==========================================

df = df.drop_duplicates()
df = df.dropna(subset=['Order ID', 'Customer ID'])

df.columns = (
    df.columns.str.strip()
    .str.lower()
    .str.replace(" ", "_")
    .str.replace("-", "_")
)

#==========================================
# Date Conversion
#==========================================

df["order_date"] = pd.to_datetime(df["order_date"], format="%m/%d/%Y")
df["ship_date"] = pd.to_datetime(df["ship_date"], format="%m/%d/%Y")

#==========================================
# Create Date Keys
#==========================================

df["order_date_key"] = df["order_date"].dt.strftime("%Y%m%d").astype(int)
df["ship_date_key"] = df["ship_date"].dt.strftime("%Y%m%d").astype(int)

#==========================================
# Create Dimension Tables
#==========================================

#CUSTOMER
customer_df = df[
    ["customer_id", "customer_name", "segment"]
].drop_duplicates()

#PRODUCT
product_df = (
    df[['product_id', 'product_name', 'category', 'sub_category']]
    .drop_duplicates(subset='product_id')
    .reset_index(drop=True))

#GEOGRAPHY
geo_df = df[['postal_code','city','state','country','region']].drop_duplicates().reset_index(drop=True)
geo_df['location_id'] = geo_df.index + 1

#SHIPPING
shipping_df = df[['ship_mode']].drop_duplicates().reset_index(drop=True)
shipping_df['shipping_id'] = shipping_df.index + 1

df = df.merge(geo_df, on=['postal_code','city','state','country','region'], how='left')
df = df.merge(shipping_df, on='ship_mode', how='left')

#DATE
date_df = pd.DataFrame({
    'full_date': pd.concat([df['order_date'], df['ship_date']]).unique()
})

date_df['full_date'] = pd.to_datetime(date_df['full_date'])
date_df['date_key'] = date_df['full_date'].dt.strftime('%Y%m%d').astype(int)
date_df['year_num'] = date_df['full_date'].dt.year
date_df['month_num'] = date_df['full_date'].dt.month
date_df['day_num'] = date_df['full_date'].dt.day
date_df['month_name'] = date_df['full_date'].dt.strftime('%B')
date_df['quarter_num'] = date_df['full_date'].dt.quarter


#==========================================
# Create Fact Table
#==========================================
fact_df = df[
    [
        "order_id",
        "customer_id",
        "product_id",
        "location_id",
        "shipping_id",
        "order_date_key",
        "ship_date_key",
        "sales",
        "profit",
        "quantity",
        "discount"
    ]
]

#==========================================
# Connect to MySQL
#==========================================

conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password="******",
    database="sales_dw")


#==========================================
# Load data into MYSQL DATA WAREHOUSE
#==========================================

cursor = conn.cursor()
conn.autocommit = True

#CUSTOMER
customer_data = list(customer_df.itertuples(index=False, name=None))

cursor.executemany("""
INSERT INTO dim_customer (customer_id, customer_name, segment)
VALUES (%s, %s, %s)
""", customer_data)

conn.commit()


#PRODUCT
product_data = list(product_df.itertuples(index=False, name=None))

cursor.executemany("""
INSERT INTO dim_product (product_id, product_name, category, sub_category)
VALUES (%s, %s, %s, %s)
""", product_data)

conn.commit()


#GEOGRAPHY
geo_data = list(geo_df[['location_id','country','city','state','postal_code','region']]
                .itertuples(index=False, name=None))

cursor.executemany("""
INSERT INTO dim_geography (location_id, country, city, state, postal_code, region)
VALUES (%s, %s, %s, %s, %s, %s)
""", geo_data)

conn.commit()


#DATE
date_data = list(date_df[[
    'date_key','full_date','year_num','month_num','day_num','month_name','quarter_num'
]].itertuples(index=False, name=None))

cursor.executemany("""
INSERT INTO dim_date (date_key, full_date, year_num, month_num, day_num, month_name, quarter_num)
VALUES (%s, %s, %s, %s, %s, %s, %s)
""", date_data)

conn.commit()


#SHIPPING
shipping_data = list(shipping_df[['shipping_id','ship_mode']]
                     .itertuples(index=False, name=None))

cursor.executemany("""
INSERT INTO dim_shipping (shipping_id, ship_mode)
VALUES (%s, %s)
""", shipping_data)

conn.commit()


#FACT TABLE
fact_data = list(fact_df.itertuples(index=False, name=None))

cursor.executemany("""
INSERT INTO fact_sales (
    order_id,
    customer_id,
    product_id,
    location_id,
    shipping_id,
    order_date_key,
    ship_date_key,
    sales,
    profit,
    quantity,
    discount)
VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
""", fact_data)

conn.commit()


cursor.close()
conn.close()

print("Sales Data Warehouse loaded successfully.")

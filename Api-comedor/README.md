## Docker Compose Nodejs MysqL

This is a simple example of a docker-compose file that creates a nodejs and mysql container.

### Considerations

- When mysql container is created, it will create a root user and a another user in the `MYSQLDB_USER` environment variable, each with its own password

### Commands

```sh
docker-compose up # to execute development
docker-compose -f docker-compose.prod.yml up # to execute production
```




###database

users
- id
- username
- password
- role ENUM('admin','subadmin','manager','employee')
- active
- created_at


bikes
- id
- brand
- model
- year
- color
- plate
- km
- owner
- created_at


inventory
- id
- item_name
- brand
- stock_min
- created_at

inventory_movements
- id
- inventory_id
- type ENUM('IN','OUT')
- quantity
- reason ENUM('purchase','order_use','adjustment')
- order_final_id NULL
- user_id
- created_at


order_init
- id
- bike_id
- order_date
- status_bike
- note
- created_by


order_final
- id
- bike_id
- order_init_id
- km
- note
- price
- status ENUM('open','finished','delivered')
- created_at


order_final_items
- id
- order_final_id
- inventory_id
- quantity
- price_unit


resume
-montly
-price
-num_order
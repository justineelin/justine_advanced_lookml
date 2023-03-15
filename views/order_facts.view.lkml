view: order_facts {
  derived_table: {
    sql:
      SELECT
    users.id  AS users_id,
    order_items.created_at AS order_items_created_date,
    order_items.order_id  AS order_items_order_id,
    COUNT(order_items.order_id) OVER(PARTITION BY users.id) AS CountOfOrders,
    ROW_NUMBER() OVER(PARTITION BY users.id order by order_items.created_at asc) AS OrderSequence,
    DATE_DIFF(DATE(order_items.created_at), LAG(DATE(order_items.created_at)) OVER (PARTITION BY users.id order by order_items.created_at asc), DAY) as DaysBetweenOrder
FROM `looker-private-demo.thelook.order_items`
     AS order_items
LEFT JOIN `looker-private-demo.thelook.users`
     AS users ON users.id = order_items.user_id;;
  }

  dimension: users_id {
    type: number
    primary_key: yes
    sql: ${TABLE}.users_id ;;
  }

  dimension_group: order_items_created_date {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.order_items_created_date ;;
  }

  dimension: order_items_order_id {
    type: number
    sql: ${TABLE}.order_items_order_id ;;
  }

  dimension: total_order_count_per_order {
    type: number
    sql: ${TABLE}.CountOfOrders;;
  }

  dimension: OrderSequence {
    type: number
    sql: ${TABLE}.OrderSequence ;;
  }

  dimension: DaysBetweenOrder {
    type: number
    sql: ${TABLE}.DaysBetweenOrder ;;
  }

  dimension: is_first_purchase {
    type: yesno
    sql: ${TABLE}.OrderSequence = 1 ;;
  }

  dimension: has_subsequent_order {
    type: yesno
    sql: ${total_order_count_per_order} >=2 ;;
  }

  measure: has_purchased_in_last_60_days {
    type: count_distinct
    filters: [DaysBetweenOrder: "<=60"]
    sql: ${users_id} ;;
  }

  measure: 60_Day_repeat_purchase_rate {
    type: number
    value_format_name: percent_2
    sql: ${has_purchased_in_last_60_days}/ ${customer_facts.customer if_has_at_least_one};;
  }

  measure: average_days_between_order {
    type: average
    sql: ${DaysBetweenOrder} ;;
  }
}

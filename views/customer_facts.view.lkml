view: customer_facts {
  derived_table: {
    sql:
      Select
        users_id,
        count(order_items_order_id) as order_count_per_cx,
        sum(order_items_sale_price) as sales_per_cx,
        min(order_items_created_date) as first_order,
        max(order_items_created_date) as last_order
FROM
(SELECT
    users.id  AS users_id,
    order_items.order_id  AS order_items_order_id,
    order_items.sale_price AS order_items_sale_price,
    order_items.created_at AS order_items_created_date
FROM `looker-private-demo.thelook.order_items`
     AS order_items
LEFT JOIN `looker-private-demo.thelook.users`
     AS users ON users.id = order_items.user_id
GROUP BY
    1,
    2,
    3,
    4
ORDER BY
    1)
group by users_id;;
  }

  dimension: users_id {
    type: number
    primary_key: yes
    sql: ${TABLE}.users_id ;;
  }

  dimension: order_count_per_cx {
    type: number
    sql: ${TABLE}.order_count_per_cx ;;
  }

  dimension: sales_per_cx {
    type: number
    sql: ${TABLE}.sales_per_cx ;;
    value_format_name: usd
  }

  dimension: customer_lifetime_orders {
    type: tier
    tiers: [1,2,3,6,10]
    style: integer
    sql: ${order_count_per_cx};;
  }

  dimension: customer_lifetime_revenue {
    type: tier
    tiers: [5,20,50,100,500,1000]
    style: integer
    sql: ${sales_per_cx};;
    value_format_name: usd
  }

  dimension: first_order_date {
    type: date
    sql: ${TABLE}.first_order ;;
  }

  dimension: latest_order_date {
    type: date
    sql: ${TABLE}.last_order ;;
  }

  dimension: is_active {
    type: yesno
    sql: DATE_DIFF(CURRENT_DATE(), ${latest_order_date}, DAY) < 90;;
  }

  dimension: days_since_latest_order {
    type: number
    sql: DATE_DIFF(CURRENT_DATE(), ${latest_order_date}, DAY) ;;
  }

  dimension: is_repeat_customer {
    type: yesno
    sql: ${order_count_per_cx}>1 ;;
  }

  measure: is_repeat_customer_measure {
    hidden: yes
    type: sum
    sql: if(${is_repeat_customer},1,0) ;;
  }

  measure: if_has_at_least_one {
    hidden: yes
    type: sum
    sql: if(${order_count_per_cx}>=1,1,0) ;;
  }

  measure: repeat_purchase_rate {
    type: number
    value_format_name: percent_2
    sql: ${is_repeat_customer_measure}/ ${if_has_at_least_one} ;;
  }

  measure: average_days_since_latest_order {
    type: average
    sql: ${days_since_latest_order} ;;
  }

  measure: total_lifetime_orders {
    type: sum
    sql: ${order_count_per_cx} ;;
  }

  measure: average_lifetime_orders {
    type: average
    sql: ${order_count_per_cx} ;;
  }

  parameter: metric_selector {
    type: unquoted
    allowed_value: {
      label: "Average Lifetime Orders"
      value: "AVG"
    }
    allowed_value: {
      label: "Total Lifetime Orders"
      value: "Total_O"
    }
    allowed_value: {
      label: "Total Lifetime Revenue"
      value: "Total_R"
    }
  }

  measure: dynamic_lifetime_calculation {
    sql:
      {% if metric_selector._parameter_value == "AVG" %} ${average_lifetime_orders}
      {% elsif metric_selector._parameter_value == "Total_O" %} ${total_lifetime_orders}
      {% elsif metric_selector._parameter_value == "Total_R" %} ${total_lifetime_revenue}
      {% endif %};;
    value_format_name: usd
  }

  measure: total_lifetime_revenue {
    type: sum
    value_format:"[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0.00"
    filters: [order_items.status: "-Returned, -Cancelled"]
    sql: ${sales_per_cx};;
  }

  measure: average_lifteime_revenue {
    type: average
    value_format:"[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0.00"
    filters: [order_items.status: "-Returned, -Cancelled"]
    sql: ${sales_per_cx};;
  }
}

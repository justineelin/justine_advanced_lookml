view: users {
  sql_table_name: `looker-private-demo.thelook.users`
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: age {
    type: number
    sql: ${TABLE}.age ;;
  }

  dimension: age_tier {
    type: tier
    tiers: [16,26,36,51,66]
    style: integer
    sql: ${age} ;;
  }

  parameter: age_tier_bucket_size {
    type: number
  }

  dimension: dynamic_age_tier {
    type: number
    sql: TRUNC(${age} / {% parameter age_tier_bucket_size %},0) * {% parameter age_tier_bucket_size %}  ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}.city ;;
  }

  dimension: country {
    type: string
    map_layer_name: countries
    sql: ${TABLE}.country ;;
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      day_of_week,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.created_at ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}.email ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}.first_name ;;
  }

  dimension: gender {
    type: string
    sql: ${TABLE}.gender ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}.last_name ;;
  }

  dimension: latitude {
    type: number
    sql: ${TABLE}.latitude ;;
  }

  dimension: longitude {
    type: number
    sql: ${TABLE}.longitude ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}.state ;;
    map_layer_name: us_states
    drill_fields: [products.category, products.brand, order_items.total_gross_margin]
  }

  dimension: traffic_source {
    type: string
    sql: ${TABLE}.traffic_source ;;
  }

  dimension: zip {
    type: zipcode
    sql: ${TABLE}.zip ;;
  }

  dimension: days_since_signup {
    type: number
    value_format_name: decimal_0
    description: "The number of days since the user has signed up"
    sql: DATE_DIFF(CURRENT_DATE(),DATE(${created_raw}),DAY) ;;
  }

  dimension: months_since_signup {
    type: number
    value_format_name: decimal_0
    sql: DATE_DIFF(CURRENT_DATE(),DATE(${created_raw}),MONTH) ;;
  }

  dimension: customer_cohort {
    label: "Customer Cohort (Months)"
    value_format: "0 \" Months\""
    type: tier
    tiers: [3,6,9,12,24]
    sql: ${months_since_signup} ;;
    style: integer
  }

  measure: avg_days_since_signup {
    type: average
    sql: ${days_since_signup} ;;
  }

  measure: avg_months_since_signup {
    type: average
    sql: ${months_since_signup} ;;
  }

  measure: num_of_cx_returning_items {
    type: count_distinct
    filters: [order_items.status: "Returned"]
    sql: ${id} ;;
  }

  measure: percent_users_with_returns {
    type: number
    sql: ${num_of_cx_returning_items}/NULLIF(${count},0) ;;
  }

  measure: avg_spend_per_cx {
    type: number
    value_format_name: usd
    sql: ${order_items.total_sale_price}/NULLIF(${count},0) ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      id,
      last_name,
      first_name,
      orders.count,
      order_items.count,
      order_items_final.count,
      events.count,
      order_items_test.count,
      order_items_test2.count
    ]
  }
}

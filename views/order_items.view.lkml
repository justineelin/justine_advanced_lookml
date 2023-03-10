view: order_items {
  sql_table_name: `looker-private-demo.thelook.order_items`
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      month_name,
      quarter,
      year
    ]
    sql: ${TABLE}.created_at ;;
  }

  dimension_group: delivered {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.delivered_at ;;
  }

  dimension: inventory_item_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.inventory_item_id ;;
  }

  dimension: order_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.order_id ;;
  }

  dimension_group: returned {
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
    sql: ${TABLE}.returned_at ;;
  }

  dimension: sale_price {
    type: number
    sql: ${TABLE}.sale_price ;;
  }

  measure: total_sale_price {
    type: sum
    sql: ${sale_price} ;;
    value_format_name: usd
  }

  measure: average_sale_price {
    type: average
    sql: ${sale_price} ;;
    value_format_name: usd
  }

  measure: cumulative_total_sales {
    type: running_total
    sql: ${sale_price} ;;
    value_format_name: usd
  }

  measure: total_gross_revenue {
    type: sum
    value_format:"[>=1000000]$0.00,,\"M\";[>=1000]$0.00,\"K\";$0.00"
    filters: [status: "-RETURNED, -CANCELLED"]
    sql: ${sale_price};;
    drill_fields: [users.age_tier, users.gender, total_gross_revenue]
  }

  measure: total_gross_margin {
    type: number
    sql: ${total_gross_revenue} - ${inventory_items.total_cost} ;;
    value_format_name: usd
  }

  measure: gross_margin_percentage {
    type: number
    value_format_name: percent_2
    sql: ${total_gross_margin}/NULLIF(${total_gross_revenue},0);;
  }

  measure: average_gross_margin {
    type: average
    sql: ${sale_price} - ${inventory_items.cost} ;;
  }

  measure: num_of_items_returned {
    type: count
    filters: [status: "Returned"]
  }

  measure: rate_of_items_returned {
    type: percent_of_total
    sql: ${num_of_items_returned};;
  }

  dimension_group: shipped {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.shipped_at ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension: user_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.user_id ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      id,
      users.last_name,
      users.id,
      users.first_name,
      inventory_items.id,
      inventory_items.product_name,
      orders.order_id
    ]
  }
}

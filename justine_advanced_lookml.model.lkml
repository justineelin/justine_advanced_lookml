connection: "looker-private-demo"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project
# include: "/**/*.view.lkml"                 # include all views in this project
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

# # Select the views that should be a part of this model,
# # and define the joins that connect them together.
#
# explore: order_items {
#   join: orders {
#     relationship: many_to_one
#     sql_on: ${orders.id} = ${order_items.order_id} ;;
#   }
#
#   join: users {
#     relationship: many_to_one
#     sql_on: ${users.id} = ${orders.user_id} ;;
#   }
# }

explore: order_items {
  label: "Order Item Information"

  join: inventory_items {
    type: left_outer
    relationship: one_to_one
    sql_on: ${order_items.inventory_item_id} = ${inventory_items.id} ;;
  }
  join: users {
    type: left_outer
    relationship:  one_to_one
    sql_on: ${users.id} = ${order_items.user_id};;
  }
  join: distribution_centers {
    type: left_outer
    relationship: one_to_one
    sql_on: ${inventory_items.product_distribution_center_id} = ${distribution_centers.id} ;;
  }
  join: products {
    type: left_outer
    relationship: one_to_one
    sql_on: ${inventory_items.product_id} = ${products.id} ;;
  }
  join: events {
    type: left_outer
    relationship: one_to_one
    sql_on: ${events.user_id} = ${users.id} ;;
  }
}

# ========================================================================
# Dependencies.
# ========================================================================

# provides in_groups, in_groups_of, and split methods on Array.
require 'active_support/core_ext/array/grouping'

#debugging.
require "awesome_print"

# ========================================================================
# top level namespace.
# ========================================================================

class CHAINABLE_GRAPH_FUNCTIONS; end

#
# ========================================================================
#
# A value representing a specific point in a graph.
# Includes N-dimentional info as well as links to other graph values.
# 
# Usage example:
#
# val = CHAINABLE_GRAPH_FUNCTIONS::GRAPH_VALUE.new(
#   dimensions: { x: 0, y: 1 }
# )
#
# These can be passed to to the CHAINABLE_GRAPH_FUNCTIONS::GRAPH_BUILDER constructor
# or via the #insert method on a GRAPH_BUILDER instance
#
# There is also a optional :linkages param which does not need to be manually
# set. It it manipulated by the GRAPH_BUILDER methods.
#
# ========================================================================
#

require_relative "./chainable_graph_functions/graph_value.rb"

#
# ========================================================================
#
# Graph factories:
# - Each function returns a new instance, so they are chainable. 
#
# Usage example:
#
# vals = 1.upto(10).map do |i|
#   CHAINABLE_GRAPH_FUNCTIONS::GRAPH_VALUE.new(
#     dimensions: { x: i }
#   )
# end
# graph = CHAINABLE_GRAPH_FUNCTIONS::GRAPH_BUILDER.new(values: vals)
# graph.to_singly_linked_list
#      .to_doubly_linked_list
#      .to_binary_search_tree
#      .to_balanced_binary_search_tree
#
# ========================================================================
require_relative "./chainable_graph_functions/graph_builder.rb"

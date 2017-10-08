class CHAINABLE_GRAPH_FUNCTIONS::GRAPH_BUILDER

  GRAPH_VALUE = CHAINABLE_GRAPH_FUNCTIONS::GRAPH_VALUE

  # Certain functions require a comparator block to be passed.
  # This can be used if it's a standard binary tree, with int/float values.
  # It's a higher-level function. Pass the dimension in the topmost argument,
  # receive a lambda which can be passed to another method
  B_TREE_COMPARATOR = -> (dimension) do
    ->(val, parent) { val.linkages[dimension] < parent.linkages[dimension] }
  end
  
  attr_reader :values
  attr_reader :root_val
  attr_reader :parent
  attr_reader :is_balanced

  # throws an error unless all the values are GRAPH_VALUE instances
  def values_with_typecheck(values)
    unless values.all? { |val| val.is_a?(GRAPH_VALUE)}
      raise ArgumentError, "passed :values aren't all GRAPH_VALUE instances"
    end
    values
  end
  
  # @param values [Array<GRAPH_VALUE>]
  # @param root_val [GRAPH_VALUE]
  # @param is_balanced [Boolean]
  def initialize(values: [], root_val: nil, is_balanced: nil)
    @values = values_with_typecheck(values)
    @root_val = root_val
  end
  
  # returns new instance with #root_val set.
  # :next set on all values' linkages.
  # @yield [GRAPH_VALUE, GRAPH_VALUE], each pair of values as they are seen.
  def singly_linked_list(&blk)
    root_val = nil
    values = @values.in_groups_of(2).each_with_object([]) do |(val1, val2), memo|
      root_val ||= val1
      val1.linkages[:next] = val2
      val1.linkges[:parent] = nil
      blk&.call(val1, val2)
      memo.push *[val1, val2].compact
    end
    self.class.new(values: values, root_val: root_val)
  end
  
  # returns new instance with #root_val set.
  # :next and :previous set on all values' linkages.
  def doubly_linked_list(&blk)
    singly_linked_list do |val1, val2|
      (val2.linkages[:prev] = val1) if val2
      blk&.call(val1, val2)
    end
  end

  # @param dimension, key in the value's dimensions hash.
  # The values stored at this key should be gt/lt comparable,
  # e.g. integers or floats
  def binary_search_tree(dimension:, &blk)
    search_tree(->(val, root) {
      val.dimensions[dimension] < root.dimensions[dimension]
    }, &blk)
  end

  # returns new instance with #root_val set.
  # :left and :right are set on most values' linkages, as is :parent.
  # @param comparator [Lambda], passed val and root.
  #   if it evaluates to true, :left gets set. Otherwise, right.
  # @yield [GRAPH_VALUE] whenever one gets it :parent set.
  def search_tree(comparator, &blk)
    root_val = nil
    values = @values.map do |value|
      if root_val
        search_tree_recurser(value, root_val, comparator, &blk)
      else
        value.tap { root_val = value }
      end
    end
    self.class.new(values: values, root_val: root_val)
  end

  # @param root [GRAPH_VALUE] changes with each recursive call
  # @param val [GRAPH_VALUE] the candidate to add
  # @param comparator [Lambda], see #search_tree
  # @yield [GRAPH_VALUE], see #search_tree
  def search_tree_recurser(val, root, comparator, &blk)
    root_linkages = root.linkages
    val_linkages = val.linkages
    if comparator.call(val, root)
      left_linkage = root_linkages[:left]
      if left_linkage
        # recurse to the next depth with the left linkage as root
        search_tree_recurser(val, left_linkage, comparator)
      else
        root_linkages[:left] = val
        val_linkages[:parent] = root
      end
    else
      right_linkage = root_linkages[:right]
      if right_linkage
        # recurse to the next depth with the left linkage as root
        search_tree_recurser(val, right_linkage, comparator)
      else
        root_linkages[:right] = val
        val_linkages[:parent] = root
      end
    end
    val
  end

  def insert_into_search_tree(val_to_add, &comparator)
    insert_into_search_tree_step(root_val, val_to_add, &comparator)
  end

  def insert_into_search_tree_step(root, val_to_add, &comparator)
    # helper 1
    recurse_fn = ->(direction) do
      insert_into_search_tree_step(
        root.linkages[direction], val_to_add, &comparator
      )
    end
    # helper 2
    do_insert_fn = ->(direction) do
      root.linkages[direction] = val_to_add
      val_to_add.linkages[:parent] = root
    end
    # helper 3
    recurse_or_insert_fn = ->(direction) do
      if root.linkages[direction]
        recurse_fn.call(direction)
      else
        do_insert_fn.call(direction)
      end
    end
    # meat of the matter
    if root_val
      if comparator.call(val_to_add, root)
        recurse_or_insert_fn.call :left
      else
        recurse_or_insert_fn.call :right
      end
    else
      root_val = val_to_add
      values = [root_val]
    end
    self.class.new(values: values, root_val: root_val)
  end

  def to_sorted_order
    values = depth_first_iteration([]) { |memo, val| memo.push val }
    self.class.new(values: values, root_val: root_val)
  end

  def to_original_order
    values = breadth_first_iteration([]) { |memo, val| memo.push val }
    self.class.new(values: values, root_val: root_val)
  end

  def depth_first_iteration(memo, &blk)
    depth_first_iteration_step root_val, memo, &blk
  end

  def depth_first_iteration_step(root, memo, &blk)
    left_linkage = root.linkages[:left]
    right_linkage = root.linkages[:right]
    if left_linkage
      depth_first_iteration_step(left_linkage, memo, &blk)
    end
    blk.call(memo, root)
    if right_linkage
      depth_first_iteration_step(right_linkage, memo, &blk)
    end
    memo    
  end

  def balance_tree(&comparator)
      sorted_list = to_sorted_order
      midpoint_idx = Math.floor(sorted_list.values.length / 2)
      midpoint = sorted_list.delete_at midpoint_idx
      new_tree = self.class.new
      new_tree.insert_into_search_tree(midpoint)
      sorted_list.each { |node| new_tree.insert_into_search_tree node }
      new_tree
  end

  def breadth_first_iteration(memo, &blk)
    blk.call(memo, root_val)
    nodes_queue = [root_val.linkages[:left], root_val.linkages[:right]]
    breadth_first_iteration_step(memo, nodes_queue, &blk) 
  end

  def breadth_first_iteration_step(memo, nodes_queue, &blk)
    return memo if nodes_queue.empty?
    nodes_queue.length.times do
      node = nodes_queue.shift
      blk.call(memo, node)
      next_nodes = [node.linkages[:left], node.linkages[:right]].compact
      nodes_queue.push(*next_nodes)
    end
    breadth_first_iteration_step(memo, nodes_queue, &blk)
  end

end

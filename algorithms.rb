# top level namespace
class ALGORITHMS; end

# builds a graph which can be passed to other searching algorithms
class ALGORITHMS::GRAPH_BUILDER
	# @param value_sets [Array<Array>]
    # each nested array is an any-length tuple which becomes a point in the graph
	def initialize(*value_sets)
		
	end
end

# searches for target in graph, optimizating horizontal distance covered
class ALGORITHMS::BREADTH_FIRST_SEARCH

end

# searches for target in graph, optimizating vertical distance covered
class ALGORITHMS::DEPTH_FIRST_SEARCH
end

class ALGORITHMS::DYKSTRAS_SEARCH
end

class ALGORITHMS::A_STAR_SEARCH
end


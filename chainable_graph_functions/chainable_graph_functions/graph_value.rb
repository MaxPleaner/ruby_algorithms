class CHAINABLE_GRAPH_FUNCTIONS::GRAPH_VALUE
  
  attr_reader :dimensions, :linkages
  
  # @keyword dimensions [Hash]
  # @keyword linkages [Hash]
  def initialize(dimensions: {}, linkages: {})
    @dimensions, @linkages = dimensions, linkages
  end

end

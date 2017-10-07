require_relative "../algorithms.rb"

GRAPH_VALUE = ALGORITHMS::GRAPH_VALUE
GRAPH_BUILDER = ALGORITHMS::GRAPH_BUILDER

RSpec.describe "ALGORITHMS" do

  describe "GRAPH_VALUE" do

    describe "#initialize" do

      it "saves the dimensions passed to it" do
        dimensions = { x: 0, y: 0, z: 0 }
        val = GRAPH_VALUE.new dimensions: dimensions
        expect(val.dimensions).to eq dimensions
      end

      it "saves the linkages passed to it" do
        linkages = {foo: "bar"}
        val = GRAPH_VALUE.new linkages: linkages
        expect(val.linkages).to eq linkages
      end

      it "sets linkages to an empty hash by default" do
        val = GRAPH_VALUE.new
        expect(val.linkages).to eq({})
      end

      it "sets dimensions to an empty hash by default" do
        val = GRAPH_VALUE.new
        expect(val.dimensions).to eq({})
      end

    end

  end

  describe "GRAPH_BUILDER" do

    let(:values) { 3.times.map { GRAPH_VALUE.new(dimensions: {x: 0}) } }

    describe "#initialize" do

      it "stores the passed :values" do
        graph = GRAPH_BUILDER.new(values: values)
        expect(graph.values).to eq values
      end

      it "stores the passed :root_val, :end_val" do
        root_val, end_val, parent = 3.times.map { {} }
        graph = GRAPH_BUILDER.new(root_val: root_val, end_val: end_val)
        expect(graph.root_val).to eq root_val
        expect(graph.end_val).to eq end_val
      end

    end

    describe "#singly_linked_list" do

      it "returns a new instance list containing the same elements" do
        graph = GRAPH_BUILDER.new(values: values)
        new_values = graph.singly_linked_list.values 
        expect(new_values).not_to be graph.values
        expect(new_values).to eq graph.values
      end
      
      it "sets the :next property on each value" do
        graph = GRAPH_BUILDER.new(values: values)
        singly_linked_list = graph.singly_linked_list
        singly_linked_list.values.in_groups_of(2).each do |(val1, val2)|
          expect(val1.linkages[:next]).to eq val2
        end
      end
      
      it "sets the :root_val property on the graph" do
        graph = GRAPH_BUILDER.new(values: values)
        expect(graph.singly_linked_list.root_val).to eq values[0]
      end
      
      it "sets the :end_val property on the graph" do
        graph = GRAPH_BUILDER.new(values: values)
        expect(graph.singly_linked_list.end_val).to eq values[-1]
      end
      
      it "calls the block (if given) for each pair of values" do
        graph = GRAPH_BUILDER.new(values: values)
        blk = -> (val1, val2) {}
        values.in_groups_of(2) do |(val1, val2)|
          expect(blk).to receive(:call).with(val1, val2)
        end
        graph.singly_linked_list(&blk)
      end

    end

    describe "#doubly_linked_list" do
      
      it "returns a new values list containing the same elements" do
        graph = GRAPH_BUILDER.new(values: values)
        new_values = graph.doubly_linked_list.values 
        expect(new_values).not_to be graph.values
        expect(new_values).to eq graph.values
      end

      it "sets the :next and :prev properties on each value" do
        graph = GRAPH_BUILDER.new(values: values)
        doubly_linked_list = graph.doubly_linked_list
        doubly_linked_list.values.in_groups_of(2).each do |(val1, val2)|
          expect(val1.linkages[:next]).to eq val2
          (expect(val2.linkages[:prev]).to eq val1) if val2
        end
      end
      
      it "calls the block (if given) for each pair of values" do
        graph = GRAPH_BUILDER.new(values: values)
        blk = -> (val1, val2) {}
        values.in_groups_of(2) do |(val1, val2)|
          expect(blk).to receive(:call).with(val1, val2)
        end
        graph.doubly_linked_list(&blk)
      end

      it "sets the :root_val property on the graph" do
        graph = GRAPH_BUILDER.new(values: values)
        expect(graph.doubly_linked_list.root_val).to eq values[0]
      end
      
      it "sets the :end_val property on the graph" do
        graph = GRAPH_BUILDER.new(values: values)
        expect(graph.doubly_linked_list.end_val).to eq values[-1]
      end
    
    end

    describe "#binary_search_tree" do

      it "returns a new values list containing the same elements" do
        graph = GRAPH_BUILDER.new(values: values)
        tree = graph.binary_search_tree(dimension: :x)
        expect(tree.values).not_to be values
        expect(tree.values).to eq values
      end

      it "sets the expected linkages" do
        values = [5,1,10,0,2,15,12,17].map do |num|
          GRAPH_VALUE.new(dimensions: {x: num})
        end
        graph = GRAPH_BUILDER.new(values: values)
        tree = graph.binary_search_tree(dimension: :x)
        # Visually it looks like this:
        #            5
        #           / \ 
        #          1   10
        #         / \    \
        #        0   2   15
        #                / \ 
        #               12  17
        #
        five, one, ten, zero, two, fifteen, twelve, seventeen = values
        # confirm root node
        expect(tree.root_val).to eq(five)
        expect(tree.root_val.linkages[:parent]).to be_nil
        # confirm :parent linkages
        expect_parent = ->(expected) do
          ->(node) { expect(node.linkages[:parent]).to eq expected }
        end
        [one,ten].each &expect_parent.call(five)
        [zero, two].each &expect_parent.call(one)
        [twelve, seventeen].each &expect_parent.call(fifteen)
        [fifteen].each &expect_parent.call(ten)

        # confirm :left and :right linkages
        expect(five.linkages[:left]).to eq(one)
        expect(five.linkages[:right]).to eq(ten)
        expect(one.linkages[:left]).to eq(zero)
        expect(one.linkages[:right]).to eq(two)
        expect(ten.linkages[:right]).to eq(fifteen)
        expect(fifteen.linkages[:left]).to eq(twelve)
        expect(fifteen.linkages[:right]).to eq(seventeen)
      end

    end

  end

end

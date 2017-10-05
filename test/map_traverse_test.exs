defmodule MapTraverseTest do
  use ExUnit.Case
  doctest MapTraverse

  defmodule TestTraverse do
    use MapTraverse, descendants_key: "nodes", id_key: "node_id"
  end

  setup do

    tree = %{
      "node_id" => 1,
      "text" => "this is node 1",
      "nodes" => [
        %{
          "node_id" => 2,
          "text" => "this is node 2",
          "condition" => "123",
          "nodes" => [
            %{
              "node_id" => 4,
              "text" => "this is node 5"
            },
            %{
              "node_id" => 5,
              "text" => "this is node 6"
            }
          ]
        },
        %{
          "node_id" => 3,
          "text" => "this is node 3",
          "condition" => "abc",
          "nodes" => [
            %{
              "node_id" => 6,
              "text" => "this is node 6"
            },
            %{
              "node_id" => 7,
              "text" => "this is node 7"
            }
          ]
        },
        %{
          "node_id" => 8,
          "text" => "this is node 8 (default)",
          "condition" => "[default]",
        }
      ]
    }

    {:ok, tree: tree}
  end

  test "find can return top level node", %{tree: tree} do
    node = TestTraverse.find(tree, "node_id", 1)
    assert node["text"] == "this is node 1"
    assert node["nodes"] |> Enum.count == 3
  end

  test "find can return second-level nested node", %{tree: tree} do
    node = TestTraverse.find(tree, "node_id", 3)
    assert node["text"] == "this is node 3"
    assert node["nodes"] |> Enum.count == 2
  end

  test "find can return third-level nested node", %{tree: tree} do
    node = TestTraverse.find(tree, "node_id", 6)
    assert node["text"] == "this is node 6"
  end

  test "find can return node based on a condition", %{tree: tree} do
    node = TestTraverse.find(tree, "condition", "123")
    assert node["text"] == "this is node 2"
  end

  test "find can be chained to return a nested result", %{tree: tree} do
    node = TestTraverse.find(tree, "node_id", 1) |> TestTraverse.find("condition", "abc")
    assert node["text"] == "this is node 3"
    assert node["nodes"] |> Enum.count == 2
  end

  test "find_child will return a direct descendent of the tree passed in if it exists", %{tree: tree} do
    node = TestTraverse.find_child(tree, "condition", "abc")
    assert node["text"] == "this is node 3"
  end

  test "find_child will return nil if a direct descendent of the tree passed in doesn't exist", %{tree: tree} do
    node = TestTraverse.find_child(tree, "condition", "wasd")
    assert node == nil
  end
end

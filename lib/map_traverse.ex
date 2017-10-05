defmodule MapTraverse do
  @moduledoc """
  Documentation for MapTraverse.
  """

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @id_key opts[:id_key]
      @descendants_key opts[:descendants_key]
    
      def find(map, key, value) do
        map
        |> walk(key, value)
        |> return_result
      end
    
      def find_child(map, key, value) do
        map[@descendants_key]
        |> Enum.find(fn(x) ->
          x |> Map.get(key) == value
        end)
      end
      
      defp walk(nil, _, _), do: nil
      defp walk(node, key, value) when is_map(node) do
        case node |> Map.get(key)  do
          ^value ->
            node
          _ ->
            node[@descendants_key]
            |> walk(key, value)
        end
      end
      defp walk(nodes, key, value) when is_list(nodes) do
        nodes
        |> Enum.map(fn(node) -> 
          find(node, key, value)
        end)
      end
    
      defp return_result(nil), do: nil
      defp return_result(value) when is_list(value) do
        value
        |> List.flatten
        |> Enum.filter(fn(x) -> not is_nil(x) end)
        |> List.first
      end
      defp return_result(value), do: value
    end
  end

end

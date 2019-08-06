defmodule Kitsune.Aws.ResponseParser do
  require Record

  Record.defrecord :xmlElement, Record.extract(:xmlElement, from_lib: "xmerl/include/xmerl.hrl")
  Record.defrecord :xmlText,    Record.extract(:xmlText, from_lib: "xmerl/include/xmerl.hrl")

  def parse_document(document_string) do
    {doc, _} = document_string |> :binary.bin_to_list |> :xmerl_scan.string

    doc
  end

  def find_node(doc, xpath) do
    :xmerl_xpath.string(xpath, doc)
      |> Enum.map(fn(element) ->
        parse_node(xmlElement(element, :content))
      end)
  end

  def parse_node(xml_node) do
    cond do
      Record.is_record(xml_node, :xmlElement) ->
        name    = xmlElement(xml_node, :name) |> to_string
        content = xmlElement(xml_node, :content)
        Map.put(%{}, name, parse_node(content))

      Record.is_record(xml_node, :xmlText) ->
        xmlText(xml_node, :value) |> to_string

      is_list(xml_node) ->
        case Enum.map(xml_node, &(parse_node(&1))) do
          [text_content] when is_binary(text_content) ->
            text_content

          elements ->
            Enum.reduce(elements, %{}, fn(x, acc) ->
              if is_map(x) do
                Map.merge(acc, x)
              else
                acc
              end
            end)
        end

      true -> "Not supported to parse #{inspect xml_node}"
    end
  end

end

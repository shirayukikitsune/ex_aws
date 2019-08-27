defmodule Kitsune.Aws.Sqs.Message do
  defstruct message_id: nil,
    receipt_handle: nil,
    md5_of_body: nil,
    body: nil,
    attributes: []
end

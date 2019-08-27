defmodule Kitsune.Aws.Exception do
  def verify_response(response) do
    if response["Error"], do: raise Kitsune.Aws.SdkException, code: response["Error"]["Code"], type: response["Error"]["Type"], description: response["Error"]["Message"]
    response
  end
end

defmodule Kitsune.Aws.SdkException do
  defexception [:code, :type, :description]

  @impl true
  def message(%{code: code, type: type}) do
    "AWS SDK Error Type #{type} with code #{code}"
  end
end

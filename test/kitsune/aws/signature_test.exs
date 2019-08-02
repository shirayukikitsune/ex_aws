defmodule Kitsune.Aws.SignatureTest do
  use ExUnit.Case
  doctest Kitsune.Aws.Signature
  alias Kitsune.Aws.Signature

  @secret_key "wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY"
  @date_stamp ~D[2012-02-15]
  @region_name "us-east-1"
  @service_name "iam"

  test "should generate a valid date key" do
    date_key = Signature.get_date_key(@secret_key, @date_stamp)
               |> key_to_string

    assert date_key == "969fbb94feb542b71ede6f87fe4d5fa29c789342b0f407474670f0c2489e0a0d"
  end

  test "should generate a valid region key" do
    region_key = Signature.get_date_key(@secret_key, @date_stamp)
                 |> Signature.get_region_key(@region_name)
                 |> key_to_string

    assert region_key == "69daa0209cd9c5ff5c8ced464a696fd4252e981430b10e3d3fd8e2f197d7a70c"
  end

  test "should generate a valid service key" do
    service_key = Signature.get_date_key(@secret_key, @date_stamp)
                  |> Signature.get_region_key(@region_name)
                  |> Signature.get_service_key(@service_name)
                  |> key_to_string

    assert service_key == "f72cfd46f26bc4643f06a11eabb6c0ba18780c19a8da0c31ace671265e3c87fa"
  end

  test "should generate a valid signing key" do
    signing_key = Signature.get_date_key(@secret_key, @date_stamp)
                  |> Signature.get_region_key(@region_name)
                  |> Signature.get_service_key(@service_name)
                  |> Signature.get_signing_key
                  |> key_to_string

    assert signing_key == "f4780e2d9f65fa895f9c67b32ce1baf0b0d8a43505a000a1a9e090d414db404d"
  end

  test "should generate a valid signing key/4" do
    signing_key = Signature.get_signing_key(@secret_key, @region_name, @service_name, @date_stamp)
                  |> key_to_string

    assert signing_key == "f4780e2d9f65fa895f9c67b32ce1baf0b0d8a43505a000a1a9e090d414db404d"
  end

  test "should generate a valid credential scope" do
    assert Signature.get_credential_scope(~D[2015-08-30], "us-east-1", "iam") == "20150830/us-east-1/iam/aws4_request"
  end

  test "should generate a valid string to sign" do
    assert Signature.get_string_to_sign(~U[2015-08-30T12:36:00Z], "20150830/us-east-1/iam/aws4_request", "f536975d06c0309214f805bb90ccff089219ecd68b2577efef23edd43b7e1a59") <> "\n" === ~S"""
AWS4-HMAC-SHA256
20150830T123600Z
20150830/us-east-1/iam/aws4_request
f536975d06c0309214f805bb90ccff089219ecd68b2577efef23edd43b7e1a59
"""
  end

  defp key_to_string(signature), do: signature |> Base.encode16 |> String.downcase
end

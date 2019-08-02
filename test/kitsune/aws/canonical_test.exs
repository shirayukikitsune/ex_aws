defmodule Kitsune.Aws.CanonicalTest do
  use ExUnit.Case
  doctest Kitsune.Aws.Canonical
  alias Kitsune.Aws.Canonical

  test "should generate a canonical method string" do
    assert Canonical.get_canonical_method("GET") == "GET"
    assert Canonical.get_canonical_method("post") == "POST"
    assert Canonical.get_canonical_method("Put") == "PUT"
  end

  test "should generate a canonical URI" do
    assert Canonical.get_canonical_uri("http://google.com") == "/"
    assert Canonical.get_canonical_uri("http://google.com/") == "/"
    assert Canonical.get_canonical_uri("http://s3.amazonaws.com/examplebucket/myphoto.jpg") == "/examplebucket/myphoto.jpg"
  end

  test "should generate a canonical query string" do
    assert Canonical.get_canonical_query_string("http://google.com") == ""
    assert Canonical.get_canonical_query_string("http://s3.amazonaws.com/examplebucket?prefix=somePrefix&marker=someMarker&max-keys=20") == "marker=someMarker&max-keys=20&prefix=somePrefix"
    assert Canonical.get_canonical_query_string("http://s3.amazonaws.com/examplebucket?acl") == "acl="
  end

  test "should generate a canonical header string" do
    assert Canonical.get_canonical_headers([{"a", "123"}, {"Accept", "application/json"}, {"Content-Type", "application/json"}]) == "a:123\naccept:application/json\ncontent-type:application/json"
  end

  test "should generate a signed headers string" do
    assert Canonical.get_signed_headers([{"a", "123"}, {"Accept", "application/json"}, {"Content-Type", "application/json"}]) == "a;accept;content-type"
  end

  test "should generate valid payload hashes" do
    assert Canonical.get_payload_hash("") == "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
    assert Canonical.get_payload_hash("Welcome to Amazon S3.") == "44ce7dd67c959e0d3524ffac1771dfbba87d2b6b4b4e99e42034a8b803f8b072"
  end

  test "should generate a valid canonical request string 1" do
    request = Canonical.get_canonical_request("GET", "http://examplebucket.s3.amazonaws.com/test.txt", [{"x-amz-date", "20130524T000000Z"}, {"Range"," bytes=0-9"}, {"x-amz-content-sha256","e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"}, {"x-amz-date", "20130524T000000Z"}], "")
    assert (request <> "\n") == ~S"""
GET
/test.txt

host:examplebucket.s3.amazonaws.com
range:bytes=0-9
x-amz-content-sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
x-amz-date:20130524T000000Z

host;range;x-amz-content-sha256;x-amz-date
e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
"""
  end

  test "should generate a valid canonical request string 2" do
    request = Canonical.get_canonical_request("PUT", "http://examplebucket.s3.amazonaws.com/test$file.text", [{"Date", "Fri, 24 May 2013 00:00:00 GMT"}, {"x-amz-date"," 20130524T000000Z"}, {"x-amz-storage-class","REDUCED_REDUNDANCY"}, {"x-amz-content-sha256", "44ce7dd67c959e0d3524ffac1771dfbba87d2b6b4b4e99e42034a8b803f8b072"}], "Welcome to Amazon S3.")
    assert (request <> "\n") == ~S"""
PUT
/test%24file.text

date:Fri, 24 May 2013 00:00:00 GMT
host:examplebucket.s3.amazonaws.com
x-amz-content-sha256:44ce7dd67c959e0d3524ffac1771dfbba87d2b6b4b4e99e42034a8b803f8b072
x-amz-date:20130524T000000Z
x-amz-storage-class:REDUCED_REDUNDANCY

date;host;x-amz-content-sha256;x-amz-date;x-amz-storage-class
44ce7dd67c959e0d3524ffac1771dfbba87d2b6b4b4e99e42034a8b803f8b072
"""
  end
end

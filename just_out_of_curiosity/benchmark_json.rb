require 'json'
require 'benchmark/ips'

obj = { name: "John \"Doe\"", message: "Hello\nWorld!", city: "New York" }

obj_without_escape = { name: "JohnDoe", age: 30, city: "NewYork" }
# This object has no spaces or special characters that require escaping in JSON.

Benchmark.ips do |x|
  x.report("obj.to_json") { obj.to_json }
  x.report("obj.to_json nothing to escape") { obj_without_escape.to_json }
  x.compare!
end

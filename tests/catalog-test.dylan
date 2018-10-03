Module: pacman-test

define constant $catalog-text =
  #str:({
    "__catalog_attributes": {"unused": "for now"},
    "http": {
      "contact": "zippy",
      "description": "foo",
      "license-type": "MIT",
      "synopsis": "HTTP server and client",
      "category": "network",
      "keywords": [ "http" ],
      "versions": {
        "1.0.0": {
          "deps": [ "uri/4.0.9", "opendylan/2014.2.2" ],
          "source-url": "https://github.com/dylan-lang/http"
        },
        "2.10.0": {
          "deps": [ "strings/2.3.4", "uri/6.1.0", "opendylan/2018.0.2" ],
          "source-url": "https://github.com/dylan-lang/http"
        }
      }
    },
    "json": {
      "contact": "me@mine",
      "description": "bar",
      "license-type": "BSD",
      "synopsis": "json parser/serializer",
      "category": "encoding",
      "keywords": [ "parser", "config", "serialize" ],
      "versions": {
        "1.0.0": {
          "deps": [ "opendylan/2014.1.0" ],
          "source-url": "https://github.com/dylan-lang/json"
        },
        "3.1234.100": {
          "deps": [ "strings/3.4.5", "opendylan/2018.8.8" ],
          "source-url": "https://github.com/dylan-lang/json"
        }
      }
    }
  });

define function get-test-catalog () => (_ :: <catalog>)
  with-input-from-string (in = $catalog-text)
    read-json-catalog(in /* table-class: <ordered-string-table> */)
  end
end;

define test test-catalog ()
  // Okay, this is a shitty test, but what can I do?  We don't have an
  // <ordered-dict> class, which would allow me to write the json back
  // out to a string in a predictable way, remove whitespace, and then
  // diff. We don't have an object differ. So for now I'll just spot
  // check a few values.
/*
  let text = with-output-to-string (out)
               write-json-catalog(cat1, out)
             end;
  let orig-stripped = choose(complement(whitespace?), $catalog-text);
  let text-stripped = choose(complement(whitespace?), text);
  assert-equal(orig-stripped, text-stripped);
*/
  let cat = get-test-catalog();
  assert-equal(#["http", "json"], sort(key-sequence(cat.package-map)));
  let http = %find-package(cat, "http", string-to-version("2.10.0"));
  assert-true(http);
  assert-equal("MIT", http.license-type);
  assert-equal("opendylan", http.dependencies[2].package-name);
end;

define test test-find-latest-version ()
  let cat = get-test-catalog();
  let json = %find-package(cat, "json", $latest);
  assert-true(json);
  assert-equal("3.1234.100", version-to-string(json.version));
end;

define test test-validate-dependencies ()
  // needs more...
  assert-signals(<catalog-error>, validate-catalog(get-test-catalog()));
end;

define suite catalog-suite ()
  test test-catalog;
  test test-find-latest-version;
  test test-validate-dependencies;
end;

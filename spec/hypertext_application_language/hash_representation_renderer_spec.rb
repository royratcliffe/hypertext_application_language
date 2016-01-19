describe HypertextApplicationLanguage::HashRepresentationRenderer do
  let(:renderer) { described_class.new }

  it 'renders a representation' do
    representation = HypertextApplicationLanguage::Representation.new
    representation.with_namespace('ns', 'http://localhost:9292/{rel}')
    representation.with_link(HypertextApplicationLanguage::Link::SELF_REL, 'http://localhost:9292/self')
    representation.with_property('value', 123)
    representation.with_property('array', [1, 2, 3])
    embedded = HypertextApplicationLanguage::Representation.new
    embedded.with_property('hello', 'world')
    embedded.with_link(HypertextApplicationLanguage::Link::SELF_REL, 'http://localhost:9292/sub')
    representation.with_representation('sub', embedded)
    expect(renderer.render(representation)).to eq(JSON.parse(<<-EXPECTED))
      {
        "_links": {
          "curies": {
            "href": "http://localhost:9292/{rel}",
            "name": "ns"
          },
          "self": {
            "href": "http://localhost:9292/self"
          }
        },
        "value": 123,
        "array": [
          1,
          2,
          3
        ],
        "_embedded": {
          "sub": {
            "_links": {
              "self": {
                "href": "http://localhost:9292/sub"
              }
            },
            "hello": "world"
          }
        }
      }
    EXPECTED
  end
end

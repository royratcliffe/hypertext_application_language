describe HypertextApplicationLanguage::Representation do
  let(:representation) { described_class.new }

  it 'retains links' do
    expect(representation.links).to be_empty
    representation.with_link(HypertextApplicationLanguage::Link::SELF_REL, 'http://localhost/rel/1')
    expect(representation.links).not_to be_empty
  end
end

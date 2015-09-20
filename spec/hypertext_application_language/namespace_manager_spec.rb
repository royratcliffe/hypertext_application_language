describe HypertextApplicationLanguage::NamespaceManager do
  let(:manager) { described_class.new }

  it 'initializes' do
    expect(manager).not_to be_nil
    expect(manager.namespaces).to be_empty
    expect(manager.namespaces.length).to eq(0)

    namespaces = manager.namespaces
    namespaces['name'] = 'href'
    expect(manager.namespaces.length).to eq(0)
  end

  it 'loads with namespaces' do
    expect(manager.namespaces.length).to eq(0)
    manager.with_namespace('name', 'http://localhost/' + described_class::REL)
    expect(manager.namespaces['name']).to eq('http://localhost/{rel}')
    expect(manager.namespaces.length).to eq(1)
  end

  let(:ns_manager) { manager.with_namespace('ns', 'http://localhost/{rel}/to') }

  it 'answers curie for href' do
    expect(ns_manager.curie('http://localhost/path/to')).to eq('ns:path')
  end

  it 'answers nil when no matching href' do
    expect(ns_manager.curie('http://localhost:8080/to')).to be_nil
  end

  it 'answers href for curie' do
    expect(ns_manager.href('ns:arg')).to eq('http://localhost/arg/to')
  end

  it 'answers nil when no matching curie' do
    expect(ns_manager.href('n$:arg')).to be_nil
  end
end

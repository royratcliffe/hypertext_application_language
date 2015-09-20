describe HypertextApplicationLanguage::Link do
  let(:link) { described_class.new('rel', '/path') }

  it 'initializes' do
    expect(link.rel).to eq('rel')
    expect(link.href).to eq('/path')

    other_link = described_class.new('other_rel', '/other_path', name: 'other_name')
    expect(other_link.name).to eq('other_name')
  end

  it 'mutates' do
    link.rel = 'otherRel'
    expect(link.rel).to eq('otherRel')
  end

  it 'freezes' do
    link.freeze
    expect do
      link.rel = 'frozenRel'
    end.to raise_error(RuntimeError)
  end

  it 'freezes attributes' do
    link.freeze
    expect do
      link.rel.prepend('other_')
    end.to raise_error(RuntimeError)
  end
end

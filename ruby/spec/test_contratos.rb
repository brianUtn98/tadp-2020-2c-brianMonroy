describe Prueba do
  let(:contrato) { Contrato.new }

  describe '' do
    it '' do
      expect(contrato.get_property(:energia)).to raise_error(PropertyNotFound)
    end

    it '' do
      contracto.set_property(:id, 100)
      expect(contrato.id).to eq 100
      expect(contrato.respond_to?(:id)).to be(true)
    end

    it '' do
      contrato.set_property(:saludar, proc {'hola'})
      expect(contrato.saludar).to eq('hola')
    end

    it '' do
      contrato1.set_property(:nombre, 'Pepe')
      contrato1.set_property(:saludar, proc do |nombre_saludador| "Hola #{nombre_saludador}, soy #{nombre}"end)
      expect(contrato.saludar('Juan')).to eq('Hola Juan, soy Pepe')
    end
  end
end

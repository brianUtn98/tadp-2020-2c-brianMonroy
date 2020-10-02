# frozen_string_literal: true
require 'rspec'
require_relative '../lib/pila'

describe 'Contratos' do
  before do
    @pepita = Golondrina.new 100
  end

  describe 'contratos con pepita' do
    it 'pepita no puede volar mas de lo que su energia le permite' do
      expect(@pepita.volar(200)).to raise_error(Exception)
    end
  end
end



# frozen_string_literal: true
require 'rspec'
require_relative '../lib/contract_framework'
#
# describe 'Contratos' do
#   before do
#     pila = Pila.new 2
#     pila.push 1
#     pila.push 2
#    end
#
#   describe 'contratos en la pila' do
#     it 'la pila no puede agregar mas elementos que su capacidad' do
#       expect(pila.push 3).to raise("No se cumplio la pre-condicion")
#     end
#
#     it '' do
#       expect(3).eql? 3
#     end
#   end
# end

describe 'Test contract_framework con la pila' do

  before do
    pila = Pila.new 2
    pila.push 1
    pila.push 2
  end

  # it 'la pila no deberia poder hacer push de un elemento si esta llena' do
  #   expect(pila.push 3).to raise "No se cumplio la pre-condicion"
  # end
  #
  it 'pruebita' do
    expect (3).eql? 3
  end

end



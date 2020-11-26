require_relative 'contract_framework'


module Contrato
  def self.included(base)
    base.extend(BeforeAndAfter)
  end
end


# class Class
#   include BeforeAndAfter
# end
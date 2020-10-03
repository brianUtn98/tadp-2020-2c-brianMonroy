module HookBeforeAfter

  def method_added(name)
    @methods ||= []
    return if @methods.include?(name)
    @methods << name

    meth = instance_method(name)

    @before_hook ||= proc { |_meth_name, *_args| raise 'No hook defined!' }
    @after_hook ||= proc { |_meth_name, *_args| raise 'No hook defined!' }

    before_hook = @before_hook
    after_hook = @after_hook

    define_method(name) do |*args, &block|
      before_hook.call(name, *args)

      result = meth.bind(self).call(*args, &block)

      after_hook.call(result)
    end
  end

  def before(&blk)
    @before_hook = blk
  end

  def after(&blk)
    @after_hook = blk
  end

  def before_and_after_each_call(before=proc{}, after=proc{})
    @before_hook = before
    @after_hook = after
  end
end


##################################################
# usage example
##################################################


# class Object
#   include HookBeforeAfter
# end

class MiClass
  extend HookBeforeAfter

  before do |name, *args|
    puts "===========Soy before ================"
    puts "Name: #{name}"
    puts "Arguments: #{args.join(', ')}"
    @start_time = Time.now
  end

  # Register an after method call hook
  after do |result|

    puts "===========Soy after ================"

    run_time = Time.now - @start_time
    puts "Result: #{result}"
    puts "Run Time: #{run_time} Seconds"
    result
  end

  # constructor
  def initialize(var)

    puts "Llammando a intitialize ##############"
    @var = var
  end

  # when methods gets defined they get redefined with the registered hooks above
  # Smashing this method between the before and after hooks.
  def greet(name)
    "Hello #{name}"
  end

  # it can even handle yields
  def call_back
    yield @var
  end

end


class A
  extend HookBeforeAfter


  # before {puts 'Soy before'}
  #
  # after {puts 'Soy after'}

  before_and_after_each_call(proc{puts 'before'},proc{puts 'after'})
  def saludar nombre
    puts "Hola #{nombre}"
  end


end




# obj = MiClass.new('my var')
#
#
# obj.greet('Slippers')
#
# obj.call_back do |var|
#   "This is my Var: #{var}"
# end
#
# obj.greet('Probando')
# obj.greet('123')
# obj.greet('sasdas')
# #
#  a = A.new
#  a.saludar "Brian"
#
module BeforeAndAfter
  @before = nil
  @after = nil
  class << self
    attr_accessor :before, :after
  end

  def before_and_after_each_call(before = proc {},after = proc {})
    @before = before
    @after = after
  end

  def self.method_added(sym)
    return if @working

    metodo_original = instance_method(method_name)

    @working = true
    proc_antes = @before
    proc_despues = @after
    define_method(sym) do
      proc_antes.call
      resultado = metodo_original.bind(self).call
      resultado
      self.class.send(:controlarInvariants,self)
      proc_despues.call
    end
    @working = false
  end

  def pre(&before)
    puts 'Definiendo pre'
    @before = proc {raise Error("No se cumple la pre-condicion") unless self.instance_eval(before) }
  end
  def post(&after)
    puts 'Definiendo post'
    @after = proc {raise Error("No se cumple la post-condicion") unless self.instance_eval(after) }
  end

  def invariant

  end
end

class Object
  include BeforeAndAfter
end

class Pila
  attr_accessor :current_node, :capacity

  invariant { capacity >= 0 }
  post { empty? }
  def initialize(capacity)
    @capacity = capacity
    @current_node = nil
  end

  pre { !full? }
  post { height.positive? }
  def push(element)
    @current_node = Node.new(element, current_node)
  end

  pre { !empty? }
  def pop
    element = top
    @current_node = @current_node.next_node
    element
  end

  pre { !empty? }
  def top
    current_node.element
  end

  def height
    empty? ? 0 : current_node.size
  end

  def empty?
    current_node.nil?
  end

  def full?
    height == capacity
  end

  Node = Struct.new(:element, :next_node) do
    def size
      next_node.nil? ? 1 : 1 + next_node.size
    end
  end
end
#
pila = Pila.new 2
pila.push 2
pila.push 3
pila.push 4

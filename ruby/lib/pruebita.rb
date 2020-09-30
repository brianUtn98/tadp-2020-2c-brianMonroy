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
end


##################################################
# usage example
##################################################

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


# obj = MiClass.new('my var')
#
#
# obj.greet('Slippers')
#
# obj.call_back do |var|
#   "This is my Var: #{var}"
# end
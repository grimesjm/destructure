require 'destructure/destructure'

module DestructureMagic
  def self.included(base)
    orig = base.instance_method(:=~)

    base.send(:define_method, :=~) do |pattern|
      if pattern.is_a?(Regexp)
        orig.bind(self).call(pattern)
      elsif pattern.is_a?(Proc)
        # stuff gets cranky if you try to factor this out
        caller_binding = binding.of_caller(1)
        caller_location = caller_locations(1,1)[0].label
        caller = caller_binding.eval('self')
        caller.class.send(:include, Destructure) unless caller.class.included_modules.include?(Destructure)
        caller.send(:dbind_internal, self, pattern.to_sexp(strip_enclosure: true, ignore_nested: true), caller_binding, caller_location)
      else
        super
      end
    end
  end
end

class Object; include DestructureMagic end
class String; include DestructureMagic end
class Symbol; include DestructureMagic end

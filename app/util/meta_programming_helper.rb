class MetaProgrammingHelper
  def safe_define_class(name, klass)
    name_parts = name.split("::").reject(&:empty?)
    demodulized_const_name = name_parts.pop
    parent_const = nil
    module_parts = []
    name_parts.each do |name_part|
      module_parts << name_part
      parent_const = safe_define_const(module_parts, Module.new, parent_const)
    end
    module_parts << demodulized_const_name
    safe_define_const(module_parts, klass, parent_const)
  end

  private

  def safe_define_const(parts, klass, parent_const)
    parent_const ||= Object
    name = parts.last
    path = parts.join("::")
    (parent_const.const_defined?(path) && parent_const.const_get(path)) || parent_const.const_set(name, klass)
  end
end

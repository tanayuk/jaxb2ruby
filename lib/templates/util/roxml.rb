UNSUPPORTED_TYPES = [:ID, :IDREF, :boolean, "String", "Object"]

def unsupported_type?(type)
  UNSUPPORTED_TYPES.include?(type)
end

def namespace_map(klass)
  ns = [klass.element].concat(klass.element.children).map { |e| e.namespace }.compact.uniq
  return unless ns.any?

  map = "xml_namespaces "
  map << ns.map { |e| sprintf('"%s" => "%s"', e.prefix, e) }.join(", ")
end

def type_name(node)
  name = unsupported_type?(node.type) ? "" : node.type.dup
  # May be an attribute node
  if node.respond_to?(:array?) && node.array?
    name.prepend "["
    name.concat  "]"
  end
  name
end

def accessor_name(node)
  name = ":#{node.accessor}"
  name << "?" if node.type == :boolean
  name
end

def initializer(children, indent = '')
  return if children.empty?

  initializers = []
  children.each do |e|
    if !e.array? && !unsupported_type?(e.type) && e.type != 'Integer' && e.type != 'Date' && e.required?
      initializers << "#{indent}  @#{e.accessor} = #{type_name(e)}.new\n"
    end
  end

  return if initializers.empty?

  result = "\n"
  result << "#{indent}def initialize\n"
  result << initializers.join('')
  result << "#{indent}end\n"
  result
end

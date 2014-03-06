require "scoped_attr_accessor"

# Monkeypatch all classes to allow private_attr_reader, protected_attr_accessor, etc.
class Object
  extend ScopedAttrAccessor
end

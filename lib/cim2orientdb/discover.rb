#
# cim2orientdb/lib/cim2orientdb/discover.rb
#
# Discover wbem infrastructure
#

require 'wbem'
require 'uri'

module CIM2OrientDB
  class Discover

    private

    # create class hierachy for objectpath or classname
    def create_class_hierachy op_or_cn
      cn = case op_or_cn
           when String
             op_or_cn # is a classname
           else
             begin
               op_or_cn.classname # is an objectpath
             rescue
               raise "Can't determine classname from #{objectpath}<#{objectpath.class}>"
             end
           end
      klass = @import.get_class(cn) # class exists
      puts "#{cn} => #{klass.inspect}"
      return if klass
      mof = @mof.get cn
      raise "Cannot find MOF for #{cn}" unless mof

      create_class_hierachy mof.superclass if mof.superclass
      puts "Create! #{cn}"
      klass = @import.create_class mof
#      puts "Created #{cn} as #{klass}"
      klass
    end
    # import instance
    # create class hierachy
    def import_instance inst
      klass = inst.classname
      create_class_hierachy inst.object_path
      @import.save inst
    end
    
    def import_associations inst, from
      @wbem.each_association inst.object_path do |assoc|
        puts "Assoc #{assoc.class}"
        to = import_instance assoc
        @import.create_edge from, to
#        import_associations assoc, to
      end
    end

    public

    def initialize client, uri, includes = []
      @import = Importer.new client
      @mof = Mof.new includes
      @uri = URI.parse uri
      @wbem = Wbem::Client.connect(@uri)
      puts "Discover client: #{@wbem}"
      if @uri.path =~ %r{/((\w+/)+\w+)(:(\w+_\w+))?}
        @ns = $1
        @cimclass = $4
        discover @ns, @cimclass
      else
        puts "Namespace ? Class ?"
      end
    end # initialize

      # enumerate instances
      # enumerate associations
      # recurse
    def discover ns, cimclass
      puts "Discover start at #{ns}:#{cimclass}"
      @wbem.each_instance(ns, cimclass) do |inst|
        puts "Instance: #{inst}"
        from = import_instance inst
        puts "#{inst} saved as #{from}"
        import_associations inst, from
      end
    end
  end
end

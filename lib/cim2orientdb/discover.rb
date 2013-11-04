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
      return if @import.get_class(cn) # class exists
      mof = @mof.get cn
      raise "Cannot find MOF for #{cn}" unless mof
      puts "Found #{cn}"
      if mof.superclass
        return create_class_hierachy mof.superclass
      else
        @import.create_class mof
      end
    end
    # import instance
    # create class hierachy
    def import_instance inst
      klass = inst.classname      
      create_class_hierachy inst.object_path
      @import.save inst
    end
    
    def import_association from, to
      vertex = import_instance to
      @import.create_edge from, to
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
        @wbem.each_association inst do |assoc|
          import_association from, assoc
        end
      end
    end
  end
end

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
    # create class hierachy
    def create_class_hierachy objectpath
      return if @import.get_class(objectpath.classname) # class exists
      cimclass = @wbem.get_class objectpath
      if cimclass.superclass
        return create_class_hierachy cimclass.superclass
      else
        @import.create_class cimclass
      end
    end
    # import instance
    # create class hierachy
    def import_instance inst
      klass = inst.classname      
      create_class_hierachy inst
      @import.save inst
    end
    
    def import_association from, to
      vertex = import_instance to
      @import.create_edge from, to
    end
    public
    def initialize client, uri, includes = []
      @import = Importer.new client, includes
      @uri = URI.parse uri
      @wbem = Wbem::Client.connect(@uri)
      puts "Discover #{@wbem}"
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
      puts "discover #{ns}:#{cimclass}"
      @wbem.each_instance(ns, cimclass) do |inst|
        puts "#{inst}"
        from = import_instance inst
        @wbem.each_association inst do |assoc|
          import_association from, assoc
        end
      end
    end
  end
end

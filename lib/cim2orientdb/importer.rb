#
# cim2orientdb/lib/cim2orientdb/importer.rb
#
# Importer of cim class structures as OrientDB classes
#

require 'mof'
require 'cim'

module CIM2OrientDB
  class Importer
    QUALIFIERS = "/usr/share/cim/cim-current/qualifiers.cim"

    def initialize client, includes = []
      @client = client
      @includes = includes
    end # initialize

    # save instance (or objectpath)
    def save element
      puts "Import.save #{element}"
      # class hierachy
      create_class_hierachy element.class
      element.properties.each do |prop|
        # document
      end
    end
    
    # find and parse mof for klass
    def parse_mof_for klass
      return
      parser = MOF::Parser.new :style => :cim, :includes => @includes, :quiet => true
      result = parser.parse [ QUALIFIERS, filename ]
      result.each_value do |res|      # key: filename, value: result
        res.classes.each do |klass|
          @@classes[klass.name] = klass
        end
      end
    end

    # create class hierachy
    def get_class klass
      begin
        @client.get_class klass
      rescue Orientdb4r::NotFoundError
        # return nil
      end
    end
    
#      rescue
#        properties = Array.new
#        klass.properties.each do |prop|
#          { :property => "name", :type => :string, :notnull => true, :mandatory => true },
#          { :property => "scheme", :type => :string },
#          { :property => "superclass", :type => :string }
#        end
#        client.create_class klass, :extends => klass.superclass, :properties => properties
#      end
#    end
  end
end

#
# cim2orientdb/lib/cim2orientdb/importer.rb
#
# Importer of cim class structures as OrientDB classes
#

require 'mof'
require 'cim'

module CIM2OrientDB
  class Importer

    def initialize client
      @client = client
    end # initialize

    # find instance (or objectpath)
    def lookup element
#      puts "Import.lookup #{element}<#{element.class}>"
      # convert element keys to hash (for to_json)
      doc = Hash.new
      op = element.is_a?(Sfcc::Cim::Instance) ? element.object_path : element
      op.each_key do |name, value|
        doc[name] = value.to_s
      end
      begin
        @client.lookup element.classname, doc
      rescue Exception => e
        puts "lookup failed with #{e.class}:#{e}"
      end
    end
      
    # save instance (or objectpath)
    def save element
#      puts "Import.save #{element}<#{element.class}>"
      # convert element to hash (for to_json)
      doc = Hash.new
      op = element.is_a?(Sfcc::Cim::Instance) ? element.object_path : element
      op.each_key do |name, value|
        doc[name] = value.to_s
      end
      res = @client.lookup element.classname, doc
      return res if res
      element.each_property do |name, value|
        doc[name] = value.to_s
      end
      begin
        @client.insert element.classname, doc
      rescue Exception => e
        puts "insert failed with #{e.class}:#{e}"
      end
    end
    
    # create class hierachy
    def get_class klass
      begin
        @client.get_class klass
        true
      rescue Orientdb4r::NotFoundError
        nil
      end
    end
    
    def create_class mof
#      puts "create_class #{mof.name}"
      properties = Array.new
      mof.features.each do |prop|
        p = Hash.new
        p[:property] = prop.name
        if prop.key?
          p[:mandatory] = true 
          p[:notnull] = true
        end
        p[:type] = case prop.type.type
                   when :string
                     :string
                   when :uint64, :uint32, :uint16, :uint8
                     :decimal
                   when :sint64
                     :long
                   when :sint32
                     :integer
                   when :sint16
                     :short
                   when :sint8
                     :byte
                   when :dateTime
                     :datetime
                   when :boolean
                     :boolean
                   when :real32
                     :float
                   when :real64
                     :double
                   else
                     abort "Type #{prop.type} unsupported"
                   end
      end
      options = Hash.new
      options[:properties] = properties
      options[:extends] = mof.superclass ? mof.superclass : "V"
      options[:abstract] = true if mof.name =~ /^CIM_/
      begin
        return @client.create_class mof.name, options
      rescue Exception => e
        unless e.to_s =~ /already exists/
          puts "Class creation failed with #{e.class}:#{e}"
        end
      end
    end
    
    def create_edge from, to
#      puts "Importer.create_edge #{from.rid} -> #{to.rid}"
      @client.create_edge from, to
    end
  end
end

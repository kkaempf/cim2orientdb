#
# cim2orientdb/lib/cim2orientdb/mof.rb
#
# MOF finder and loader
#

require 'mof'
require 'cim'

module CIM2OrientDB
  class Mof
    private
    STDINC = "/usr/share/mof/cim-current"
    QUALIFIERS = STDINC + "/qualifiers.mof"

    #
    # CIM_ classes have one .mof per class
    #
    def recursive_find_in_dir mofname, dir
#      puts "recursive_find_in_dir #{mofname} in #{dir}"
      Dir.foreach(dir) do |fname|
        next if fname[0,1] == "."
        path = File.join(dir, fname)
        if File.directory?(path)
          try = recursive_find_in_dir mofname, path
          return try if try
        end
        if fname == mofname
          return path
        end
      end
    end

    public
    def initialize includes=[]
      @cache = Hash.new # map class names to .mof names
      @includes = includes
    end

    #
    # provider .mofs have multiple classes per .mof
    #
    # parse all .mof files below dir
    def recursive_parse dir
      moffiles = Array.new
      Dir.foreach(dir) do |fname|
        next if fname[0,1] == "."
        path = File.join(dir, fname)
        if File.directory?(path)
          recursive_parse path
        else
          moffiles << path
        end
      end
      parse moffiles.sort
    end

    # parse mof file
    def parse path
      parser = MOF::Parser.new :style => :cim, :includes => @includes, :quiet => true
      result = parser.parse(path.is_a?(Array) ? [ QUALIFIERS ] + path : [ QUALIFIERS, path ] )
      result.each_value do |res|      # key: filename, value: result
        res.classes.each do |klass|
          @cache[klass.name] = klass
        end
      end
    end
    # get mof for classname
    def get classname
      mof = @cache[classname]
      return mof if mof
      if classname =~ /^CIM_/
        path = recursive_find_in_dir "#{classname}.mof", STDINC
        parse path if path
      else
        @includes.each do |inc|
          mof = recursive_parse inc
        end
      end
      @cache[classname]
    end

  end
end

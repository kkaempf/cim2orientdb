#
# cim2orientdb/lib/cim2orientdb/options.rb
#
# Extract ARGV options
#

require 'getoptlong'
require 'uri'

module CIM2OrientDB
  class Options
    attr_reader :target, :user, :password, :database, :includes, :clean

    def initialize
      @includes = Array.new
      @database = "cmdb"
      @user = "cmdb"
      @password = "susemanager"
      # Parse command line options
      GetoptLong.new(
        [ '-h', '--help', GetoptLong::NO_ARGUMENT ],
        [ '-H', '--man', GetoptLong::NO_ARGUMENT ],
        [ '-t', '--target', GetoptLong::REQUIRED_ARGUMENT ],
        [ '-u', '--user', GetoptLong::REQUIRED_ARGUMENT ],
        [ '-p', '--pass', '--password', GetoptLong::REQUIRED_ARGUMENT ],
        [ '-d', '--db', '--database', GetoptLong::REQUIRED_ARGUMENT ],
        [ '-I', '--include', GetoptLong::REQUIRED_ARGUMENT ],
        [ '-c', '--clean', GetoptLong::NO_ARGUMENT ]
      ).each do |opt, arg|
        case opt
        when '-t'
          @target = URI.new(arg)
        when '-u'
          @user = arg
        when '-p'
          @password = arg
        when '-d'
          @database = arg
        when '-I'
          @includes << arg
        when '-c'
          @clean = true
        else
          "Run $0 -h or $0 -H for details on usage";
        end
      end
      
      abort "Database missing: --db <name>" unless @database
      abort "Username missing: --user <name>" unless @user
      abort "Password missing: --pass <name>" unless @password
    end
  
  end
end

require 'enumerator'
require 'csv'
require 'pry'
require 'whois'
require_relative 'top_level_domain_names'

class FindMeName
  # a-z0-9

  TOP_LEVEL = ALL_DOMAINS
  def do_work(top_level_domain_name, first_twenty = nil)
    inputs = (0...36).map{ |i| i.to_s 36}

    names = inputs.repeated_combination(2).to_a  #=> [[aaa], [aab], [aac]]

    client = Whois::Client.new
    names = names.pop(20) if first_twenty
    names.each do |name|
      begin
        r = client.lookup("#{name.join}.#{top_level_domain_name}")
        sleep(5)
        write_data([r]) if r.available?
      rescue => e
        puts ("DERP-#{name.join}.#{top_level_domain_name}")
      end
    end
  end

  def do_mad_work
    TOP_LEVEL.each_slice(3) do |domains|
      threads = []
      domains.each do |domain|
        threads << Thread.new { do_work(domain) }
      end
      threads.each { |thr| thr.join }
    end
  end

  def write_data(data)
    CSV.open('results', 'a+') do |csv|
      csv << Array.wrap(data)
    end
  end
end


f = FindMeName.new
f.do_mad_work
#a.repeated_combination(4).to_a

# try 1
# w = Whois::Client.new
# names.each_slice(20) do |ss|
#   Whois::Client.new do |w|
#     name_slice.each do |name|
#       w.lookup("#{name.join}.com")
#     end
#   end
# end


# # try 2
# test = [
#  ["n", "u", "y"],
#  ["n", "u", "z"],
#  ["n", "v", "v"],
#  ["n", "v", "w"],
#  ["n", "v", "x"],
#  ["n", "v", "y"],
#  ["n", "v", "z"],
#  ["n", "w", "w"],
#  ["n", "w", "x"],
#  ["n", "w", "y"],
#  ["n", "w", "z"],
#  ["n", "x", "x"],
#  ["n", "x", "y"],
#  ["n", "x", "z"],
#  ["n", "y", "y"],
#  ["n", "y", "z"],
#  ["n", "z", "z"]
# ]

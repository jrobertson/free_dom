#!/usr/bin/env ruby

# file: free_dom.rb

require 'domle'
require 'line-tree'
require 'xml_to_sliml'


class Rexle::Element
  def to_sliml()

    xml = self.xml(pretty: true)
    XmlToSliml.new(xml.gsub(/ style=''/,"")).to_s
    
  end
end

class FreeDom < Domle

  def initialize(s, debug: false)

    @debug = debug

    xml = s =~ /^</ ? s : LineTree.new(s).to_xml
    @doc = Rexle.new(xml)

    h = {}

    @doc.root.each_recursive do |e|
      
      h[e.name.to_sym] ||= {}

      # if there's a custom attribute, add a default trigger called trigger_change
      a = e.attributes.keys.reject {|x| %i(id name class style).include? x }
      e.attributes.merge!({trigger_change: a.first}) if a.any?
      
      # add a trigger attribute for each *on* event attribute
      events = e.attributes.keys.select {|x| x =~ /^on/}\
          .map {|x| 'trigger_' + x.to_s[/(?<=^on)\w+/]}
      e.attributes.merge! events.zip(['']*events.length).to_h

      h[e.name.to_sym].merge!(e.attributes)
    end

    @defined_elements = {}

    h.each do |name, attributelist|

      klass = Class.new(Domle::Element) do

        a = attributelist.keys
        
        triggers = a.select {|x| x =~ /^trigger_/ }                  
        attr2_accessor *((a - triggers) + %i(onchange)).uniq
        
        triggers.each do |x|

          trigger = x.to_s[/(?<=^trigger_).*/].to_sym
          puts 'trigger: ' + trigger.inspect if @debug
          
          define_method(trigger)  do
            statement = method(('on' + trigger.to_s).to_sym).call
            eval statement, $env if statement
          end

          if trigger == :change then            
            
            attribute = attributelist[x].to_sym
            
            define_method((attribute.to_s + '=').to_sym) do |val|

              oldval = attributes[attribute]
              attributes[attribute] = val

              @rexle.refresh if @rexle
              change() unless val == oldval

              val
            end
            
          end
          
        end        

      end

      custom_class = FreeDom.const_set name.to_s.capitalize, klass
      @defined_elements.merge!({name => custom_class})

    end
    
    # remove the trigger declaration attributes
    @doc.root.each_recursive do |e|
      e.attributes.keys.select {|x| x =~ /^trigger_/ }\
          .each {|x| e.attributes.delete x }
    end

    super(@doc.root.xml, debug: @debug)        
    script()
                                     
  end
  
  
  # used within the scope of the script tags
  #
  def doc()
    self
  end
  
  def script()
    s = @doc.root.xpath('//script').map {|x| x.text.unescape }.join
    eval s
    $env = binding
  end                                      
  
  def to_sliml()

    xml = @doc.root.element('*').xml(pretty: true)
    puts 'xml: ' + xml.inspect if @debug
    XmlToSliml.new(xml.gsub(/ style=''/,"")).to_s
    
  end
                                    

  private
  
  def defined_elements()
    @defined_elements  
  end

end


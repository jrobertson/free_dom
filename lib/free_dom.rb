#!/usr/bin/env ruby

# file: free_dom.rb

require 'domle'


class FreeDom < Domle

  def initialize(xml, debug: false)

    @doc, @debug = Rexle.new(xml), debug

    h = {}

    @doc.root.each_recursive do |e|
      h[e.name.to_sym] ||= {}
      h[e.name.to_sym].merge!(e.attributes)
    end

    @defined_elements = {}

    h.each do |name, attributelist|

      klass = Class.new(Domle::Element) do

        a = attributelist.keys
        
        triggers = a.select {|x| x =~ /^trigger_/ }                
        
        attr2_accessor *(a - triggers)
        
        triggers.each do |x|

          trigger = x.to_s[/(?<=^trigger_).*/].to_sym
          puts 'trigger: ' + trigger.inspect if @debug
          
          define_method(trigger)  do
            eval method(('on' + trigger.to_s).to_sym).call, $env
          end

          if trigger == :change then
            
            #puts 'change found'
            
            attribute = attributelist[x].to_sym
            
            define_method((attribute.to_s + '=').to_sym) do |val|
              oldval = attributes[attribute]
              attributes[attribute] = val
              #puts 'inside change='
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

    super(@doc.root.xml)        
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
                                    

  private
  
  def defined_elements()
    @defined_elements  
  end

end

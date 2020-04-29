#!/usr/bin/env ruby

# file: free_dom.rb

require 'domle'


class FreeDom < Domle

  def initialize(xml)

    doc = Rexle.new xml

    h = {}

    doc.root.each_recursive do |e|
      h[e.name.to_sym] ||= {}
      h[e.name.to_sym].merge!(e.attributes)
    end

    @defined_elements = {}

    h.each do |name, attributes|

      klass = Class.new(Domle::Element) do

        attr2_accessor *attributes.keys

      end

      custom_class = FreeDom.const_set name.to_s.capitalize, klass
      @defined_elements.merge!({name => custom_class})

    end

    super(xml)
  end

  private
  
  def defined_elements()
    @defined_elements  
  end

end



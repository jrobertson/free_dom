# Introducing the Free_dom gem

    require 'free_dom'

    xml = "<home>
      <kitchen>
        <light switch='off'/>
      </kitchen>

      <porch>
        <doorentry>
          <button name='btn'></button>
        </doorentry>
        <door lock='locked'>
      </porch>

      <livingroom>
      </livingroom>
    </home>
    "

    doc = FreeDom.new(xml)

    e = doc.root.element('kitchen/light')
    e.switch = 'off'
    puts doc.to_sliml

<pre>
home
  kitchen
    light {switch: "off"}
  porch
    doorentry
      btn {name: "btn"}
    door {lock: "locked"}
  livingroom
</pre>

Note: A document in Sliml format can also be passed into this gem instead of XML.

## Resources

* free_dom https://rubygems.org/gems/free_dom

free_dom dom xml

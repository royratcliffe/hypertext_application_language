module HypertextApplicationLanguage
  # Renders a representation as a Hash.
  class HashRepresentationRenderer
    # Renders a representation to a Hash.
    # @return [Hash] The resulting Hash representation.
    def render(representation)
      render_representation(representation)
    end

    private

    # Renders either a top-level representation or an embedded resource.
    def render_representation(representation, embedded=false)
      object = {}

      # Render the name-spaces and links but only if there are name-spaces and
      # links; also render links if there are name-spaces to render, assuming
      # not embedded. Create a hash representation without links if there are
      # none. Merge the name-spaces and links.
      unless representation.links.empty? && (embedded || representation.namespaces.empty?)
        links_object = object[Representation::LINKS] ||= {}
        links = []
        unless embedded
          representation.namespaces.each do |name, ref|
            links.push(Link.new(Link::CURIES_REL, ref, Link::NAME => name))
          end
        end
        links.concat(representation.links)
        links_for_rel = {}
        links.each do |link|
          (links_for_rel[link.rel] ||= []).push(link)
        end
        links_for_rel.each do |rel, links|
          link_objects = links.map do |link|
            # Render a link as a hash. Importantly, the following does not
            # render the link relation; it only renders the link content. The
            # relation appears in the rendered output as the key, not as part of
            # the hash value paired with the key.
            link_object = {}

            # There is always a relation and a hypertext reference for every
            # link; no need to check for +nil+. If you set up a link with a
            # +nil+ reference, the output will contain a blank string, since
            # +nil.to_s+ answers +""+.
            link_object[Link::HREF] = link.href.to_s

            link_object[Link::NAME] = link.name.to_s if link.name
            link_object[Link::TITLE] = link.title.to_s if link.title
            link_object[Link::HREFLANG] = link.hreflang.to_s if link.hreflang
            link_object[Link::PROFILE] = link.profile.to_s if link.profile

            link_object
          end
          links_object[rel] = link_objects.length == 1 ? link_objects.first : link_objects
        end
      end

      # Merge the representation's properties. Properties live at the root of
      # the hash. Merging is just another way to assign values to their name
      # keys.
      #
      #   representation.properties.each do |name, value|
      #     hash[name] = value
      #   end
      #
      # This makes some assumptions about the representation properties. It
      # assumes that the property values are primitive types: strings, numbers,
      # booleans. They should never be hashes or custom classes.
      object.merge!(representation.properties)

      # Render embedded resource representations. Each representation retains
      # zero or more sub-representations by their relation. The relation maps to
      # an array of embedded representations, zero or more for each
      # relation. Render each one recursively.
      unless representation.representations.empty?
        embedded_object = object[Representation::EMBEDDED] ||= {}
        representation.representations_for_rel.each do |rel, representations|
          objects = representations.map do |representation|
            render_representation(representation, true)
          end
          embedded_object[rel] = objects.length == 1 ? objects.first : objects
        end
      end

      object
    end
  end
end

# coding: utf-8
module HypertextApplicationLanguage
  # An object that parses a representation.
  #
  # The parser does not “parse” the hash, strictly speaking. Nor does it check
  # the hash for strict compliance. Instead it just picks out pieces of the hash
  # matching HAL expectations. Nothing more than that.
  class HashRepresentationParser
    # Parses a hash, loading the given representation with its
    # hypertext-application-language content.
    def parse(representation, object)
      # Takes compact URI pairs from the links. Looks for the +curies+ sub-hash
      # within +_links+ root-level hash. Every CURIE is a hash with a name and a
      # hypertext reference.
      links_object = object[Representation::LINKS]
      if links_object
        curie_objects = links_object[Link::CURIES_REL]
        if curie_objects
          curie_objects = [curie_objects] unless curie_objects.is_a?(Array)
          curie_objects.select { |element| element.is_a?(Hash) }.each do |object|
            # Both the name and the hypertext reference must have string type;
            # there is no scope for representing references except using their
            # string form. Represent with strings, otherwise the parser ignores
            # it.
            #
            # The link's +href+ attribute carries the relative reference, even
            # though the reference is not a true hypertext reference since it
            # contains the +{rel}+ token as a placeholder for substitution.
            name = object[Link::NAME]
            next unless name.is_a?(String)
            ref = object[Link::HREF]
            next unless ref.is_a?(String)
            representation.with_namespace(name, ref)
          end
        end

        # The links object is a hash of strings paired with a hash or an array
        # of hashes.
        links_object.each do |rel, link_objects|
          next if rel == Link::CURIES_REL
          link_objects = [link_objects] unless link_objects.is_a?(Array)
          link_objects.each do |link_object|
            # Makes you wonder. Should the following pass the name? Doing so
            # allows name-spaces to sneak into the links. Name-spaces should
            # only appear in the +curies+ hash. They will never function as a
            # CURIE unless they do.
            href = object[Link::HREF]
            next unless href
            link = Link.new(rel, href)
            link.name = object[Link::NAME] if object[Link::NAME]
            link.title = object[Link::TITLE] if object[Link::TITLE]
            link.hreflang = object[Link::HREFLANG] if object[Link::HREFLANG]
            link.profile = object[Link::PROFILE] if object[Link::PROFILE]
            representation.with_link(link)
          end
        end
      end

      # Properties should only contain primitive types: string, numbers,
      # booleans or arrays of the same.
      object.each do |name, value|
        next if [Representation::LINKS, Representation::EMBEDDED].include?(name)
        # if value.is_a?(Array)
        #   representation.with_property(name, value.map(&:to_s))
        # else
        #   representation.with_property(name, value.to_s)
        # end
        representation.with_property(name, value)
      end

      embedded = object[Representation::EMBEDDED]
      if embedded
        embedded.each do |rel, objects|
          # The relation key must be a string. Turn the value into an array of
          # hashes, parsing an embedded representation from each hash.
          objects = [objects] unless objects.is_a?(Array)
          objects.each do |object|
            embedded_representation = Representation.new
            parse(embedded_representation, object)
            representation.with_representation(rel, embedded_representation)
          end
        end
      end
    end
  end
end

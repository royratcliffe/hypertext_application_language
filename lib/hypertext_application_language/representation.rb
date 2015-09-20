require 'hypertext_application_language/namespace_manager'
require 'hypertext_application_language/link'

module HypertextApplicationLanguage
  # Represents a resource. This includes sub-resources which also have their own
  # representation. Representations have links, properties and sub-resources.
  #
  # Resource is the name of a representation embedded within another
  # super-representation. Representations have zero or resources. They will
  # appear in the rendered results as embedded resources.
  class Representation
    LINKS = '_links'.freeze
    EMBEDDED = '_embedded'.freeze

    # Array of links.
    attr_accessor :links

    attr_accessor :properties

    # Hash of string-array pairs. The arrays contain embedded representations,
    # zero or more.
    attr_accessor :representations_for_rel

    def initialize
      @namespace_manager = NamespaceManager.new
      @links = []
      @properties = {}
      @representations_for_rel = {}
    end

    # @!group Namespaces

    def namespaces
      @namespace_manager.namespaces
    end

    def with_namespace(name, ref)
      @namespace_manager.with_namespace(name, ref)
      self
    end

    # @!group Links

    def link
      link_for(Representation::SELF_REL)
    end

    def link_for(href_or_rel)
      links_for(href_or_rel).first
    end

    # Answers the representation's links selected by either a hypertext
    # reference or by a relation.
    def links_for(href_or_rel)
      rel = @namespace_manager.curie(href_or_rel) || href_or_rel
      @links.select { |link| link.rel == rel }
    end

    # Adds a link to this representation.
    #
    # Ruby does not support argument overloading. If there is just one argument,
    # assume that it is a +Link+ instance. If not, if more than one argument,
    # assume that they are +String+ instances.
    def with_link(*args)
      @links.push(args.length == 1 ? args.first : Link.new(*args))
      self
    end

    # @!group Properties

    def value_for(name, default_value=nil)
      @properties[name] || default_value
    end

    def with_property(name, value)
      @properties[name] = value
      self
    end

    # @!group Representations

    # Takes the array values from the representations by relation, then flattens
    # the array of arrays of representations. The result becomes an array of
    # representations, all of them but without their relation to the
    # super-representation that having been stripped away.
    def representations
      @representations_for_rel.values.flatten
    end

    # Associates a given embedded representation with this representation by a
    # given relation.
    def with_representation(rel, representation)
      (@representations_for_rel[rel] ||= []).push(representation)
      self
    end
  end
end

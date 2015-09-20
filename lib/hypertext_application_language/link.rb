module HypertextApplicationLanguage
  # Links belong to representations; a representation retains zero or more
  # links. Each link gives a hypertext reference for a relation, at least. Some
  # links provide more information.
  #
  # Links have attributes. The relation and hypertext reference attributes are
  # primary and are always required for every link. Representations may carry
  # multiple links with the _same_ relation, just like a HTML page. Links
  # sharing the same relation refer to the same thing, or things.
  #
  # This is the simplest possible implementation of a
  # hypertext-application-language (HAL) link. It does not support
  # immutability. All links and their attributes remain mutable, even after
  # attaching to a representation. This condition continues until you freeze the
  # instance, according to the Ruby immutability paradigm.
  class Link
    # Creates a new mutable link.
    # @return [Link] Answers a newly initialised link.
    # @param [String] rel Relation.
    # @param [String] href Hypertext reference.
    # @param [Array<String, Hash>] args Array of strings used to initialise the
    #   optional attributes in the following order: +name+, +title+, +hreflang+
    #   and +profile+. If the last element is a Hash, these become keyword
    #   arguments where you can set up the optional link attributes by name,
    #   either symbolic or string.
    def initialize(rel, href, *args)
      @rel = rel
      @href = href

      # Take an array of arguments following the #rel and #href; these arguments
      # assign to the optional link attributes in order. Pick out keyword
      # arguments if the last argument is a #Hash. Be indifferent about the
      # keywords; accept both string and symbols. Do this by converting the
      # string keys to symbols if they do not otherwise match anything in the
      # keyword arguments hash. Take care not to re-invoke the hash fetch again
      # using the subscript operator, otherwise the default #Proc will recurse
      # indefinitely.
      keyword_args = args.last.is_a?(Hash) ? args.pop : {}
      keyword_args.default_proc = proc do |hash, key|
        hash.fetch(key.to_sym, nil)
      end
      @name, @title, @hreflang, @profile = args
      @name ||= keyword_args[NAME]
      @title ||= keyword_args[TITLE]
      @hreflang ||= keyword_args[HREFLANG]
      @profile ||= keyword_args[PROFILE]
    end

    # When you freeze the object, also freeze all the instance
    # variables. Otherwise, you can still modify the existing instance
    # variables' assigned objects even though you cannot reassign the variables
    # themselves.
    def freeze
      instance_variables.each do |instance_variable|
        instance_variable_get(instance_variable).freeze
      end
      super
    end

    # @!group Required attributes

    attr_accessor :rel

    # Link attribute describing the hypertext reference. The reference can be a
    # full universal resource location, or some element thereof. It can be just
    # the path.
    attr_accessor :href

    # @!group Optional attributes

    attr_accessor :name
    attr_accessor :title

    # Returns the ISO 639-1 code describing the link's language. You can have
    # multiple links for the same relation but for different languages.
    attr_accessor :hreflang

    attr_accessor :profile

    # @!group Required link attribute names

    REL = 'rel'.freeze
    HREF = 'href'.freeze

    # @!group Optional link attribute names

    NAME = 'name'.freeze
    TITLE = 'title'.freeze
    HREFLANG = 'hreflang'.freeze
    PROFILE = 'profile'.freeze

    # @!endgroup

    # Array of attribute names including those required and those optional.
    ATTRIBUTE_NAMES = [
      # required
      REL,
      HREF,

      # optional
      NAME,
      TITLE,
      HREFLANG,
      PROFILE,
    ].freeze

    # @!group Special link relations

    # This special link relation describes the link to the representations own
    # source, i.e. itself.
    SELF_REL = 'self'.freeze

    # Special link relation used for name-spaces. Representation name-spaces
    # appear in rendered links under the "curies" relation; where the link
    # +name+ corresponds to the name-space name and the link +href+ corresponds
    # to the name-space reference with its embedded +{rel}+ placeholder.
    CURIES_REL = 'curies'.freeze
  end
end

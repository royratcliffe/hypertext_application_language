module HypertextApplicationLanguage
  # Handles _compact_ URIs, a.k.a. CURIEs. Representations and representation
  # factories have CURIEs handled by a name-space manager instance.
  #
  # @see http://www.w3.org/TR/curie/
  class NamespaceManager
    # Defines the relative reference token, the placeholder used in CURIEs.
    REL = '{rel}'.freeze

    extend Forwardable

    # @return [Hash<String, String>] Answers a hash of relative references by
    # their name.
    def_delegator :@ref_for_name, :dup, :namespaces

    def initialize
      # Retains one relative hypertext reference for one name.
      @ref_for_name = {}
    end

    # Adds a name-space to this manager.
    # @param [String] name
    #   Names the CURIE. This appears in CURIE references as the prefix before
    #   the colon. The relative reference comes after the colon.
    # @param [String] ref
    #   Gives the CURIE's relative reference. It must include the +{rel}+
    #   placeholder identifying where to substitute the CURIE argument, the
    #   value that replaces the placeholder.
    def with_namespace(name, ref)
      @ref_for_name[name] = ref
      self
    end

    # Converts an expanded hypertext reference to a CURIE'd reference based on
    # the current set of CURIE specifications, the name-spaces.
    # @return [String] Answers the CURIE'd reference corresponding to the given
    # hypertext reference, or +nil+ if there is no matching CURIE.
    def curie(href)
      @ref_for_name.each do |name, ref|
        # start_index = ref.index(REL)
        # end_index = start_index + REL.length
        # left = ref[0...start_index]
        # right = ref[end_index..-1]
        # if href.start_with?(left) && href.end_with?(right)
        #   middle = href[start_index..(end_index - 2)]
        #   return name + ':' + middle
        # end
        left, right = ref.split(REL)
        if href.start_with?(left) && href.end_with?(right)
          return name + ':' + href[left.length...-right.length]
        end
      end
      nil
    end

    # Converts a CURIE'd reference to a hypertext reference.
    # @param [String] curie The argument is a string comprising a name prefix
    # followed by a colon delimiter, followed by a CURIE argument.
    #
    # Splits the name at the first colon. The prefix portion before the colon
    # identifies the name of the CURIE. The portion after the colon replaces the
    # +{rel}+ placeholder. This is a very basic way to parse a CURIE, but it
    # works.
    def href(curie)
      name, arg = curie.split(':', 2)
      ref = @ref_for_name[name]
      return nil unless ref
      ref.sub(REL, arg)
    end
  end
end

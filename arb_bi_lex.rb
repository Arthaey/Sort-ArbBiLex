# from active_support
class Object
  def blank?
    respond_to?(:empty?) ? empty? : !self
  end
end

# TODO: rename "major" => "families", "minor" => "glyph equivalencies",
# or something like that
module ArbBiLex
  @@debug = false

  def self.import(sort_function_name, sort_spec)
    # TODO: support arbitrary number of name/decl pairs (as hash pairs)
    if sort_function_name.blank? or sort_spec.blank?
      abort "Both name and sort-order spec are required."
    end

    # TODO: define method on approriate object
    self.class.send(:define_method, sort_function_name.to_sym, source_maker(sort_spec))
  end

  def self.maker
    # TODO
  end

  def self.source_maker(decl)
    one_level_mode = false

    # sanity-check declaration input
    if decl.is_a?(Array) # it's a rLoL declaration
      puts "rLOL-decl mode" if @@debug
      decl.each do |f|
        abort "Each family must be an array." unless f.is_a?(Array)
        abort "Family must not be empty." if f.empty?
        abort "Each glyph must be a string." unless f.all? { |x| x.is_a?(String) }
      end
    else # it's a string-style declaration
      # TODO: support string-style declarations
      puts "string-decl mode" if @@debug
    end

    # TODO: change it from a family of N glyphs into N families of one glyph each(?)

    # iterate thru the families and their glyphs and build the tables
    glyphs = []
    major_out = []
    minor_out = []
    max_glyph_length = 0;
    max_family_length = 0;
    seen = {}

    decl.each_with_index do |family, major|
      puts "Family #{major}" if @@debug
      max_family_length = family.length if family.length > max_family_length

      family.each_with_index do |glyph, minor|
        puts "  Glyph (#{major}):#{minor} (#{glyph})" if @@debug
        if seen[glyph]
          abort "Glyph <#{glyph}> appears twice in the sort order declaration!"
        end
        seen[glyph] = true
        max_glyph_length = glyph.length if glyph.length > max_glyph_length

        #glyph.gsub!(/([^a-zA-Z0-9])/) { |s| _char2esc(s) } # XXX
        glyphs << glyph
        major_out << _num2esc(major)
        minor_out << _num2esc(minor)
      end
    end

    # whether there is only one glyph per family
    one_level_mode = (max_family_length == 1)

    # TODO: optimize for special case of only single-character glyphs
    # TODO: timestamp generated code?

    major = {}
    minor = {}

    major_out.each_with_index do |m, i|
      major[glyphs[i]] = m
    end
    minor_out.each_with_index do |m, i|
      minor[glyphs[i]] = m
    end

    longest_glyphs_first = major.keys.sort { |a,b| b.length <=> a.length }
    glyph_re = /#{longest_glyphs_first.join("|")}/

    sort_method = lambda { |*unsorted|
      unsorted.sort_by do |s|
        [major_code(s, glyph_re, major),
         minor_code(s, glyph_re, minor)]
      end
    }

    sort_method
  end

  # maps each glyph in the string to its family's numeric value (its order in sort spec)
  #
  # TODO: rename by_family or something like that
  def self.major_code(s, glyph_re, major)
    matches = s.scan(glyph_re)
    matches.map { |match| major[match] }.join
  end

  # TODO: rename by_glyph_order_within_family or something like that
  def self.minor_code(s, glyph_re, minor)
    matches = s.scan(glyph_re)
    matches.map { |match| minor[match] }.join
  end

  def self._char2esc(str)
    ascii = str[0].ord
    _num2esc(ascii)
  end

  def self._num2esc(num)
    width = (num > 255 ? '' : '02')
    sprintf("\\x%#{width}x", num)
  end

  def self.xcmp
  end

  def self.xlt
  end

  def self.xgt
  end

  def self.xle
  end

  def self.xge
  end

end

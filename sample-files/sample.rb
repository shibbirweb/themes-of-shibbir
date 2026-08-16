# frozen_string_literal: true

# Ruby sample: modules, blocks, symbols, string interpolation, heredocs.

require 'json'
require 'set'

module Palette
  DEFAULT_HEX = '#EEFFFF'
  MAX_DEPTH = 8
  HEX_PATTERN = /\A#(?:\h{3}){1,2}\z/.freeze

  class InvalidHexError < StandardError
    def initialize(hex)
      super("Invalid hex value: #{hex.inspect}")
    end
  end

  module Describable
    def describe
      "#{label} => #{hex}"
    end

    def shout
      describe.upcase
    end
  end

  Swatch = Struct.new(:label, :hex, :tags, keyword_init: true) do
    include Describable

    def initialize(**args)
      super
      self.tags ||= []
      raise InvalidHexError, hex unless hex.match?(HEX_PATTERN)
    end

    def dark?
      luminance < 0.5
    end

    private

    def luminance
      red, green, blue = hex.delete('#').scan(/../).map { |part| part.to_i(16) }
      (0.2126 * red + 0.7152 * green + 0.0722 * blue) / 255.0
    end
  end

  class Registry
    include Enumerable

    attr_reader :name
    attr_accessor :strict

    def initialize(name, strict: false)
      @name = name
      @strict = strict
      @swatches = {}
    end

    def self.from_file(path)
      raw = JSON.parse(File.read(path), symbolize_names: true)
      registry = new(raw.fetch(:name, 'unnamed'))

      raw.fetch(:colors, {}).each do |label, hex|
        registry << Swatch.new(label: label.to_s, hex: hex)
      end

      registry
    end

    def <<(swatch)
      @swatches[swatch.label] = swatch
      self
    end

    def each(&block)
      @swatches.each_value(&block)
    end

    def [](label)
      @swatches[label]
    end

    def to_s
      <<~SUMMARY
        Registry: #{name}
        Swatches: #{@swatches.size}
        Strict:   #{strict ? 'yes' : 'no'}
      SUMMARY
    end
  end
end

registry = Palette::Registry.new('Themes of Shibbir', strict: true)
registry << Palette::Swatch.new(label: 'background', hex: '#263238', tags: %w[ui dark])
registry << Palette::Swatch.new(label: 'keyword', hex: '#C792EA')

dark, light = registry.partition(&:dark?)
labels = registry.map(&:label).sort
unique = Set.new(labels)

puts registry
puts "dark: #{dark.size}, light: #{light.size}, unique: #{unique.size}"

registry.each_with_index do |swatch, index|
  printf("%<index>2d. %<text>s\n", index: index + 1, text: swatch.describe)
rescue Palette::InvalidHexError => e
  warn e.message
end

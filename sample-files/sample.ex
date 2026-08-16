# Elixir sample: modules, pattern matching, pipes, structs, sigils.

defmodule Palette do
  @moduledoc """
  Module attributes and doc strings use their own scopes, so this block
  should render differently from the code below it.
  """

  @default_hex "#EEFFFF"
  @max_depth 8
  @hex_pattern ~r/^#(?:[0-9a-fA-F]{3}){1,2}$/

  defmodule Swatch do
    @moduledoc false

    @enforce_keys [:label]
    defstruct label: nil, hex: "#EEFFFF", tags: []

    @type t :: %__MODULE__{
            label: String.t(),
            hex: String.t(),
            tags: [String.t()]
          }
  end

  defmodule InvalidHexError do
    defexception [:hex]

    @impl true
    def message(%{hex: hex}), do: "Invalid hex value: #{inspect(hex)}"
  end

  @doc """
  Builds a swatch, raising when the hex is malformed.
  """
  @spec new(String.t(), String.t(), [String.t()]) :: Swatch.t()
  def new(label, hex \\ @default_hex, tags \\ []) do
    unless Regex.match?(@hex_pattern, hex) do
      raise InvalidHexError, hex: hex
    end

    %Swatch{label: label, hex: hex, tags: tags}
  end

  @spec luminance(String.t()) :: float()
  def luminance("#" <> rest) when byte_size(rest) == 6 do
    [red, green, blue] =
      rest
      |> String.upcase()
      |> String.graphemes()
      |> Enum.chunk_every(2)
      |> Enum.map(&(&1 |> Enum.join() |> String.to_integer(16)))

    (0.2126 * red + 0.7152 * green + 0.0722 * blue) / 255
  end

  def luminance(_other), do: -1.0

  def tone(hex) do
    case luminance(hex) do
      value when value < 0.0 -> :unknown
      value when value < 0.5 -> :dark
      _ -> :light
    end
  end

  def describe(%Swatch{label: label, hex: hex}) do
    "#{String.pad_trailing(label, 12)} => #{hex}"
  end

  def sorted_labels(swatches) do
    swatches
    |> Enum.reject(&(&1.hex == @default_hex))
    |> Enum.map(& &1.label)
    |> Enum.sort()
  end

  def summarize(swatches) do
    swatches
    |> Enum.group_by(&tone(&1.hex))
    |> Enum.map(fn {tone, group} -> {tone, length(group)} end)
    |> Enum.into(%{})
  end

  def max_depth, do: @max_depth
end

swatches = [
  Palette.new("background", "#263238", ~w(ui dark)),
  Palette.new("keyword", "#C792EA"),
  Palette.new("string", "#C3E88D")
]

for swatch <- swatches do
  value = Palette.luminance(swatch.hex)
  IO.puts("#{Palette.describe(swatch)}  #{Float.round(value, 4)}  #{Palette.tone(swatch.hex)}")
end

summary = Palette.summarize(swatches)
labels = Palette.sorted_labels(swatches)

IO.inspect(summary, label: "tones")
IO.puts("#{length(labels)} labels, max depth #{Palette.max_depth()}")

result =
  try do
    Palette.new("broken", "not-a-hex")
  rescue
    error in Palette.InvalidHexError -> {:error, Exception.message(error)}
  else
    swatch -> {:ok, swatch}
  after
    IO.puts("done")
  end

IO.inspect(result)

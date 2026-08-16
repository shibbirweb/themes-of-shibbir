// C# sample: namespaces, records, LINQ, properties, async, pattern matching.

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace Shibbir.Themes;

public enum TokenKind
{
    Comment,
    Keyword,
    String,
    Number,
}

public record Swatch(string Label, string Hex, IReadOnlyList<string> Tags)
{
    public const string DefaultHex = "#EEFFFF";

    public string Describe() => $"{Label} => {Hex}";
}

public interface IDescribable
{
    string Describe();

    string Shout() => Describe().ToUpperInvariant();
}

public sealed partial class Registry : IDescribable
{
    private static readonly Regex HexPattern = HexRegex();

    private readonly Dictionary<string, Swatch> _swatches = new();

    public Registry(string name, bool strict = false)
    {
        Name = name;
        Strict = strict;
    }

    public string Name { get; }

    public bool Strict { get; init; }

    public int Count => _swatches.Count;

    public IReadOnlyCollection<Swatch> Swatches => _swatches.Values;

    [GeneratedRegex(@"^#(?:[0-9a-fA-F]{3}){1,2}$")]
    private static partial Regex HexRegex();

    public void Add(Swatch swatch)
    {
        if (!HexPattern.IsMatch(swatch.Hex))
        {
            throw new ArgumentException($"Invalid hex: {swatch.Hex}", nameof(swatch));
        }

        _swatches[swatch.Label] = swatch;
    }

    public Swatch? Find(string label) =>
        _swatches.TryGetValue(label, out var swatch) ? swatch : null;

    public string Describe() => $"{Name} ({Count} swatches)";

    public async Task<IReadOnlyList<Swatch>> LoadAsync(string path)
    {
        await using var stream = File.OpenRead(path);
        var parsed = await JsonSerializer.DeserializeAsync<List<Swatch>>(stream);

        return parsed ?? new List<Swatch>();
    }

    public static string Classify(TokenKind kind) => kind switch
    {
        TokenKind.Comment => "italic",
        TokenKind.Keyword or TokenKind.String => "normal",
        TokenKind.Number => "numeric",
        _ => throw new ArgumentOutOfRangeException(nameof(kind)),
    };
}

public static class Program
{
    public static void Main(string[] args)
    {
        var registry = new Registry("Themes of Shibbir", strict: true);

        registry.Add(new Swatch("background", "#263238", new[] { "ui" }));
        registry.Add(new Swatch("keyword", "#C792EA", Array.Empty<string>()));

        var labels = registry.Swatches
            .Where(s => s.Hex != Swatch.DefaultHex)
            .OrderBy(s => s.Label, StringComparer.Ordinal)
            .Select(s => s.Label.ToUpperInvariant())
            .ToList();

        foreach (var (label, index) in labels.Select((value, i) => (value, i)))
        {
            Console.WriteLine($"{index + 1,2}. {label}");
        }

        Console.WriteLine(registry.Describe());
        Console.WriteLine(Registry.Classify(TokenKind.Comment));
    }
}

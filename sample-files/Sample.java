// Java sample: annotations, generics, records, streams, switch expressions.

package com.shibbir.themes;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

public final class Sample {

    public static final String DEFAULT_HEX = "#EEFFFF";
    private static final int MAX_DEPTH = 8;
    private static final Pattern HEX = Pattern.compile("^#(?:[0-9a-fA-F]{3}){1,2}$");

    public enum TokenKind {
        COMMENT("comment"),
        KEYWORD("keyword"),
        STRING("string");

        private final String scope;

        TokenKind(String scope) {
            this.scope = scope;
        }

        public String scope() {
            return scope;
        }
    }

    public record Swatch(String label, String hex, List<String> tags) {
        public Swatch {
            Objects.requireNonNull(label, "label must not be null");
            if (!HEX.matcher(hex).matches()) {
                throw new IllegalArgumentException("Invalid hex: " + hex);
            }
        }

        public String describe() {
            return "%s => %s".formatted(label, hex);
        }
    }

    public interface Describable {
        String describe();

        default String shout() {
            return describe().toUpperCase();
        }
    }

    private final Map<String, Swatch> swatches = new java.util.HashMap<>();

    @SafeVarargs
    public final void addAll(Swatch... incoming) {
        for (Swatch swatch : incoming) {
            swatches.put(swatch.label(), swatch);
        }
    }

    public Optional<Swatch> find(String label) {
        return Optional.ofNullable(swatches.get(label));
    }

    public List<String> sortedLabels() {
        return swatches.values().stream()
                .filter(swatch -> !DEFAULT_HEX.equals(swatch.hex()))
                .map(Swatch::label)
                .sorted(Comparator.naturalOrder())
                .collect(Collectors.toList());
    }

    public static String classify(TokenKind kind) {
        return switch (kind) {
            case COMMENT -> "italic";
            case KEYWORD, STRING -> "normal";
        };
    }

    public static void main(String[] args) {
        var sample = new Sample();

        sample.addAll(
                new Swatch("background", "#263238", List.of("ui")),
                new Swatch("keyword", "#C792EA", new ArrayList<>()));

        String text = """
                Text block with a quote " and interpolation-free braces {}.
                Max depth is %d.
                """.formatted(MAX_DEPTH);

        try {
            System.out.println(text);
            sample.sortedLabels().forEach(System.out::println);
        } catch (RuntimeException exception) {
            System.err.println("failed: " + exception.getMessage());
        } finally {
            System.out.printf("%d swatches%n", sample.swatches.size());
        }
    }
}

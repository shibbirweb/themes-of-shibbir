// C++ sample: templates, namespaces, smart pointers, lambdas, RAII.

#include <algorithm>
#include <iostream>
#include <map>
#include <memory>
#include <optional>
#include <regex>
#include <stdexcept>
#include <string>
#include <string_view>
#include <vector>

namespace palette {

inline constexpr std::string_view kDefaultHex = "#EEFFFF";
inline constexpr std::size_t kMaxDepth = 8;

enum class TokenKind : std::uint8_t {
    Comment,
    Keyword,
    String,
    Number,
};

class InvalidHexError : public std::runtime_error {
public:
    explicit InvalidHexError(const std::string& hex)
        : std::runtime_error("Invalid hex value: " + hex) {}
};

struct Swatch {
    std::string label;
    std::string hex{kDefaultHex};
    std::vector<std::string> tags{};

    [[nodiscard]] std::string describe() const {
        return label + " => " + hex;
    }

    friend std::ostream& operator<<(std::ostream& os, const Swatch& swatch) {
        return os << swatch.describe();
    }
};

template <typename T>
class Registry {
public:
    explicit Registry(std::string name) : name_(std::move(name)) {}

    void add(const std::string& key, T value) {
        items_.insert_or_assign(key, std::move(value));
    }

    [[nodiscard]] std::optional<T> find(const std::string& key) const {
        if (auto it = items_.find(key); it != items_.end()) {
            return it->second;
        }
        return std::nullopt;
    }

    [[nodiscard]] std::size_t size() const noexcept { return items_.size(); }

private:
    std::string name_;
    std::map<std::string, T> items_;
};

double luminance(std::string_view hex) {
    static const std::regex pattern{R"(^#([0-9a-fA-F]{2})([0-9a-fA-F]{2})([0-9a-fA-F]{2})$)"};
    std::smatch match;
    std::string text{hex};

    if (!std::regex_match(text, match, pattern)) {
        throw InvalidHexError(text);
    }

    const auto red = std::stoi(match[1].str(), nullptr, 16);
    const auto green = std::stoi(match[2].str(), nullptr, 16);
    const auto blue = std::stoi(match[3].str(), nullptr, 16);

    return (0.2126 * red + 0.7152 * green + 0.0722 * blue) / 255.0;
}

}  // namespace palette

int main() {
    using palette::Swatch;

    auto registry = std::make_unique<palette::Registry<Swatch>>("Themes of Shibbir");

    std::vector<Swatch> swatches{
        {"background", "#263238", {"ui"}},
        {"keyword", "#C792EA", {}},
        {"string", "#C3E88D", {}},
    };

    for (const auto& swatch : swatches) {
        registry->add(swatch.label, swatch);
    }

    std::sort(swatches.begin(), swatches.end(),
              [](const Swatch& lhs, const Swatch& rhs) { return lhs.label < rhs.label; });

    for (const auto& swatch : swatches) {
        try {
            std::cout << swatch << "  luminance=" << palette::luminance(swatch.hex) << '\n';
        } catch (const palette::InvalidHexError& error) {
            std::cerr << "skipped: " << error.what() << '\n';
        }
    }

    std::cout << registry->size() << " swatches, max depth " << palette::kMaxDepth << '\n';

    return 0;
}

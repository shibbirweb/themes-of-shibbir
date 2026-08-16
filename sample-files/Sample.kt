// Kotlin sample: data classes, sealed classes, extensions, coroutines, DSLs.

package com.shibbir.themes

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.withContext

const val DEFAULT_HEX = "#EEFFFF"
const val MAX_DEPTH = 8

private val HEX_PATTERN = Regex("""^#(?:[0-9a-fA-F]{3}){1,2}$""")

enum class TokenKind(val scope: String) {
    COMMENT("comment"),
    KEYWORD("keyword"),
    STRING("string"),
    NUMBER("constant.numeric"),
}

sealed class PaletteResult {
    data class Success(val swatches: List<Swatch>) : PaletteResult()
    data class Failure(val reason: String, val cause: Throwable? = null) : PaletteResult()
    object Empty : PaletteResult()
}

data class Swatch(
    val label: String,
    val hex: String = DEFAULT_HEX,
    val tags: List<String> = emptyList(),
) {
    init {
        require(HEX_PATTERN.matches(hex)) { "Invalid hex: $hex" }
    }

    fun describe(): String = "$label => $hex"
}

val Swatch.luminance: Double
    get() {
        val value = hex.removePrefix("#").toInt(16)
        val red = (value shr 16 and 0xFF).toDouble()
        val green = (value shr 8 and 0xFF).toDouble()
        val blue = (value and 0xFF).toDouble()

        return (0.2126 * red + 0.7152 * green + 0.0722 * blue) / 255
    }

fun Swatch.isDark(): Boolean = luminance < 0.5

class Registry(val name: String, private val strict: Boolean = false) {
    private val swatches = mutableMapOf<String, Swatch>()

    val size: Int get() = swatches.size

    operator fun plusAssign(swatch: Swatch) {
        swatches[swatch.label] = swatch
    }

    operator fun get(label: String): Swatch? = swatches[label]

    fun sortedLabels(): List<String> = swatches.values
        .filter { it.hex != DEFAULT_HEX }
        .map { it.label.uppercase() }
        .sorted()

    suspend fun loadAll(paths: List<String>): PaletteResult = coroutineScope {
        try {
            val loaded = paths
                .map { path -> async(Dispatchers.IO) { load(path) } }
                .awaitAll()
                .filterNotNull()

            if (loaded.isEmpty()) PaletteResult.Empty else PaletteResult.Success(loaded)
        } catch (error: Exception) {
            PaletteResult.Failure(reason = "load failed", cause = error)
        }
    }

    private suspend fun load(path: String): Swatch? = withContext(Dispatchers.IO) {
        runCatching { Swatch(label = path.substringAfterLast('/'), hex = "#C792EA") }.getOrNull()
    }

    override fun toString(): String = "Registry($name, $size swatches, strict=$strict)"
}

fun classify(kind: TokenKind): String = when (kind) {
    TokenKind.COMMENT -> "italic"
    TokenKind.KEYWORD, TokenKind.STRING -> "normal"
    TokenKind.NUMBER -> "numeric"
}

fun main() {
    val registry = Registry("Themes of Shibbir", strict = true)

    registry += Swatch("background", "#263238", listOf("ui"))
    registry += Swatch("keyword", "#C792EA")

    registry.sortedLabels().forEachIndexed { index, label ->
        println("${(index + 1).toString().padStart(2)}. $label")
    }

    val summary = """
        |$registry
        |Max depth: $MAX_DEPTH
        |Comment style: ${classify(TokenKind.COMMENT)}
    """.trimMargin()

    println(summary)
}

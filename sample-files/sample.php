<?php

/**
 * PHP sample. This theme has PHP specific rules for namespaces,
 * use statements, and the inheritance separator, so those are
 * exercised deliberately below.
 */

declare(strict_types=1);

namespace App\Models\Palette;

use App\Models\BaseModel;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Cache;

interface Describable
{
    public function describe(): string;
}

trait HasHexColors
{
    public function normalizeHex(string $hex): string
    {
        return strtoupper(ltrim($hex, '#'));
    }
}

abstract class AbstractSwatch extends \Illuminate\Database\Eloquent\Model implements Describable
{
    abstract public function describe(): string;
}

final class Swatch extends AbstractSwatch
{
    use HasFactory;
    use HasHexColors;

    public const DEFAULT_HEX = '#EEFFFF';

    protected $table = 'swatches';

    protected $fillable = [
        'theme_id',
        'label',
        'hex',
        'font_style',
        'is_active',
    ];

    protected $casts = [
        'theme_id' => 'integer',
        'is_active' => 'boolean',
        'created_at' => 'datetime',
    ];

    public function theme(): BelongsTo
    {
        return $this->belongsTo(Theme::class, 'theme_id');
    }

    public function describe(): string
    {
        return sprintf('%s => %s', $this->label, $this->hex ?? self::DEFAULT_HEX);
    }

    public static function activeForTheme(int $themeId): Collection
    {
        return Cache::remember("swatches.{$themeId}", 600, function () use ($themeId) {
            return static::query()
                ->where('theme_id', '=', $themeId)
                ->where('is_active', true)
                ->orderBy('label')
                ->get();
        });
    }
}

$swatches = [
    'background' => '#263238',
    'foreground' => '#EEFFFF',
    'keyword' => '#C792EA',
];

$heredoc = <<<TEXT
Heredoc content with interpolation: {$swatches['keyword']}
and a literal dollar sign: \$notAVariable
TEXT;

$nowdoc = <<<'TEXT'
Nowdoc content: $swatches is not interpolated here.
TEXT;

foreach ($swatches as $name => $hex) {
    if (! preg_match('/^#[0-9A-Fa-f]{6}$/', $hex)) {
        throw new \InvalidArgumentException("Invalid hex for {$name}");
    }

    echo strtoupper($name) . ': ' . $hex . PHP_EOL;
}

$total = count($swatches);
$isDark = $total > 0 ? true : false;
$label = $swatches['accent'] ?? 'none';

// Requires PHP 8. Kept deliberately so the `match` keyword is covered.
match (true) {
    $total === 0 => print('empty'),
    $total < 5 => print('small'),
    default => print('large'),
};

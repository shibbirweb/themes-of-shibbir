//! Rust sample: traits, generics, lifetimes, macros, pattern matching.

use std::collections::HashMap;
use std::fmt::{self, Display, Formatter};
use std::sync::{Arc, Mutex};

const DEFAULT_HEX: &str = "#EEFFFF";
const MAX_DEPTH: usize = 8;
static PREFIX: &str = "themes-of-shibbir";

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum TokenKind {
    Comment,
    Keyword,
    StringLiteral,
    Number(u8),
}

#[derive(Debug, thiserror::Error)]
pub enum PaletteError {
    #[error("invalid hex value: {0}")]
    InvalidHex(String),
    #[error("swatch not found: {label}")]
    NotFound { label: String },
}

#[derive(Debug, Clone, Default)]
pub struct Swatch {
    pub label: String,
    pub hex: String,
    pub tags: Vec<String>,
}

impl Display for Swatch {
    fn fmt(&self, f: &mut Formatter<'_>) -> fmt::Result {
        write!(f, "{} => {}", self.label, self.hex)
    }
}

pub trait Describe {
    fn describe(&self) -> String;

    fn shout(&self) -> String {
        self.describe().to_uppercase()
    }
}

impl Describe for Swatch {
    fn describe(&self) -> String {
        format!("{}: {}", self.label, self.hex)
    }
}

pub struct Registry<'a> {
    name: &'a str,
    swatches: Arc<Mutex<HashMap<String, Swatch>>>,
}

impl<'a> Registry<'a> {
    pub fn new(name: &'a str) -> Self {
        Self {
            name,
            swatches: Arc::new(Mutex::new(HashMap::new())),
        }
    }

    pub fn add(&self, swatch: Swatch) -> Result<(), PaletteError> {
        if !swatch.hex.starts_with('#') || swatch.hex.len() != 7 {
            return Err(PaletteError::InvalidHex(swatch.hex));
        }

        let mut guard = self.swatches.lock().unwrap();
        guard.insert(swatch.label.clone(), swatch);

        Ok(())
    }

    pub fn find(&self, label: &str) -> Option<Swatch> {
        self.swatches.lock().ok()?.get(label).cloned()
    }
}

fn classify(kind: TokenKind) -> &'static str {
    match kind {
        TokenKind::Comment => "italic",
        TokenKind::Keyword | TokenKind::StringLiteral => "normal",
        TokenKind::Number(level) if level > 4 => "deep",
        TokenKind::Number(_) => "shallow",
    }
}

fn main() {
    let registry = Registry::new(PREFIX);

    let swatches = vec![
        Swatch {
            label: "background".to_string(),
            hex: "#263238".to_string(),
            tags: vec!["ui".into()],
        },
        Swatch {
            label: "keyword".to_string(),
            hex: "#C792EA".to_string(),
            ..Default::default()
        },
    ];

    for swatch in &swatches {
        if let Err(error) = registry.add(swatch.clone()) {
            eprintln!("skipped: {error}");
            continue;
        }

        println!("{} ({})", swatch, swatch.describe());
    }

    let labels: Vec<String> = swatches
        .iter()
        .filter(|s| s.hex != DEFAULT_HEX)
        .map(|s| s.label.to_uppercase())
        .collect();

    assert_eq!(labels.len(), 2);
    println!("{} labels, max depth {MAX_DEPTH}", labels.len());
    println!("{}", classify(TokenKind::Number(6)));
}

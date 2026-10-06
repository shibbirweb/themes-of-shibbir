// Validates every theme contributed in package.json. Used by both the CI and
// publish workflows, and runnable locally with `pnpm validate`.
//
// Checks, per theme:
//   - the file exists and parses as JSON
//   - `name` equals the picker `label`, and the label carries the shared prefix
//   - `type` agrees with `uiTheme` in package.json
//   - every color is a valid hex color
//   - every token rule has settings, with valid colors and fontStyle
// And per pair of sibling themes (see PAIRS): the two files are structurally
// parallel, so only their values differ.

import fs from 'node:fs';

const LABEL_PREFIX = 'Themes of Shibbir: ';

// Sibling themes that must keep the same keys, rules, and order.
const PAIRS = [
	['themes/dark-solid-color-theme.json', 'themes/dark-shades-color-theme.json'],
	['themes/islands-dark-color-theme.json', 'themes/islands-light-color-theme.json'],
];

const UI_THEME_TYPES = {
	'vs': 'light',
	'vs-dark': 'dark',
	'hc-black': 'hc',
	'hc-light': 'hcLight',
};

const HEX = /^#(?:[0-9a-fA-F]{3,4}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$/;
const FONT_STYLES = new Set(['italic', 'bold', 'underline', 'strikethrough']);

const errors = [];

function fail(file, message) {
	errors.push(`${file}: ${message}`);
}

function checkColor(file, where, value) {
	if (typeof value !== 'string' || !HEX.test(value)) {
		fail(file, `${where} is not a hex color: ${JSON.stringify(value)}`);
	}
}

function checkFontStyle(file, where, value) {
	if (typeof value !== 'string') {
		fail(file, `${where} fontStyle must be a string`);
		return;
	}
	for (const style of value.split(' ').filter(Boolean)) {
		if (!FONT_STYLES.has(style)) {
			fail(file, `${where} has unknown fontStyle "${style}"`);
		}
	}
}

function checkTheme(file, entry, theme) {
	if (!entry.label.startsWith(LABEL_PREFIX)) {
		fail(file, `label "${entry.label}" must start with "${LABEL_PREFIX}"`);
	}
	if (theme.name !== entry.label) {
		fail(file, `name "${theme.name}" must equal its package.json label "${entry.label}"`);
	}
	const expectedType = UI_THEME_TYPES[entry.uiTheme];
	if (!expectedType) {
		fail(file, `unknown uiTheme "${entry.uiTheme}"`);
	} else if (theme.type !== expectedType) {
		fail(file, `type "${theme.type}" does not match uiTheme "${entry.uiTheme}" (expected "${expectedType}")`);
	}

	for (const [key, value] of Object.entries(theme.colors ?? {})) {
		checkColor(file, `colors["${key}"]`, value);
	}

	(theme.tokenColors ?? []).forEach((rule, index) => {
		const where = `tokenColors[${index}]${rule.name ? ` ("${rule.name}")` : ''}`;
		if (!rule.settings || typeof rule.settings !== 'object') {
			fail(file, `${where} has no settings`);
			return;
		}
		for (const prop of ['foreground', 'background']) {
			if (rule.settings[prop] !== undefined) {
				checkColor(file, `${where} ${prop}`, rule.settings[prop]);
			}
		}
		if (rule.settings.fontStyle !== undefined) {
			checkFontStyle(file, where, rule.settings.fontStyle);
		}
	});

	for (const [selector, value] of Object.entries(theme.semanticTokenColors ?? {})) {
		const where = `semanticTokenColors["${selector}"]`;
		if (typeof value === 'string') {
			checkColor(file, where, value);
			continue;
		}
		for (const prop of ['foreground', 'background']) {
			if (value[prop] !== undefined) {
				checkColor(file, `${where} ${prop}`, value[prop]);
			}
		}
		if (value.fontStyle !== undefined) {
			checkFontStyle(file, where, value.fontStyle);
		}
	}
}

function shape(theme) {
	return {
		colors: Object.keys(theme.colors ?? {}),
		tokenColors: (theme.tokenColors ?? []).map((rule) => ({
			name: rule.name,
			scope: rule.scope,
			settings: Object.keys(rule.settings ?? {}).sort(),
		})),
		semanticTokenColors: Object.keys(theme.semanticTokenColors ?? {}),
	};
}

function checkPair(fileA, themeA, fileB, themeB) {
	const a = shape(themeA);
	const b = shape(themeB);
	for (const part of Object.keys(a)) {
		if (JSON.stringify(a[part]) !== JSON.stringify(b[part])) {
			fail(`${fileA} + ${fileB}`, `${part} differ in keys, rules, or order; sibling themes must stay structurally parallel`);
		}
	}
}

const themes = loadContributedThemes();
const loaded = new Map();

for (const entry of themes) {
	const file = entry.path.replace(/^\.\//, '');
	if (!fs.existsSync(file)) {
		fail(file, `missing theme file for label "${entry.label}"`);
		continue;
	}
	let theme;
	try {
		theme = JSON.parse(fs.readFileSync(file, 'utf8'));
	} catch (error) {
		fail(file, `is not valid JSON: ${error.message}`);
		continue;
	}
	loaded.set(file, theme);
	checkTheme(file, entry, theme);
	console.log(`checked ${entry.label} -> ${file} (${Object.keys(theme.colors ?? {}).length} colors, ${(theme.tokenColors ?? []).length} token rules)`);
}

for (const [fileA, fileB] of PAIRS) {
	if (loaded.has(fileA) && loaded.has(fileB)) {
		checkPair(fileA, loaded.get(fileA), fileB, loaded.get(fileB));
	} else {
		fail(`${fileA} + ${fileB}`, 'listed as a pair but not both contributed in package.json');
	}
}

if (errors.length > 0) {
	for (const error of errors) {
		console.error(`::error::${error}`);
	}
	console.error(`${errors.length} problem(s) found.`);
	process.exit(1);
}

console.log(`All ${themes.length} themes and ${PAIRS.length} pairs are valid.`);

function loadContributedThemes() {
	const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
	const contributed = pkg.contributes?.themes ?? [];
	if (contributed.length === 0) {
		fail('package.json', 'contributes no themes');
	}
	return contributed;
}

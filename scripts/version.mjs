// Reads and changes the extension's version. package.json is the source of
// truth; CHANGELOG.md and the README's install example follow it.
//
//     node scripts/version.mjs show              print the version
//     node scripts/version.mjs check             verify the changelog and README agree (CI runs this)
//     node scripts/version.mjs level             print the bump the unreleased commits call for
//     node scripts/version.mjs bump <level>      move to the next version: auto | patch | minor | major | x.y.z
//     node scripts/version.mjs notes [x.y.z]     print a changelog section (Unreleased by default)
//
// Releases are normally cut by the "Release" workflow, which runs `bump` and
// opens the release pull request. See the Releasing section of CLAUDE.md.

import { execFileSync } from 'node:child_process';
import fs from 'node:fs';

const PACKAGE_JSON = 'package.json';
const CHANGELOG = 'CHANGELOG.md';
const README = 'README.md';

const SEMVER = /^(\d+)\.(\d+)\.(\d+)$/;
const LEVELS = ['patch', 'minor', 'major'];

const read = (path) => fs.readFileSync(path, 'utf8');

function fail(message) {
	console.error(message);
	process.exit(1);
}

function currentVersion() {
	const version = JSON.parse(read(PACKAGE_JSON)).version;
	if (!SEMVER.test(version ?? '')) {
		fail(`package.json version "${version}" is not x.y.z`);
	}
	return version;
}

function nextVersion(version, level) {
	const [major, minor, patch] = version.match(SEMVER).slice(1).map(Number);
	if (level === 'major') {
		return `${major + 1}.0.0`;
	}
	if (level === 'minor') {
		return `${major}.${minor + 1}.0`;
	}
	return `${major}.${minor}.${patch + 1}`;
}

function git(...args) {
	try {
		return execFileSync('git', args, { encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] }).trim();
	} catch {
		return '';
	}
}

// Subjects of the commits no release tag contains yet, merges left out.
function unreleasedSubjects() {
	return git('log', 'HEAD', '--no-merges', '--format=%s', '--not', '--tags=v*')
		.split('\n')
		.filter(Boolean);
}

// The bump the unreleased conventional commits call for, or null when none of
// them changes what people install (docs, chore, ci, test and the like).
function suggestLevel(subjects) {
	let level = null;
	for (const subject of subjects) {
		const match = subject.match(/^(\w+)(?:\([^)]*\))?(!)?:/);
		if (!match) {
			continue;
		}
		const [, type, bang] = match;
		if (bang) {
			return 'major';
		}
		if (type === 'feat') {
			level = 'minor';
		} else if (['fix', 'perf', 'refactor', 'style'].includes(type) && level === null) {
			level = 'patch';
		}
	}
	return level;
}

// The body of a "## [label]" section, without its heading, trimmed. Null when
// the section does not exist.
function changelogSection(text, label) {
	const lines = text.split('\n');
	const start = lines.findIndex((line) => line.startsWith(`## [${label}]`));
	if (start === -1) {
		return null;
	}
	let end = lines.findIndex((line, index) => index > start && (line.startsWith('## [') || /^\[[^\]]+\]: /.test(line)));
	if (end === -1) {
		end = lines.length;
	}
	return lines.slice(start + 1, end).join('\n').trim();
}

function setPackageVersion(version) {
	const text = read(PACKAGE_JSON);
	const updated = text.replace(/("version":\s*")[^"]+(")/, `$1${version}$2`);
	if (updated === text) {
		fail('could not rewrite the version in package.json');
	}
	fs.writeFileSync(PACKAGE_JSON, updated);
}

// Moves the Unreleased entries under a dated heading for `version`, leaves an
// empty Unreleased section above it, and updates the compare links.
function dateChangelog(previous, version) {
	const text = read(CHANGELOG);
	const body = changelogSection(text, 'Unreleased');
	if (body === null) {
		fail('CHANGELOG.md has no [Unreleased] section');
	}
	if (body === '') {
		fail('The [Unreleased] section of CHANGELOG.md is empty. Add the changes this release ships, then run it again.');
	}
	const today = new Date().toISOString().slice(0, 10);
	const lines = text.split('\n');
	const start = lines.findIndex((line) => line.startsWith('## [Unreleased]'));
	let end = lines.findIndex((line, index) => index > start && (line.startsWith('## [') || /^\[[^\]]+\]: /.test(line)));
	if (end === -1) {
		end = lines.length;
	}
	const section = ['## [Unreleased]', '', `## [${version}] - ${today}`, '', body, ''];
	let updated = [...lines.slice(0, start), ...section, ...lines.slice(end)].join('\n');

	const link = updated.match(/^\[Unreleased\]: (\S+)\/compare\/v[^.\s]+\.[^.\s]+\.[^.\s]+\.\.\.HEAD$/m);
	if (!link) {
		fail('CHANGELOG.md has no "[Unreleased]: <repo>/compare/vX.Y.Z...HEAD" link to update');
	}
	const repo = link[1];
	updated = updated.replace(
		link[0],
		`[Unreleased]: ${repo}/compare/v${version}...HEAD\n[${version}]: ${repo}/compare/v${previous}...v${version}`,
	);
	fs.writeFileSync(CHANGELOG, updated);
}

function setReadmeVersion(version) {
	const text = read(README);
	fs.writeFileSync(README, text.replace(/themes-of-shibbir-\d+\.\d+\.\d+\.vsix/g, `themes-of-shibbir-${version}.vsix`));
}

function check() {
	const version = currentVersion();
	const problems = [];
	const changelog = read(CHANGELOG);
	if (changelogSection(changelog, 'Unreleased') === null) {
		problems.push('CHANGELOG.md has no [Unreleased] section');
	}
	if (!new RegExp(`^## \\[${version.replaceAll('.', '\\.')}\\] - \\d{4}-\\d{2}-\\d{2}$`, 'm').test(changelog)) {
		problems.push(`CHANGELOG.md has no dated "## [${version}] - YYYY-MM-DD" section`);
	}
	for (const match of read(README).matchAll(/themes-of-shibbir-(\d+\.\d+\.\d+)\.vsix/g)) {
		if (match[1] !== version) {
			problems.push(`README.md mentions ${match[0]}, expected themes-of-shibbir-${version}.vsix`);
		}
	}
	if (problems.length > 0) {
		for (const problem of problems) {
			console.error(`::error::${problem}`);
		}
		process.exit(1);
	}
	console.log(`package.json, CHANGELOG.md and README.md agree on ${version}`);
}

function bump(requested) {
	const previous = currentVersion();
	let version;
	if (SEMVER.test(requested ?? '')) {
		version = requested;
	} else if (requested === 'auto') {
		const level = suggestLevel(unreleasedSubjects());
		if (level === null) {
			fail('No feat or fix commits since the last release, so auto has nothing to bump. Choose patch, minor or major to release anyway.');
		}
		version = nextVersion(previous, level);
	} else if (LEVELS.includes(requested)) {
		version = nextVersion(previous, requested);
	} else {
		fail(`Unknown level "${requested}". Use auto, patch, minor, major, or an x.y.z version.`);
	}
	if (version === previous) {
		fail(`Already at ${version}.`);
	}
	// Check the changelog before writing anything, so a refused bump leaves
	// every file as it was.
	if (!changelogSection(read(CHANGELOG), 'Unreleased')) {
		fail('The [Unreleased] section of CHANGELOG.md is missing or empty. Add the changes this release ships, then run it again.');
	}
	setPackageVersion(version);
	dateChangelog(previous, version);
	setReadmeVersion(version);
	console.log(version);
}

function notes(version) {
	const section = changelogSection(read(CHANGELOG), version ?? 'Unreleased');
	if (!section) {
		fail(`CHANGELOG.md has no entries under [${version ?? 'Unreleased'}]`);
	}
	console.log(section);
}

const [command, argument] = process.argv.slice(2);

if (command === 'show') {
	console.log(currentVersion());
} else if (command === 'check') {
	check();
} else if (command === 'level') {
	console.log(suggestLevel(unreleasedSubjects()) ?? 'none');
} else if (command === 'bump') {
	bump(argument);
} else if (command === 'notes') {
	notes(argument);
} else {
	fail('Usage: node scripts/version.mjs show | check | level | bump <auto|patch|minor|major|x.y.z> | notes [x.y.z]');
}

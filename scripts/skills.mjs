import { existsSync } from "node:fs";
import { createHash } from "node:crypto";
import { execFileSync } from "node:child_process";
import {
  cp,
  mkdir,
  mkdtemp,
  readFile,
  readdir,
  rename,
  rm,
  stat,
  writeFile,
} from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

const root = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const collection = path.join(root, "agents", "runtime");
const catalogFile = path.join(root, "skills-lock.json");

function validate(catalog) {
  if (catalog.version !== 1 || !catalog.skills || Object.keys(catalog.skills).length === 0) {
    throw new Error("Expected a nonempty Skills CLI v1 catalog");
  }
  for (const [name, entry] of Object.entries(catalog.skills)) {
    if (!/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(name) || !/^[a-f0-9]{64}$/.test(entry.computedHash)) {
      throw new Error(`Invalid skill name or content hash: ${name}`);
    }
    if (entry.sourceType === "github") {
      if (existsSync(path.join(root, "agents", "personal-skills", name, "SKILL.md"))) {
        throw new Error(`Upstream source collides with custom skill: ${name}`);
      }
      if (!/^[\w.-]+\/[\w.-]+$/.test(entry.source) || !/^[a-f0-9]{40}$/i.test(entry.ref || "")) {
        throw new Error(`A full Git commit pin is required: ${name}`);
      }
      if (
        !entry.skillPath ||
        path.isAbsolute(entry.skillPath) ||
        entry.skillPath.split("/").includes("..") ||
        !entry.skillPath.endsWith("SKILL.md")
      ) {
        throw new Error(`Invalid source skill path: ${name}`);
      }
    } else if (entry.sourceType === "local") {
      if (entry.source !== `./agents/personal-skills/${name}` || entry.ref) {
        throw new Error(`Custom skills must use their tracked relative source: ${name}`);
      }
    } else {
      throw new Error(`Unsupported skill source: ${name}`);
    }
  }
}

// Matches the CLI's documented folder hash: sorted relative paths and bytes.
async function folderHash(directory) {
  const files = [];
  async function walk(current, relative = "") {
    for (const entry of await readdir(current, { withFileTypes: true })) {
      if (entry.name === ".git" || entry.name === "node_modules") continue;
      const filename = path.join(current, entry.name);
      const name = relative ? `${relative}/${entry.name}` : entry.name;
      if (entry.isSymbolicLink()) throw new Error(`Unexpected symlink in skill: ${filename}`);
      if (entry.isDirectory()) await walk(filename, name);
      else if (entry.isFile()) files.push({ name, filename });
      else throw new Error(`Unsupported file in skill: ${filename}`);
    }
  }
  await walk(directory);
  files.sort((a, b) => a.name.localeCompare(b.name));
  const hash = createHash("sha256");
  for (const file of files) hash.update(file.name).update(await readFile(file.filename));
  return hash.digest("hex");
}

async function verify(catalog, directory) {
  validate(catalog);
  const expected = Object.keys(catalog.skills).sort();
  const actual = (await readdir(directory)).sort();
  if (JSON.stringify(actual) !== JSON.stringify(expected))
    throw new Error("Installed skill inventory differs from the catalog");
  for (const [name, entry] of Object.entries(catalog.skills)) {
    const skill = path.join(directory, name);
    if (!(await stat(path.join(skill, "SKILL.md"))).isFile())
      throw new Error(`Missing SKILL.md: ${name}`);
    if ((await folderHash(skill)) !== entry.computedHash)
      throw new Error(`Content hash mismatch: ${name}`);
    if (
      entry.sourceType === "local" &&
      (await folderHash(path.join(root, entry.source))) !== entry.computedHash
    ) {
      throw new Error(`Custom source changed; refresh its catalog entry with skills add: ${name}`);
    }
  }
}

async function install(catalog, approvedBytes) {
  await mkdir(path.dirname(collection), { recursive: true });
  const stage = await mkdtemp(path.join(root, "agents", ".skills-stage-"));
  const previous = path.join(stage, "previous");
  let preserveStage = false;
  try {
    await writeFile(path.join(stage, "skills-lock.json"), approvedBytes);
    await cp(
      path.join(root, "agents", "personal-skills"),
      path.join(stage, "agents", "personal-skills"),
      { recursive: true },
    );
    console.log(
      `Restoring ${Object.keys(catalog.skills).length} pinned/custom skills with the Skills CLI…`,
    );
    try {
      execFileSync("skills", ["experimental_install"], {
        cwd: stage,
        env: { ...process.env, DISABLE_TELEMETRY: "1" },
        maxBuffer: 16 * 1024 * 1024,
        stdio: ["ignore", "pipe", "pipe"],
      });
    } catch (error) {
      throw new Error(
        `Skills CLI restore failed:\n${String(error.stdout || "")}\n${String(error.stderr || error.message)}`,
      );
    }
    if (!(await readFile(path.join(stage, "skills-lock.json"))).equals(approvedBytes)) {
      throw new Error("Skills CLI changed the approved catalog; refusing to deploy");
    }
    const candidate = path.join(stage, ".agents", "skills");
    await verify(catalog, candidate);
    // Recheck source metadata before replacing an existing generated collection.
    if (!(await readFile(catalogFile)).equals(approvedBytes))
      throw new Error("Catalog changed during restore; retry after reviewing the change");
    let movedPrevious = false;
    try {
      await rename(collection, previous);
      movedPrevious = true;
    } catch (error) {
      if (error.code !== "ENOENT") throw error;
    }
    try {
      await rename(candidate, collection);
    } catch (error) {
      if (movedPrevious) {
        try {
          await rename(previous, collection);
        } catch (rollbackError) {
          preserveStage = true;
          throw new Error(
            `Cannot restore the old collection; it is preserved at ${previous}: ${rollbackError.message}`,
          );
        }
      }
      throw error;
    }
    console.log(
      `Verified and installed ${Object.keys(catalog.skills).length} skills; catalog unchanged.`,
    );
  } finally {
    if (!preserveStage) await rm(stage, { recursive: true, force: true });
  }
}

try {
  const bytes = await readFile(catalogFile);
  const catalog = JSON.parse(bytes);
  validate(catalog);
  const command = process.argv[2];
  if (command === "install") await install(catalog, bytes);
  else if (command === "verify") {
    await verify(catalog, process.argv[3] ? path.resolve(process.argv[3]) : collection);
    console.log(`Verified ${Object.keys(catalog.skills).length} skills.`);
  } else throw new Error("Usage: node scripts/skills.mjs install|verify [collection]");
} catch (error) {
  console.error(error.message);
  process.exitCode = 1;
}

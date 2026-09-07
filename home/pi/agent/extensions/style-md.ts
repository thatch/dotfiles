import * as fs from "node:fs";
import * as path from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const STYLE_NAMES = ["style.md", "STYLE.md"];

function findGitRoot(start: string): string | undefined {
        let dir = path.resolve(start);
        while (true) {
                if (fs.existsSync(path.join(dir, ".git"))) return dir;
                const parent = path.dirname(dir);
                if (parent === dir) return undefined;
                dir = parent;
        }
}

function findStyleFile(cwd: string): string | undefined {
        const root = findGitRoot(cwd) ?? path.parse(path.resolve(cwd)).root;
        let dir = path.resolve(cwd);

        while (true) {
                for (const name of STYLE_NAMES) {
                        const candidate = path.join(dir, name);
                        if (fs.existsSync(candidate) && fs.statSync(candidate).isFile()) {
                                return candidate;
                        }
                }

                if (dir === root) break;
                const parent = path.dirname(dir);
                if (parent === dir) break;
                dir = parent;
        }

        const homeStyle = path.join(process.env.HOME ?? "", ".claude", "style.md");
        if (homeStyle && fs.existsSync(homeStyle) && fs.statSync(homeStyle).isFile()) {
                return homeStyle;
        }

        return undefined;
}

export default function styleMdExtension(pi: ExtensionAPI) {
        let notifiedPath: string | undefined;

        pi.on("before_agent_start", async (event, ctx) => {
                const stylePath = findStyleFile(ctx.cwd);
                if (!stylePath) return;

                const styleContent = fs.readFileSync(stylePath, "utf8");
                if (stylePath !== notifiedPath) {
                        notifiedPath = stylePath;
                        ctx.ui.notify(`Loaded style instructions from ${stylePath}`, "info");
                }

                return {
                        systemPrompt:
                                event.systemPrompt +
                                `

## Style instructions

Loaded from ${stylePath}:

${styleContent}
`,
                };
        });
}

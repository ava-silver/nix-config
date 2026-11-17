// Shows or hides a shell split to the right of the shown tab. Each space gets one shell,
// started once and parked between uses, so it reappears instantly with its history.
// Bound in keys.json as "mod.open:side-term"; draws nothing.

import { View, div } from "gpui-kit";
import { props, closeOverlay, focused, panes, terminals, exec, run, shared, setShared, notify, home } from "herdr";

const KEY = "side-term";

// The app learns of new terminals and panes a moment after the command that makes them.
async function until(cx, ready) {
  for (let i = 0; i < 50 && !ready(); i++) await cx.sleep(50);
}

// Hiding parks the shell at the core's detached size and showing resizes it again. The prompt
// redraws at each width and leaves copies behind, so clear the screen once the size settles,
// unless a program other than the shell is running.
async function redraw(cx, address) {
  let last = null;
  for (let i = 0; i < 20; i++) {
    await cx.sleep(100);
    const t = JSON.parse((await exec("hc", ["get", address, "--json"])).stdout);
    const size = `${t.cols}x${t.rows}`;
    if (size === last) {
      if (t.foreground?.pid === t.pid) await exec("hc", ["keys", address, "ctrl+l"]);
      return;
    }
    last = size;
  }
}

export default class SideTerm extends View {
  init(_props, cx) {
    const overlay = props()?.overlay;
    cx.spawn(async (cx) => {
      try {
        await this.toggle(cx);
      } catch (e) {
        notify({ title: "Side terminal", body: String(e?.message ?? e), level: "error" });
      } finally {
        if (overlay) closeOverlay(overlay);
      }
    });
  }

  async toggle(cx) {
    const here = focused();
    if (!here?.space) return;
    const owned = shared(KEY) ?? {};
    let address = owned[here.space];
    if (address && panes().some((p) => p.terminal === address)) return run("terminal.park", { terminal: address });
    const parked = terminals().some((t) => t.address === address);
    if (!parked) {
      const r = await exec("hc", ["run", "--json", "--bg", "--no-parent", "--cwd", here.cwd ?? home(), "--label", `herdr.side-term=${here.space}`]);
      if (r.code !== 0) throw new Error(r.stderr.trim() || "hc run failed");
      address = JSON.parse(r.stdout).address;
      setShared(KEY, { ...owned, [here.space]: address });
      await until(cx, () => terminals().some((t) => t.address === address));
    }
    run("terminal.keep", { terminal: address, place: "right" });
    await until(cx, () => panes().some((p) => p.terminal === address));
    run("pane.focus", { terminal: address });
    if (parked) await redraw(cx, address);
  }

  render() {
    return div();
  }
}
